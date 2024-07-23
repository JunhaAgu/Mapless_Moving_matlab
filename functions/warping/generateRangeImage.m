function [ptCloud, rho_struct, index] = generateRangeImage(pc, type, data_type)

if type == "HDL64"
    [ptCloud, rho, index] = genRangeImages(pc, data_type, 0);
end

rho_struct = struct('pts',ptCloud.Location,'rho',rho);

end