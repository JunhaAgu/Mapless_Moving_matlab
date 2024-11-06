function accumulated_dRdt = extractObjectCandidate(accumulated_dRdt, str_next, object_threshold, flag_vis)

    object_mask = accumulated_dRdt > 0;

    % next_zeros = str_next.rho==0;
    % 
    % object_mask_tr = [zeros(1,size(next_zeros,2)) ; object_mask(1:end-1,:)];
    % 
    % object_zeros_sum_mask = and(object_mask_tr, next_zeros);
    % 
    % [object_label_z, n_label_z] = bwlabel(next_zeros);
    % for object_idx_z = 1:n_label_z
    %     object_area_z = (object_label_z == object_idx_z);
    %     if nnz(object_area_z.*object_zeros_sum_mask)<10
    %         next_zeros(object_area_z)=0;
    %     end
    % end
    % 
    % object_zero_mask = or(object_mask, next_zeros);

    % Label objects in 2D image
    [object_label, n_label] = bwlabel(object_mask);
    sum_object = zeros(1, n_label);
    valid_num =  zeros(1, n_label);
    for object_idx = 1:n_label
        object_area = (object_label == object_idx);
        sum_object(object_idx) = sum(sum(object_area));
        if(sum_object(object_idx) < object_threshold)
            % Ignore small object segmentations
            accumulated_dRdt(object_area)=0;
            continue;
        else
            rho_roi = str_next.rho.*object_area;
            rho_roi_ = rho_roi;
            rho_roi(rho_roi==0)=[];
            [N_hist,edges_hist] = histcounts(rho_roi(:),50);
            max_idx = find(N_hist==max(N_hist),1);
            if edges_hist(max_idx) - 1.0<0
                range_min = edges_hist(max_idx);
            else
                range_min = edges_hist(max_idx) - 0.8;
            end
            range_max = edges_hist(max_idx+1) + 1.0;
                
            fprintf("#: %d, range_min: %f, range_max: %f\n",sum_object(object_idx), range_min, range_max);

            disconti = and(object_area, or(rho_roi_<range_min, rho_roi_>range_max));

            %%%check via object_thr
            if nnz(object_area) - nnz(disconti) < object_threshold
                accumulated_dRdt(object_area) = 0;
            else
                accumulated_dRdt(disconti) =0;
            end

            diff_object_area_conti = object_area-disconti;
            diff_z = str_next.pts(:,:,3).*diff_object_area_conti;
            vec_diff_z = diff_z(diff_z~=0);
            mean_diff_z = mean(vec_diff_z);
            std_diff_z = sqrt( 1/(length(vec_diff_z)-1)*sum( (vec_diff_z-mean_diff_z*ones(size(vec_diff_z))).^2 ) );
            fprintf('object_idx: %d / std: %f\n',object_idx,std_diff_z);
            if std_diff_z < 9
                accumulated_dRdt(object_area) = 0;
            end

            valid_num(object_idx) = object_idx;
        end
    end
    valid_num(valid_num==0) = [];

    if flag_vis == true
        figure(100); subplot(8,1,5); imagesc(accumulated_dRdt); title('after binary\_connection'); colorbar; colormap hsv;
    end

end