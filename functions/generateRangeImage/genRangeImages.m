function [pc, img_rho, img_index, pts_per_pixel_index, pts_per_pixel_n] = genRangeImages(xyz, data_type, cur_next)

h_factor = 5;
v_factor = 1;
azimuth_res = 0.08*h_factor;

% generate range images
az_step = 1/azimuth_res; % 0.08 degrees step.
n_radial = 360*az_step+1;
n_ring = 64/v_factor;
n_pts = size(xyz,1);

%% vertical angle resolusion for KITTI or CARLA
if data_type== "KITTI"
    top = linspace(2.5, -8.0, 32/v_factor); % 2 -8.5
    bottom = linspace(-8.50, -23.8, 32/v_factor); % -8.87 -24.87
    v_angle = [top, bottom];
elseif data_type == "CARLA"
    v_angle = linspace(2, -24.8, 64);
end

%% calculate rho, phi, theta
[rho, phi, theta] = calculateRho(xyz);

%% make range image and Pts per pixel
[img_rho, img_index, pts_per_pixel_rho, pts_per_pixel_index, pts_per_pixel_n]=...
    makeRangeImageAndPtsPerPixel(rho, phi, theta, n_pts, v_angle, n_ring, n_radial, az_step);

%% fill range image using interpolation
[img_rho, img_restor_mask] = interpRangeImage(img_rho, n_ring, n_radial, cur_next);

%% fill pts corresponding to filled range image (no affect the original pts) 
[pc, pts_per_pixel_index] = interpPts(xyz, img_rho, img_index, img_restor_mask, pts_per_pixel_rho, pts_per_pixel_index, pts_per_pixel_n, n_ring, n_radial, cur_next);
end