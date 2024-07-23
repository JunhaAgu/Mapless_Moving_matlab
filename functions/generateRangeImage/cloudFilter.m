function [rho_struct, pts_index, pts_n] = cloudFilter(pc, lidar_type, data_type, cur_next)

if lidar_type == "HDL64"
    [ptCloud, rho, ~, pts_index, pts_n] = genRangeImages(pc, data_type, cur_next);
    pts = ptCloud.Location;
end

rho_struct = struct('pts',pts,'rho',rho);

end
