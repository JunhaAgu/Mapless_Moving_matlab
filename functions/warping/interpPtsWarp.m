function pts = interpPtsWarp(str_cur_warped, img_restor_mask, range_col, range_row)
pts = str_cur_warped.pts;
rho = str_cur_warped.rho;
for i = range_row
    for j = range_col

        if img_restor_mask(i,j) == 1
            pts(i ,j, :) = (pts(i-1,j,:) + pts(i+1,j,:))/2;
        elseif img_restor_mask(i,j) == 10 %1.5
            if (rho(i-1,j) - rho(i+1,j)) < 0
                pts(i ,j, :) = pts(i-1,j,:);
            else
                pts(i ,j, :) = pts(i+1,j,:);
            end
        elseif img_restor_mask(i,j) == 2
            pts(i ,j, :) = pts(i-1,j,:)*2/3 + pts(i+2,j,:)*1/3;
        elseif img_restor_mask(i,j) == 20
            if (rho(i-1,j) - rho(i+2,j)) < 0
                pts(i ,j, :) = pts(i-1,j,:);
            else
                pts(i ,j, :) = pts(i+2,j,:);
            end
        elseif img_restor_mask(i,j) == 3
            pts(i ,j, :) = pts(i-2,j,:)*1/3 + pts(i+1,j,:)*2/3;
        elseif img_restor_mask(i,j) == 30
            if (rho(i-2,j) - rho(i+1,j)) < 0
                pts(i ,j, :) = pts(i-2,j,:);
            else
                pts(i ,j, :) = pts(i+1,j,:);
            end

        elseif img_restor_mask(i,j) == 4
            pts(i ,j, :) = (pts(i,j-1,:) + pts(i,j+1,:))/2;
        elseif img_restor_mask(i,j) == 5
            pts(i ,j, :) = pts(i,j-1,:)*2/3 + pts(i,j+2,:)*1/3;
        elseif img_restor_mask(i,j) == 6
            pts(i ,j, :) = pts(i,j-2,:)*1/3 + pts(i,j+1,:)*2/3;
        end
    end
end

end
