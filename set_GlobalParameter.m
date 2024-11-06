%% Global parameter setting
height = 64/1;
width = 4500/5+1;
alpha = 0.3;
beta = 0.1;
coef_accum_w = [0.5, 0.9];
object_threshold = 40;
score_cnt = 0;

data_type = "KITTI";
% data_type = "CARLA";

% flag_vis = true;
flag_vis = false;

video_flag = true;
% video_flag = false;

%% figure window setting
if flag_vis == 1
    f1 = figure(1); f1.Position = [10 50 900 500];
    f2 = figure(2); f2.Position = [1010 50 900 500];
    f100 = figure(100); f100.Position = [10 50 900 900];
    f200 = figure(200); f200.Position = [1010 500 900 500];
end
    f201 = figure(201); f201.Position = [500 100 900 700];
    f301 = figure(301); f301.Position = [500 100 900 700];
%% visualization color setting
color_y = [1 1 0]; color_y_3(1,1,1) = 1; color_y_3(1,1,2) = 1; color_y_3(1,1,3) = 0;
color_m = [1 0 1]; color_m_3(1,1,1) = 1; color_m_3(1,1,2) = 0; color_m_3(1,1,3) = 1;
color_c = [0 1 1]; color_c_3(1,1,1) = 0; color_c_3(1,1,2) = 1; color_c_3(1,1,3) = 1;
color_r = [1 0 0]; color_r_3(1,1,1) = 1; color_r_3(1,1,2) = 0; color_r_3(1,1,3) = 0;
color_g = [0 1 0]; color_g_3(1,1,1) = 0; color_g_3(1,1,2) = 1; color_g_3(1,1,3) = 0;
color_b = [0 0 1]; color_b_3(1,1,1) = 0; color_b_3(1,1,2) = 0; color_b_3(1,1,3) = 1;
color_w = [1 1 1]; color_w_3(1,1,1) = 1; color_w_3(1,1,2) = 1; color_w_3(1,1,3) = 1;
color_k = [0 0 0]; color_k_3(1,1,1) = 0; color_k_3(1,1,2) = 0; color_k_3(1,1,3) = 0;