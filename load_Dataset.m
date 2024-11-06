%% make video
if video_flag == true
    framerate = 10;
    vid_image = VideoWriter('KITTI_05_241105.avi');
    vid_image.FrameRate = framerate;
    open(vid_image);
end

%% load dataset
if data_type == "KITTI"
    dataset_dir = 'E:/KITTI_odometry';
    data_num    = '05';
elseif data_type == "CARLA"
    dataset_dir = 'F:/mapless_dataset/CARLA';
    data_num    = '03';
end

if data_type == "KITTI"
    switch data_num
        case '00'
            start = 4390+1; final = 4530+1+1; % 1 ~ 141+2
        case '01'
            start = 150+1;  final = 250+1+1;  % 1 ~ 101+2
        case '02'
            start = 860+1;  final = 950+1+1;  % 1 ~ 91+2
        case '05'
            start = 2350+1; final = 2670+1+1; % 1 ~ 321+2
        case '07'
            start = 630+1; final = 820+1+1; % 1 ~ 190+2
    end
elseif data_type == "CARLA"
    switch data_num
        case '01'
            start = 10+1+2; final = 370+1+1; % 1 ~ 141+2
        case '01_001'
            start = 10+1+2; final = 370+1+1; % 1 ~ 141+2
        case '01_002'
            start = 10+1+2; final = 370+1+1; % 1 ~ 141+2
        case '03'
            start = 10+1+2;  final = 400+1+1;  % 1 ~ 101+2
        case '03_001'
            start = 10+1+2;  final = 400+1+1;  % 1 ~ 101+2
        case '03_002'
            start = 10+1+2;  final = 400+1+1;  % 1 ~ 101+2
    end
end

valid_data = start:1:final;

%% Ground Truth(oxts)
if data_type == "KITTI"
    pose_gt = importdata([dataset_dir,'/data_odometry_poses/dataset/poses/',data_num,'.txt']);
elseif data_type == "CARLA"
    pose_gt_temp = importdata([dataset_dir,'/sequences/',data_num,'/poses.txt']);
    pose_gt = pose_gt_temp(:,1:12);
end

n_data  = length(valid_data);

T_gt = cell(1,n_data);
t_gt = zeros(3,n_data);
R_gt = cell(1,n_data);
for ii = 1:n_data
    i = valid_data(1,ii);
    T_tmp = [pose_gt(i,1:4);pose_gt(i,5:8);pose_gt(i,9:12);0,0,0,1];
    if data_type == "KITTI"
        T_gt{1,ii} = T_tmp*[0 -1 0 0; 0 0 -1 0; 1 0 0 0; 0 0 0 1]; % KITTI
    elseif data_type == "CARLA"
        T_gt{1,ii} = T_tmp;
    end
    t_gt(:,ii) = T_gt{1,ii}(1:3,4);
    R_gt{1,ii} = T_gt{1,ii}(1:3,1:3);
end

T_gt_ = cell(1,n_data); %T_(i-1)(i)
for i=1:n_data
    if i==1
        T_gt_{1,i} = inv(T_gt{1,i})*T_gt{1,i};
    else
        T_gt_{1,i} = inv(T_gt{1,i-1})*T_gt{1,i};
    end
end

%% load velodyne points
velo = cell(n_data,1);

if data_type == "KITTI"
    for ii=1:n_data
        i = valid_data(1,ii);
        fid = fopen(sprintf('%s/data_odometry_velodyne/dataset/sequences/%s/velodyne/%06d.bin',dataset_dir,data_num,i-1),'rb');
        velo{ii,1} = fread(fid,[4 inf],'single')';
        velo{ii,1} = velo{ii,1}(1:1:end,:); % remove points for display speed
        fclose(fid);
    end
elseif data_type == "CARLA"
    for ii=1:n_data
        i = valid_data(1,ii);
        fid = fopen(sprintf('%s/sequences/%s/velodyne/%06d.bin',dataset_dir,data_num,i-1));
        velo{ii,1} = fread(fid,[4 inf],'single')';
        velo{ii,1} = velo{ii,1}(1:1:end,1:4);
        fclose(fid);
    end
end

% velo_0k = cell(n_data,1);
% for i=1:n_data
%     velo_0k{i,1} = (T_gt{i}*[velo{i,1}(:,1:3) ones(length(velo{i,1}),1)]')';
% end