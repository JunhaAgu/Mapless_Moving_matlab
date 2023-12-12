clear all; close all; clc;
dbstop if error;

%% addpath
addpath('functions/generateRangeImage');
addpath('functions/segmentGround');
addpath('functions/warping');
addpath('functions/extractDynamic');

%% Global parameter setting
set_GlobalParameter;

%% Load dataset
load_Dataset;

%% Initialize images
initialize_Images;

%% main
if data_type == "KITTI"
    iter_end = length(valid_data)-1;
elseif data_type == "CARLA"
    iter_end = length(valid_data)-2;
end

iter_start = 1;
for iter = iter_start:iter_end

    %% pointcloud input
    if iter == iter_start
        [str_cur, ~, ~] = cloudFilter(velo{iter}(:,1:3), "HDL64", data_type, 1);
    end
    [str_next, next_pts_index, next_pts_n] = cloudFilter(velo{iter+1}(:,1:3), "HDL64", data_type, 1);

    %% main process
    
    % Segment ground
    groundPtsIdx_next = fastsegmentGround(str_next); %0.1
    
    % Warp pcl represented in current frame to next frame
    
    if data_type == "KITTI"
        T_next2cur = (T_gt_{iter+1})^-1 ;
    elseif data_type == "CARLA"
        T_next2cur = (T_gt_{iter})^-1 ;
    end

    fprintf("norm(rot) = %f [deg]\n", norm(rad2deg(rotm2eul(T_next2cur(1:3,1:3)))));
    if norm(rad2deg(rotm2eul(T_next2cur(1:3,1:3)))) > 3
        object_factor = 1.5;
        object_thr = object_threshold * object_factor;
    else
        object_thr = object_threshold;
    end
    
    %%% Occlusion accumulation
    % Compute the occlusion dRdt
    [rho_cur_warped, dRdt] = dR_warpPointcloud(str_next, str_cur, velo{iter}(:,1:3), T_next2cur, flag_vis, data_type);

    % Warp the occlusion accumulation map
    accumulated_dRdt = warpPointcloud(str_next, str_cur, accumulated_dRdt, T_next2cur, data_type);
    accumulated_dRdt_score = warpPointcloud(str_next, str_cur, accumulated_dRdt_score, T_next2cur, data_type);
    
    %%% figure(100) accumulated_dRdt 'after warpPointcloud'
    if flag_vis == true
        figure(100); subplot(8,1,1);
        imagesc(accumulated_dRdt); title('after warpPointcloud'); colorbar; colormap hsv;
        sgtitle('accumulated\_dZdt');
    end
    
    %%% filter out outliers
    accumulated_dRdt = ...
        filterOutAccumdR(str_next, rho_cur_warped, accumulated_dRdt, accumulated_dRdt_score, dRdt, coef_accum_w, alpha, beta, flag_vis);
        
    %%% Extract object candidate via connected components in 2-D binary image
    accumulated_dRdt = extractObjectCandidate(accumulated_dRdt, str_next, object_thr, flag_vis);
    
    if flag_vis == true
        figure(100); subplot(8,1,4);
        imagesc(accumulated_dRdt); title('after extractObjectCandidate'); colorbar; colormap hsv;
        sgtitle('accumulated\_dZdt');
    end

    %%%% update object_mask
    object_mask = accumulated_dRdt>0;
    
    %%% figure(200) pts before segmentation
    if flag_vis == true
        figure(200);
        pcshow(str_next.pts, repmat(color_b_3,size(str_next.rho))); hold on;
        pcshow(str_next.pts.*repmat(object_mask~=0,1,1,3), repmat(color_y_3,size(str_next.rho))); hold off;
        xlim([-60 60]);ylim([-60 60]);zlim([-3 3]);
        view(-90,90);
        xlabel('x[m]'); ylabel('y[m]'); zlabel('z[m]');
        title(['(next) Iteration: ',num2str(iter), ', Frame: ', num2str(start+iter-1)],'color','yello','FontSize',15);
    end
  
    %%% Fast Segment
    accumulated_dRdt_restore = checkSegment(accumulated_dRdt, str_next, groundPtsIdx_next);
        
    if isempty(accumulated_dRdt_restore)
    else
        accumulated_dRdt = accumulated_dRdt_restore;
    end

    if flag_vis == true
        figure(100); subplot(8,1,5);
        imagesc(accumulated_dRdt); title('after checkSegment'); colorbar; colormap hsv;
        sgtitle('accumulated\_dZdt');
    end

    % update object_mask
    object_mask = accumulated_dRdt~=0; 
    
    %%% update accumulated_dRdt & accumulated_dRdt_score after checkSegment
    accumulated_dRdt_score = accumulated_dRdt_score + (accumulated_dRdt~=0);
    accumulated_dRdt = accumulated_dRdt + 4*accumulated_dRdt.*(accumulated_dRdt_score>2);
    accumulated_dRdt(accumulated_dRdt>1e3) = 1e3;

    if flag_vis == true
        figure(100); subplot(8,1,6);
        imagesc(accumulated_dRdt); title('after updateAccum'); colorbar; colormap hsv;
    end
    
    %%% Fill zero holes of image
    [accumulated_dRdt, accumulated_dRdt_score] = fillImageZeroHoles(accumulated_dRdt, accumulated_dRdt_score, str_next, groundPtsIdx_next, object_thr, flag_vis);

    if nnz(accumulated_dRdt) == 0
        accumulated_dRdt = (dRdt<0).*(dRdt>-(0.1*str_next.rho)).*(accumulated_dRdt_score>1).*(-dRdt);
        accumulated_dRdt = checkSegment(accumulated_dRdt, str_next, groundPtsIdx_next);
    end
    
    if flag_vis == true
        figure(100); subplot(8,1,8);
        imagesc(accumulated_dRdt); title('after fillImageZeroHoles'); colorbar; colormap hsv;
    end
    
    %%% 3D pts (dynamic objects) of original pointcloud
    real_pts_index = zeros(length(velo{iter+1}),1);
    obj_idx = find(accumulated_dRdt(:)>0);
    idx = 1;
    for i = obj_idx'
            nn = next_pts_n(i);
            if nn==0
                continue;
            end
            real_pts_index(idx:idx+nn-1,1) = next_pts_index(i,1:next_pts_n(i))';
            idx = idx + nn;
    end
    real_pts_index = real_pts_index(1:idx-1);
    real_pts_index(real_pts_index==0) = [];

    %% algorithm output (3D pts corresponding to representative pixels)
%     figure(201);
%     pcshow(str_next.pts, repmat(color_b_3,size(str_next.rho))); hold on;
%     pcshow(str_next.pts.*repmat(accumulated_dRdt~=0,1,1,3), repmat(color_y_3,size(str_next.rho))); hold off;
%     xlim([-60 60]);ylim([-60 60]);zlim([-3 3]);
%     view(-90,90);
%     xlabel('x[m]'); ylabel('y[m]'); zlabel('z[m]');
%     title(['(next\_update) Iteration: ',num2str(iter), ', Frame: ', num2str(start+iter-1)],'color','yello','FontSize',15);
    
    %% algorithm output (all pts)
    figure(301);
    pcshow(velo{iter+1}(:,1:3), repmat(color_b,length(velo{iter+1}(:,1:3)),1)); hold on;
    if isempty(real_pts_index)
        hold off;
    else
        pcshow(velo{iter+1}(real_pts_index,1:3), repmat(color_r,size(velo{iter+1}(real_pts_index,1:3),1),1), "MarkerSize",20); hold off;
    end
    set(gcf,'Color','w');
    set(gca,'Color','w');
    set(gca,'XColor','k'); set(gca,'YColor','k'); set(gca,'ZColor','k');

    view(-90,90);
    xlim([-20 20]);ylim([-20 20]);zlim([-3 3]);
    xlabel('x[m]'); ylabel('y[m]'); zlabel('z[m]');
    title(['Iteration: ',num2str(iter), ', Frame: ', num2str(start+iter-1)],'color','black','FontSize',15);

    ax = gca;
    ax.XAxis.LineWidth = 3;
    ax.YAxis.LineWidth = 3;
    ax.ZAxis.LineWidth = 3;

    ax.XAxis.FontSize = 25;
    ax.XAxis.FontWeight = "bold";
    ax.YAxis.FontSize = 25;
    ax.YAxis.FontWeight = "bold";
    ax.ZAxis.FontSize = 25;
    ax.ZAxis.FontWeight = "bold";

    % KITTI 00 pedestrian
    % view(-135, 20)
    % KITTI 01 vehicles
    % view(-225, 20)
    % KITTI 02 motorcycle
    % view(290, 20)
    % KITTI 05
    % view(315, 20)
    % KITTI 07
    % view(300, 20)
    % CARLA 01
    % view(200, 20)
    % CARLA 03
    % view(-150, 20)

    figure(301);
    hold on;
    plot3([0, 4],[0, 0],[0, 0],'LineWidth',5,'color','r');
    plot3([0, 0],[0, 4],[0, 0],'LineWidth',5,'color','g');
    plot3([0, 0],[0, 0],[0, 4],'LineWidth',5,'color',[0 0.4470 0.7410]);
    hold off;

    %% capture figure to make video
    if video_flag == true
        curframe = getframe(figure(301));
        writeVideo(vid_image,curframe);
    end

    %%% update for next iteration
    str_cur = str_next;

    accumulated_dRdt_score(accumulated_dRdt==0) = 0;

end 

if video_flag==1
    close (vid_image);
end

fprintf(">>>>>>>>>>> End of the algorithm <<<<<<<<<<\n");
