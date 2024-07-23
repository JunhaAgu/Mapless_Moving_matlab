function [img_rho, img_restor_mask] = interpRangeImage(img_rho, n_ring, n_radial, cur_next)

img_restor_mask   = zeros(n_ring,n_radial);
img_rho_new = img_rho;
% for i = 3:n_ring-2
for i = 36:-1:24 %24: 36 %36:-1:24 %24:36
% for i = 20:40 %24: 36 %36:-1:24 %24:36
    for j = 1+2: n_radial-2
        if img_rho(i,j) == 0
            if and(img_rho(i-1,j) ~= 0, img_rho(i+1,j) ~= 0)
                if abs(img_rho(i-1,j) - img_rho(i+1,j) ) < 0.1
                    img_restor_mask(i,j) = 1;
                    img_rho_new(i,j) = (img_rho(i-1,j) + img_rho(i+1,j) ) / 2;
                else
                    img_restor_mask(i,j) = 10;
                    if cur_next == 0
                        img_rho_new(i,j) = min( [img_rho(i-1,j), img_rho(i+1,j)] );
                    else
                        img_rho_new(i,j) = max( [img_rho(i-1,j), img_rho(i+1,j)] );
                    end
                end
            elseif and(img_rho(i-1,j) ~= 0, img_rho(i+2,j) ~= 0)
                if abs(img_rho(i-1,j) - img_rho(i+2,j) ) < 0.1
                    img_restor_mask(i,j) = 2;
                    img_restor_mask(i+1,j) = 3;
                    img_rho_new(i,j) = img_rho(i-1,j)*2/3 + img_rho(i+2,j)*1/3;
                    img_rho_new(i+1,j) = img_rho(i-1,j)*1/3 + img_rho(i+2,j)*2/3;
                else
                    img_restor_mask(i,j) = 20;
                    img_restor_mask(i+1,j) = 30;
                    if cur_next == 0
                        img_rho_new(i,j) = min([img_rho(i-1,j), img_rho(i+2,j)]);
                        img_rho_new(i+1,j) = min([img_rho(i-1,j), img_rho(i+2,j)]);
                    else
                        img_rho_new(i,j) = max([img_rho(i-1,j), img_rho(i+2,j)]);
                        img_rho_new(i+1,j) = max([img_rho(i-1,j), img_rho(i+2,j)]);
                    end
                end
            end
        end

        if and(img_rho(i,j-1) ~= 0, img_rho(i,j+1) ~= 0)
            if abs(img_rho(i,j-1) - img_rho(i,j+1) ) < 0.05
                img_restor_mask(i,j) = 4;
                img_rho_new(i,j) = (img_rho(i,j-1) + img_rho(i,j+1) ) / 2;
            end
        elseif and(img_rho(i,j-1) ~= 0, img_rho(i,j+2) ~= 0)
            if abs(img_rho(i,j-1) - img_rho(i,j+2) ) < 0.05
                img_restor_mask(i,j) = 5;
                img_restor_mask(i,j+1) = 6;
                img_rho_new(i,j) = img_rho(i,j-1)*2/3 + img_rho(i,j+2)*1/3;
                img_rho_new(i,j+1) = img_rho(i,j-1)*1/3 + img_rho(i,j+2)*2/3;
            end
        end

    end
end

img_rho = img_rho_new;

end