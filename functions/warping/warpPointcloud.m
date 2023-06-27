function [IR1] = warpPointcloud(IRef, DRef, I1, T_gt_, data_type)

velo_x = DRef.pts(:,:,1).*(I1~=0);
velo_y = DRef.pts(:,:,2).*(I1~=0);
velo_z = DRef.pts(:,:,3).*(I1~=0);
velo_xyz = [velo_x(:)' ; velo_y(:)' ; velo_z(:)'];
velo_xyz(:, and(velo_xyz(1,:)==0,velo_xyz(2,:)==0) ) = [];

%% find corresponding pixels after warping
pts_warped = T_gt_*[velo_xyz ; ones(1,size(velo_xyz,2))]; %T_gt_ : T_(i+1)(i)
[~, ~, idx_valid] = generateRangeImage(pts_warped(1:3,:)', "HDL64", data_type);

DRef_mask = and(DRef.rho, I1);

valid_mask = DRef_mask(:);
valid_mask_vec = valid_mask;
valid_mask(valid_mask==0) = [];

if isempty(valid_mask)
    IR1 = zeros(size(DRef.rho));
    return;
end

I_vec1 = I1(:);
I_vec1(valid_mask_vec==0) = [];


index_vec = idx_valid(:);
IR1_vec = zeros(size(valid_mask_vec));

if ~isempty(I_vec1)
    IR1_vec(index_vec>0) = I_vec1(index_vec(index_vec>0));
end


IR1 = reshape(IR1_vec,size(IRef.rho));

end

