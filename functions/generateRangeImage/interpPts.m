function [pc, pts_per_pixel_index] = interpPts(xyz, img_rho, img_index, img_restor_mask, pts_per_pixel_rho, pts_per_pixel_index, pts_per_pixel_n, n_ring, n_radial, cur_next)
pc = zeros(n_ring, n_radial, 3);

for i = 1 : n_ring
    for j = 1 : n_radial
        if pts_per_pixel_rho(n_ring*(j-1)+i,1)~=0
            valid_pts_mask = abs( pts_per_pixel_rho(n_ring*(j-1)+i,1:pts_per_pixel_n(64*(j-1)+i,1))-( img_rho(i,j)*ones(1, pts_per_pixel_n(64*(j-1)+i,1) ) ) )<2.0;
            pts_per_pixel_index(n_ring*(j-1)+i,1:pts_per_pixel_n(64*(j-1)+i,1)) = pts_per_pixel_index(n_ring*(j-1)+i,1:pts_per_pixel_n(64*(j-1)+i,1)).*(valid_pts_mask);
        end
        if img_index(i,j) ~= 0
            pc(i ,j , :) = xyz(img_index(i,j),:);
        end

        if img_restor_mask(i,j) == 1
            pc(i ,j, :) = (xyz(img_index(i-1,j),:) + xyz(img_index(i+1,j),:))/2;

        elseif img_restor_mask(i,j) == 10
            if cur_next == 0
                if (img_rho(i-1,j) - img_rho(i+1,j) ) > 0
                    pc(i ,j, :) = xyz(img_index(i+1,j),:);
                else
                    pc(i ,j, :) = xyz(img_index(i-1,j),:);
                end
            else
                if (img_rho(i-1,j) - img_rho(i+1,j) ) < 0
                    pc(i ,j, :) = xyz(img_index(i+1,j),:);
                else
                    pc(i ,j, :) = xyz(img_index(i-1,j),:);
                end
            end

        elseif img_restor_mask(i,j) == 2
            pc(i ,j, :) = xyz(img_index(i-1,j),:)*2/3 + xyz(img_index(i+2,j),:)*1/3;

        elseif img_restor_mask(i,j) == 20
            if cur_next == 0
                if (img_rho(i-1,j) - img_rho(i+2,j) ) > 0
                    pc(i ,j, :) = xyz(img_index(i+2,j),:);
                else
                    pc(i ,j, :) = xyz(img_index(i-1,j),:);
                end
            else
                if (img_rho(i-1,j) - img_rho(i+2,j) ) < 0
                    pc(i ,j, :) = xyz(img_index(i+2,j),:);
                else
                    pc(i ,j, :) = xyz(img_index(i-1,j),:);
                end
            end

        elseif img_restor_mask(i,j) == 3
            pc(i ,j, :) = xyz(img_index(i-2,j),:)*1/3 + xyz(img_index(i+1,j),:)*2/3;

        elseif img_restor_mask(i,j) == 30
            if cur_next == 0
                if (img_rho(i-2,j) - img_rho(i+1,j) ) > 0
                    pc(i ,j, :) = xyz(img_index(i+1,j),:);
                else
                    pc(i ,j, :) = xyz(img_index(i-2,j),:);
                end
            else
                if (img_rho(i-2,j) - img_rho(i+1,j) ) < 0
                    pc(i ,j, :) = xyz(img_index(i+1,j),:);
                else
                    pc(i ,j, :) = xyz(img_index(i-2,j),:);
                end
            end

        elseif img_restor_mask(i,j) == 4
            pc(i ,j, :) = (xyz(img_index(i,j-1),:) + xyz(img_index(i,j+1),:))/2;

        elseif img_restor_mask(i,j) == 5
            pc(i ,j, :) = xyz(img_index(i,j-1),:)*2/3 + xyz(img_index(i,j+2),:)*1/3;

        elseif img_restor_mask(i,j) == 6
            pc(i ,j, :) = xyz(img_index(i,j-2),:)*1/3 + xyz(img_index(i,j+1),:)*2/3;

        end
    end
end

pc = pointCloud(pc);
end
