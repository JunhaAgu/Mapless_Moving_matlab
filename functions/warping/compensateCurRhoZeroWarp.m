function new_pts = compensateCurRhoZeroWarp(s_cur, n_v, n_h, v_angle)

rho_zero = s_cur.rho==0;
new_DRef_rho = s_cur.rho;
new_pts = [];
min_rho_4_dir_total = [];

for i=1+1:n_v-1
    for j=1+1:n_h-1
        left_dir_rho = 0;
        right_dir_rho = 0;
        up_dir_rho = 0;
        down_dir_rho = 0;
                                                                    
        if rho_zero(i,j)>0
            cnt_left = 1;
            cnt_right = 1;
            cnt_up = 1;
            cnt_down = 1;

            while left_dir_rho==0
                if j-cnt_left<1
                    break;
                end
                left_dir_rho = s_cur.rho(i,j-cnt_left);
                cnt_left = cnt_left + 1;
            end
            while right_dir_rho==0
                if j+cnt_right>901
                    break;
                end
                right_dir_rho = s_cur.rho(i,j+cnt_right);
                cnt_right = cnt_right + 1;
            end
            while up_dir_rho==0
                if i-cnt_up<1
                    break;
                end
                up_dir_rho = s_cur.rho(i-cnt_up,j);
                cnt_up = cnt_up + 1;
            end
            while down_dir_rho==0
                if i+cnt_down>64
                    break;
                end
                down_dir_rho = s_cur.rho(i+cnt_down,j);
                cnt_down = cnt_down + 1;
            end
            four_dir = [left_dir_rho, right_dir_rho, up_dir_rho, down_dir_rho];
            four_cnt = [cnt_left, cnt_right, cnt_up, cnt_down];
            valid_dir = and(and(four_dir~=0, four_cnt<20),four_dir<100);
            if sum(valid_dir)<1
                continue;
            end
            dir_tmp = four_dir(valid_dir);
            min_dir = min(dir_tmp);
            valid_dir = and(valid_dir, four_dir<(min_dir+1.0)); % 2.0 possible

            if sum(valid_dir)<1
                continue;
            elseif sum(valid_dir)==1
                min_rho_4_dir = min_dir;
            else
                inv_left = 1/cnt_left;
                inv_right = 1/cnt_right;
                inv_up = 1/cnt_up;
                inv_down = 1/cnt_down;
                vec_inv = [inv_left, inv_right, inv_up, inv_down];
                vec_inv = vec_inv.*valid_dir;
                vec_inv = vec_inv/sum(vec_inv);

                min_rho_4_dir = (left_dir_rho*vec_inv(1) + right_dir_rho*vec_inv(2) + up_dir_rho*vec_inv(3) + down_dir_rho*vec_inv(4));
            end
            min_rho_4_dir_total = [min_rho_4_dir_total min_rho_4_dir];
%             disp(min_rho_4_dir);
            
            if ~isempty(min_rho_4_dir)
                new_DRef_rho(i,j) = min_rho_4_dir;

                new_phi = v_angle(i)*pi/180;
                new_theta = 0.4 * j *pi/180;

                for m=1:5
                    for p=1:5
                        new_x(1,5*(m-1)+p) = -min_rho_4_dir*cos(new_phi+(m-3)*0.2*pi/180)*cos(new_theta+(p-3)*0.08*pi/180);
                        new_y(1,5*(m-1)+p) = -min_rho_4_dir*cos(new_phi+(m-3)*0.2*pi/180)*sin(new_theta+(p-3)*0.08*pi/180);
                        new_z(1,5*(m-1)+p) = min_rho_4_dir*sin(new_phi+(m-3)*0.2*pi/180);
                    end
                end

                new_pts = [new_pts, [new_x; new_y; new_z]];
            end
        end
    end
end

end