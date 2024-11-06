function [accumulated_dRdt_update] = checkSegment(accumulated_dRdt, rho_next, groundPtsIdx_next_comp)

weight_factor = 0.95;
seg_deg = 5;

accumulated_dRdt_update = accumulated_dRdt;

D2R = pi/180;

roi = accumulated_dRdt~=0;

if nnz(roi)==0
    return;
end

n_row = size(roi,1);
n_col = size(roi,2);
roi_up = roi;

[idx_row,idx_col] = find(roi>0);
check = zeros(length(idx_row),1);

azimuth_res = 360/n_col;
cnt=1;
while(1)

    if check(cnt)==0
        row = idx_row(cnt);
        col = idx_col(cnt);
        R = rho_next.rho(row, col);
        for idx_cw=[1,2,3,4]
            if idx_cw ==1
                i = row-1; j = col;
            elseif idx_cw == 2
                i = row; j = col+1;
            elseif idx_cw == 3
                i = row+1; j = col;
            elseif idx_cw == 4
                i = row; j = col-1;
            end

            if or(i<1, i>n_row)
                continue;
            end
            if or(j<1, j>n_col)
                continue;
            end
            if and(roi_up(i,j)==0, rho_next.rho(i,j)>0)
                if groundPtsIdx_next_comp(i,j)==1
                    continue;
                end
                d1 = max( R, rho_next.rho(i,j) );
                d2 = min( R, rho_next.rho(i,j) );
                if atan2( d2*sin(azimuth_res*D2R), (d1-d2*cos(azimuth_res*D2R)) ) > seg_deg*D2R
                    idx_row = [idx_row ; i];
                    idx_col = [idx_col ; j];
                    check = [check ; 0];
                    roi_up(i,j) = 1;
                    accumulated_dRdt_update(i,j) = weight_factor*accumulated_dRdt_update(row,col);
                end
            elseif and(roi_up(i,j)==0, rho_next.rho(i,j)==0)
                if groundPtsIdx_next_comp(i,j)==1
                    continue;
                end

                if idx_cw ==1
                    ii = row-2; jj = col;
                elseif idx_cw == 2
                    ii = row; jj = col+2;
                elseif idx_cw == 3
                    ii = row+2; jj = col;
                elseif idx_cw == 4
                    ii = row; jj = col-2;
                end
                if or(ii<1, ii>n_row)
                    continue;
                end
                if or(jj<1, jj>n_col)
                    continue;
                end

                if groundPtsIdx_next_comp(ii,jj)==1
                    continue;
                end

                if roi_up(ii,jj) == 1
                else
                    d1 = max( R, rho_next.rho(ii,jj) );
                    d2 = min( R, rho_next.rho(ii,jj) );
                    if atan2( d2*sin(2*azimuth_res*D2R), (d1-d2*cos(2*azimuth_res*D2R)) ) > seg_deg*D2R
                        idx_row = [idx_row ; ii];
                        idx_col = [idx_col ; jj];

                        check = [check ; 0];
                        roi_up(ii,jj) = 1;
                        accumulated_dRdt_update(ii,jj) = weight_factor*accumulated_dRdt_update(row,col);
                        if idx_cw ==1
                            accumulated_dRdt_update(ii+1,jj) = weight_factor*accumulated_dRdt_update(row,col);
                        elseif idx_cw == 2
                            accumulated_dRdt_update(ii,jj-1) = weight_factor*accumulated_dRdt_update(row,col);
                        elseif idx_cw == 3
                            accumulated_dRdt_update(ii-1,jj) = weight_factor*accumulated_dRdt_update(row,col);
                        elseif idx_cw == 4
                            accumulated_dRdt_update(ii,jj+1) = weight_factor*accumulated_dRdt_update(row,col);
                        end
                    end
                end
            end
        end

        if groundPtsIdx_next_comp(row,col)==1
            roi_up(row,col) = 0;
        end

        check(cnt) = 1;
    end
    cnt = cnt + 1;
    if nnz(check) == length(check)
        break;
    end
end

end

