function[img_rho, img_index, pts_per_pixel_rho, pts_per_pixel_index, pts_per_pixel_n]=...
    makeRangeImageAndPtsPerPixel(rho, phi, theta, n_pts, v_angle, n_ring, n_radial, az_step)

R2D = 180/pi;

img_rho     = zeros(n_ring,n_radial);
img_index   = zeros(n_ring,n_radial);

pts_per_pixel_index = zeros(n_ring*(n_radial),50);
pts_per_pixel_rho = zeros(n_ring*(n_radial),50);
pts_per_pixel_n = zeros(n_ring*(n_radial),1);

i_row_b = zeros(n_pts,1);
i_col_b = zeros(n_pts,1);

for i = 1:n_pts
    for kk=1:n_ring
        if v_angle(1,kk) < phi(i)*R2D
            i_row = kk;
            break;
        end
        if kk==n_ring
            i_row = n_ring;
        end
    end
    i_col = round(theta(i)*az_step*R2D)+1;

    i_row_b(i,1) = i_row;
    i_col_b(i,1) = i_col;

    if or(i_row > n_ring, i_row < 1)
        continue;
    end

    if img_rho(i_row,i_col) == 0
        img_rho(i_row,i_col) = rho(i);
        img_index(i_row,i_col) = i;
    elseif img_rho(i_row,i_col) > rho(i)
        img_rho(i_row,i_col) = rho(i);
        img_index(i_row,i_col) = i;
    end
    pts_per_pixel_n(64*(i_col-1)+i_row,1) = pts_per_pixel_n(64*(i_col-1)+i_row,1) + 1;
    pts_per_pixel_index(64*(i_col-1)+i_row, pts_per_pixel_n(64*(i_col-1)+i_row,1) ) = i;
    pts_per_pixel_rho(64*(i_col-1)+i_row, pts_per_pixel_n(64*(i_col-1)+i_row,1) ) = rho(i);
end


end