function [input_img, score_img] = fillImageZeroHoles(input_img, score_img, str_next, groundPtsIdx_next_comp, object_threshold, flag_vis)
    n_row = size(input_img, 1);
    n_col = size(input_img, 2);

    input_img_bin = imfill(input_img>0,'holes');
    input_img = interpAndfill_image(input_img, input_img_bin);
    score_img_bin = imfill(score_img>0,'holes');
    score_img = interpAndfill_image(score_img, score_img_bin);

    if flag_vis == true
        figure(100); subplot(8,1,7);
        imagesc(input_img); title('after interpAndfill\_image'); colorbar; colormap hsv;
    end

    rho_zero_value = (str_next.rho==0);

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

            zero_candidate = object_area_filled+2*(input_img_mask);

            if nnz(zero_candidate>2)>0
                connect_zero_mean = mean(input_img(zero_candidate==3));
                input_img(zero_candidate==1) = connect_zero_mean;
                score_img(zero_candidate==1) = 1;
                input_img(groundPtsIdx_next_comp>0) = 0;
                score_img(groundPtsIdx_next_comp>0) = 0;
            end

            rho_roi = str_next.rho.*(input_img_tmp~=0).*object_area_filled;

            %%%
            if isempty(rho_roi(:))
                continue;
            end
            mean_col = zeros(1,n_col);
            for q = 1:n_col
                col_nnz = nnz(rho_roi(:,q));
                if col_nnz ~= 0
                    mean_col(1,q) = sum(rho_roi(:,q))/col_nnz;
                end
            end
            mean_col_map = repmat(mean_col,64,1);
            range_min = mean_col_map - 5;
            range_max = mean_col_map + 5;

            rho_zero_filled_rho = str_next.rho.*object_area_filled;
            disconti = and(object_area_filled, or(rho_zero_filled_rho<range_min,rho_zero_filled_rho>range_max));
            input_img(disconti) =0;
            score_img(disconti) = 0;
        end
    end
end