function [input_img, score_img] = fillImageZeroHoles(input_img, score_img, str_next, groundPtsIdx_next_comp, object_threshold, flag_vis)
    
    input_img_bin = imfill(input_img>0,'holes');
    input_img = interpAndfill_image(input_img, input_img_bin);
    score_img_bin = imfill(score_img>0,'holes');
    score_img = interpAndfill_image(score_img, score_img_bin);
%     score_img = interpAndfill_image(score_img, score_img_bin);
%     score_img = imfill(score_img);
%     input_img = interpAndfill_image(input_img, score_img);
%     input_img = imfill(input_img);

    if flag_vis == true
        figure(100); subplot(8,1,7);
        imagesc(input_img); title('after interpAndfill\_image'); colorbar; colormap hsv;
    end

    rho_zero_value = (str_next.rho==0);
%     rho_zero_value(1,:) = 0;
%     rho_zero_value(end,:) = 0;
%     rho_zero_value(end-1,:) = 0;

    input_img_mask = input_img>0;
    input_img_tmp = input_img;

    % Label objects
    [object_label, n_label] = bwlabel(or(rho_zero_value,input_img_mask));
    sum_object = zeros(1,n_label);
    for object_idx = 1:n_label
        object_area = (object_label == object_idx);
        sum_object(object_idx) = sum(sum(object_area));
        if(sum_object(object_idx) < object_threshold)
            % Ignore small object segmentations
            rho_zero_value(object_area)=0;
            input_img(object_area) = 0;
            score_img(object_area) = 0;
            continue;
        else
            B = padarray(object_area,1,1);
            BB = imfill(B,'holes');
            object_area_filled = BB(2:end-1,:);
%             figure(125);
%             imshow(object_area_filled);
            zero_candidate = object_area_filled+2*(input_img_mask);

            if nnz(zero_candidate>2)>0
                connect_zero_mean = mean(input_img(zero_candidate==3));
                input_img(zero_candidate==1) = connect_zero_mean;
                score_img(zero_candidate==1) = 1;
                input_img(groundPtsIdx_next_comp>0) = 0;
                score_img(groundPtsIdx_next_comp>0) = 0;
            end

%             rho_roi = str_next.rho.*input_img_mask.*object_area_filled;
            rho_roi = str_next.rho.*(input_img_tmp~=0).*object_area_filled;
%             if nnz(rho_roi)>0
%                 fprintf("nnz(rho_roi) is not empty\n");
%             end
            rho_roi(rho_roi==0)=[];
            if isempty(rho_roi(:))
                continue;
            end
            [N_hist,edges_hist] = histcounts(rho_roi(:),50);
            max_idx = find(N_hist==max(N_hist),1);
            if edges_hist(max_idx) - 10.0<0
                range_min = 0;
            else
                range_min = edges_hist(max_idx) - 15.0;
            end
            range_max = edges_hist(max_idx) + 15.0;

            %%추가
%             if isempty(rho_roi)
%                 continue;
%             end
% 
%             rho_roi_sort_vec = sort(rho_roi);
%             d_rho = rho_roi_sort_vec(2:end)-rho_roi_sort_vec(1:end-1);
%             y = movmedian(d_rho,3);
%             noise_idx = find((d_rho-y)>0.5);
%             range_min = rho_roi_sort_vec(1);
%             range_max = rho_roi_sort_vec(end);
% 
%             disconti = false(size(object_area));
% 
%             if ~isempty(noise_idx)
%                 n_noise = length(noise_idx);
%                 noise_idx_cnt = 1;
%                 n_conti = [];
%                 border_value = [];
%                 while n_noise>0
%                     if noise_idx_cnt == 1
%                         n_conti(1, noise_idx_cnt) = noise_idx(noise_idx_cnt);
%                     else
%                         n_conti(1, noise_idx_cnt) = noise_idx(noise_idx_cnt)+1 - noise_idx(noise_idx_cnt-1);
%                     end
%                     n_noise = n_noise-1;
%                     border_value(1, noise_idx_cnt) = rho_roi(noise_idx(noise_idx_cnt));
%                     noise_idx_cnt = noise_idx_cnt + 1;
%                     if n_noise==0
%                         n_conti(1, noise_idx_cnt) = length(y)+1 - noise_idx(noise_idx_cnt-1);
%                     end
%                 end
% 
%                 [~, idx] = max(n_conti);
%                 if (idx-1)~=0
%                     start_idx = noise_idx(idx-1)+1;
%                 else
%                     start_idx = 1;
%                 end
%                 if (idx-1)~= length(noise_idx)
%                     end_idx = noise_idx(idx);
%                 else
%                     end_idx = length(rho_roi);
%                 end
%                 range_min = rho_roi_sort_vec(start_idx);
%                 range_max = rho_roi_sort_vec(end_idx);
% 
%                 %                 disconti = and(object_area, or(rho_roi_<range_min, rho_roi_>range_max));
%                 rho_zero_value = str_next.rho.*object_area_filled;
%                 disconti = and(object_area_filled, or(rho_zero_value<range_min,rho_zero_value>range_max));
%                 input_img(disconti) =0;
%             end

            rho_zero_filled_rho = str_next.rho.*object_area_filled;
            disconti = and(object_area_filled, or(rho_zero_filled_rho<range_min,rho_zero_filled_rho>range_max));
            input_img(disconti) =0;
            score_img(disconti) = 0;
        end

    end
%     if nnz(groundPtsIdx_next_comp)>0
%         input_img(groundPtsIdx_next_comp)=0;
%     end
end