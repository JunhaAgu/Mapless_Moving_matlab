function filled_img = interpAndfill_image(input_img, filled_bin)

target = and(input_img==0, filled_bin);
filled_img = input_img;

[row,col] = find(target>0);
n_target = length(row);

if n_target == 0
    return;
end

for k=1:size(row,1)
    i = row(k);
    j = col(k);
    
    left_dir = 0;
    right_dir = 0;
    up_dir = 0;
    down_dir = 0;

    cnt_left = 1;
    cnt_right = 1;
    cnt_up = 1;
    cnt_down = 1;

    while left_dir==0
        if j-cnt_left<1
            break;
        end
        left_dir = input_img(i,j-cnt_left);
        cnt_left = cnt_left + 1;
    end
    while right_dir==0
        if j+cnt_right>901
            break;
        end
        right_dir = input_img(i,j+cnt_right);
        cnt_right = cnt_right + 1;
    end
    while up_dir==0
        if i-cnt_up<1
            break;
        end
        up_dir = input_img(i-cnt_up,j);
        cnt_up = cnt_up + 1;
    end
    while down_dir==0
        if i+cnt_down>64
            break;
        end
        down_dir = input_img(i+cnt_down,j);
        cnt_down = cnt_down + 1;
    end
    four_dir = [left_dir, right_dir, up_dir, down_dir];
    min_4_dir = min(four_dir);
    filled_img(i,j) = min_4_dir;

end
end