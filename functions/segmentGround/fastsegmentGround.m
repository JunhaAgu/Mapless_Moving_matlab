function groundPtsIdx_next = fastsegmentGround(str_next)

rho = str_next.rho;
pts = str_next.pts;
downsample_size = 10;
n_row = size(rho,1);
n_col = size(rho,2);
n_col_sample = round(n_col/downsample_size);

pts_z_sample = zeros(n_row, n_col_sample);
rho_sample   = zeros(n_row, n_col_sample);

%% down-sampling

for i=1:n_row
    for j=1:n_col_sample
        col_range = (j-1)*(downsample_size)+1:(j-1)*(downsample_size)+1+(downsample_size)-1;
        pts_z_col_range = pts(i,col_range,3);
        [~, zero_idx] = find(pts_z_col_range == 0);
        if length(zero_idx) == length(col_range)
            continue;
        end
        if ~isempty(zero_idx)
            pts_z_col_range(zero_idx) = 1e2;
        end
        [min_z,min_idx] = min(pts_z_col_range);
%         if min_z == 0
%             continue;
%         end
        pts_z_sample(i,j) = min_z;
        rho_sample(i,j) = rho(i,col_range(1)+min_idx-1);
    end
end

line_cell = cell(1, n_col_sample);
inliers_cell = cell(1, n_col_sample);
mask_inlier_cell = cell(1, n_col_sample);
mask_inlier_mat = zeros(n_row, n_col_sample);

paramRANSAC.iter = 25;
paramRANSAC.thr = 0.1;
paramRANSAC.a_thr = 0.1; %abs
paramRANSAC.b_thr = [-0.5, -1.2]; %under
paramRANSAC.min_inlier = 5; %minimum # of inliers

for i=1:n_col_sample %[31 54 55 56 57 59 60 61 62 63 64 65 66 67 68 69 70 71 73 74 75 76 77 78 79] %1:n_col_sample
    points(:,1) = rho_sample(:,i);
    points(:,2) = pts_z_sample(:,i);
%     fprintf("%d: ",i);
    [line, inliers, mask_inlier] = ransacLine_ver2(points, paramRANSAC, i);
%     fprintf("\n");
    line_cell{1,i} = line;
    inliers_cell{1,i} = inliers;
    mask_inlier_cell{1,i} = mask_inlier;
    mask_inlier_mat(:,i) = mask_inlier';
end


%% up-sampling: sample size -> original image size

groundPtsIdx_next = zeros(size(rho));

thr_distance = 0.2;
thr_z = 3.0;

for i=1:n_row
    for j=1:n_col_sample
        if (mask_inlier_mat(i,j)==1)
            rep_z_value = pts_z_sample(i,j);
            if rep_z_value==0
                continue;
            end
            col_range = (j-1)*(downsample_size)+1:(j-1)*(downsample_size)+1+(downsample_size)-1;
            bin_z = pts(i,col_range,3);

            bin_rho = rho(i,col_range);
            
            for k=1:downsample_size
                residual_leastsquare(1,k) = abs( line_cell{1,j}(1,1)*bin_rho(1,k) + (-1)*bin_z(1,k) + line_cell{1,j}(1,2) ) /...
                    sqrt(line_cell{1,j}(1,1)^2+1^2)  ;

                updown(1,k) = line_cell{1,j}(1,1)*bin_rho(1,k) + (-1)*bin_z(1,k) + line_cell{1,j}(1,2) ;
            end

            bin_ground_mask = and( bin_z~=0, residual_leastsquare < thr_distance);
            
            bin_ground_mask = or(bin_ground_mask, and(updown>0,updown<thr_z));

            groundPtsIdx_next(i, col_range) = bin_ground_mask;
        end
    end
end

end