function [cur_warped_rho_new, img_restor_mask] = interpRangeImageMin(rho, n_v, n_h, range_col, range_row)

img_restor_mask   = zeros(n_v, n_h);
cur_warped_rho_new = rho;

for i = range_row %range_row(end):-1:2 %range_row
    for j = range_col
        if rho(i,j) == 0
            if and(rho(i-1,j) ~= 0, rho(i+1,j) ~= 0)
                if abs(rho(i-1,j) - rho(i+1,j) ) < 0.1
                    img_restor_mask(i,j) = 1;
                    cur_warped_rho_new(i,j) = (rho(i-1,j) + rho(i+1,j) ) / 2;
                else
                    img_restor_mask(i,j) = 10; % 1.5;
                    cur_warped_rho_new(i,j) = min( [rho(i-1,j), rho(i+1,j)] );
                end
            elseif and(rho(i-1,j) ~= 0, rho(i+2,j) ~= 0)
                if abs(rho(i-1,j) - rho(i+2,j) ) < 0.1
                    img_restor_mask(i,j) = 2;
                    img_restor_mask(i+1,j) = 3;
                    cur_warped_rho_new(i,j) = rho(i-1,j)*2/3 + rho(i+2,j)*1/3;
                    cur_warped_rho_new(i+1,j) = rho(i-1,j)*1/3 + rho(i+2,j)*2/3;
                else
                    img_restor_mask(i,j) = 20;
                    img_restor_mask(i+1,j) = 30;
                    cur_warped_rho_new(i,j) = min([rho(i-1,j), rho(i+2,j)]);
                    cur_warped_rho_new(i+1,j) = min([rho(i-1,j), rho(i+2,j)]);
                end
            end

            if and(rho(i,j-1) ~= 0, rho(i,j+1) ~= 0)
                if abs(rho(i,j-1) - rho(i,j+1) ) < 0.05
                    img_restor_mask(i,j) = 4;
                    cur_warped_rho_new(i,j) = (rho(i,j-1) + rho(i,j+1) ) / 2;
                end
            elseif and(rho(i,j-1) ~= 0, rho(i,j+2) ~= 0)
                if abs(rho(i,j-1) - rho(i,j+2) ) < 0.05
                    img_restor_mask(i,j) = 5;
                    img_restor_mask(i,j+1) = 6;
                    cur_warped_rho_new(i,j) = rho(i,j-1)*2/3 + rho(i,j+2)*1/3;
                    cur_warped_rho_new(i,j+1) = rho(i,j-1)*1/3 + rho(i,j+2)*2/3;
                end
            end
        end
    end
end

end
