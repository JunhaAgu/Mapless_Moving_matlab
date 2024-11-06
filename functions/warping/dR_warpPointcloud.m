function [str_cur_warped, residual] = dR_warpPointcloud(s_next, s_cur, velo, T_gt_, flag_vis, data_type)
%% parameter
n_v = size(s_next.rho,1); 
n_h = size(s_next.rho,2);
dist_pts = 10;

%% representative pts
velo_x = s_cur.pts(:,:,1)';
velo_y = s_cur.pts(:,:,2)';
velo_z = s_cur.pts(:,:,3)';
velo_cur = [velo_x(:)' ; velo_y(:)' ; velo_z(:)'];
velo_cur(:,and( and(velo_cur(1,:)<dist_pts,velo_cur(1,:)>-dist_pts), and(velo_cur(2,:)<dist_pts,velo_cur(2,:)>-dist_pts) ) ) = [];

%% Far pts are warped by the original pts
velo_cur_origin = velo';
velo_cur_origin(:,or( or(velo_cur_origin(1,:)>dist_pts,velo_cur_origin(1,:)<-dist_pts), or(velo_cur_origin(2,:)>dist_pts,velo_cur_origin(2,:)<-dist_pts) ) ) = [];

% array of representative and original pts
velo_cur = [velo_cur, velo_cur_origin];

%% vertical angle resolusion for KITTI or CARLA
v_factor=1;
if data_type== "KITTI"
    top = linspace(2.5, -8.0, 32/v_factor); % 2 -8.5
    bottom = linspace(-8.50, -23.8, 32/v_factor); % -8.87 -24.87
    v_angle = [top, bottom];
elseif data_type == "CARLA"
    v_angle = linspace(2, -24.8, 64);
end

%% compensate zero in current rho image for warping
new_pts = compensateCurRhoZeroWarp(s_cur, n_v, n_h, v_angle);

% array of representative, original, and compensated pts
velo_cur = [velo_cur, new_pts];

%% current warped image
cur_pts_warped = T_gt_*[velo_cur ; ones(1,length(velo_cur))]; %T_gt_ : T_(i+1)(i)
[~, str_cur_warped, ~] = generateRangeImage(cur_pts_warped(1:3,:)', "HDL64", data_type);

if flag_vis
    figure(2);
    subplot(4 ,1,2); imagesc(str_cur_warped.rho);
    colormap hsv;
end

%% fill range image using interpolation
interp_range_row = 1+2 : n_v-2;
interp_range_col = 1+2 : n_h-2;
[cur_warped_rho_new, img_restor_mask] = interpRangeImageMin(str_cur_warped.rho, n_v, n_h, interp_range_col, interp_range_row);
str_cur_warped.rho = cur_warped_rho_new;

%% fill pts corresponding to filled range image (no affect the original pts)
str_cur_warped.pts = interpPtsWarp(str_cur_warped, img_restor_mask, interp_range_col, interp_range_row);

%% calculate occlusions
residual = str_cur_warped.rho - s_next.rho;

if flag_vis
%     figure(2);
%     subplot(5 ,1,1); imagesc(s_next.rho); title('Next (comp)'); colorbar;
%     subplot(5 ,1,2); imagesc(s_cur.rho); title('Cur (comp)'); colorbar;
%     subplot(5 ,1,3); imagesc(str_cur_warped.rho); title('Cur warped (comp)');colorbar;
%     subplot(5 ,1,4); imagesc(residual); title('Cur warped (comp) - Next (comp)'); colorbar;
%     colormap hsv;
    figure(2);
    subplot(4 ,1,1); imagesc(s_cur.rho);
    subplot(4 ,1,3); imagesc(str_cur_warped.rho);
    subplot(4 ,1,4); imagesc(s_next.rho);
    colormap hsv;
end

end

