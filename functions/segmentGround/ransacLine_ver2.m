function [line, inliers, mask_inlier] = ransacLine_ver2(points, param, segment_number)
% written by JunhaKim
%%%%% input %%%%%
% points      : 2D points, size     -> 2 x N
% param -> iter, thr, a_thr, b_thr, min_inlier 
% iter        : maximum iteration   -> scalar
% thr         : distance threshold  -> scalar
% a_thr       : line coefficient, a -> scalar
% b_thr       : line coefficient, b -> scalar
% mini_inlier : XX% of points       -> scalar

%%%%% output %%%%%
% line        : line coefficient    -> 1 X 2 (a, b)
% inliers     : 2D points           -> 2 X M (M<=N)
% mask_inlier : mask of inliers     -> 1 X N

if size(points,1)>2
    points=points'; %2 X N
end

points_dup = points;

points_sort = zeros(2,100);
valid_points_idx= [];

for i=1:100
    if i<81
        mask_temp = and(points(1,:)>(0.5*(i-1)), points(1,:)<(0.5*i));
        kk = i;
    else
        mask_temp = and(points(1,:)>40+2*(i-kk-1), points(1,:)<40+2*(i-kk-1)+2);
    end
    if nnz(mask_temp)~=0
        points_sort_temp = points(:,mask_temp);
        [min_z,min_idx] = min(points_sort_temp(2,:));
        if min_z>-1.2
            continue;
        end
        [~,idx_non_zero_mask_temp] = find(mask_temp~=0);
        valid_points_idx = [valid_points_idx, idx_non_zero_mask_temp(min_idx)];
        points_sort(:,i) = points_sort_temp(:,min_idx);
    else
    end
end

non_zero_points_mask = false(1,size(points,2));
non_zero_points_mask(valid_points_idx) = true;
mask_inlier = false(size(non_zero_points_mask));
points_valid = points(:,valid_points_idx);

if (size(points_valid,2)<2)
    line = [];
    inliers = [];
    fprintf("Seg: %d -- no valid points\n", segment_number);
    return;
end

iter = param.iter;
thr = param.thr;
a_thr = param.a_thr; %abs
b_thr = param.b_thr; %under
mini_inlier = param.min_inlier;

n_sample=2; %2 points for one line
n_pts_valid=length(points_valid); % #_points
id_good_fit = zeros(iter, 1);

ini_inlier      = zeros(iter,n_pts_valid);       % iter x #_points
mask            = zeros(iter,n_pts_valid);       % iter x #_points
residual        = zeros(iter,n_pts_valid);       % iter x #_points
inlier_cnt      = zeros(iter,1);

inlier = cell(iter,1);
AB     = zeros(2,iter);

for m=1:iter
    inlier_cnt(m,1)=1;
    
    % draw two points randomly
    while(1)
        k = floor(n_pts_valid*rand(n_sample,1))+1; % +1
        n1=k(1,1);
        n2=k(2,1);
        if n1~=n2
            break;
        end
    end
    
    % calc line
    x1 = points_valid(1,n1);
    y1 = points_valid(2,n1);
    x2 = points_valid(1,n2);
    y2 = points_valid(2,n2);
    AB(1,m) = (y2-y1)/(x2-x1);
    AB(2,m) = -AB(1,m)*x1+y1;
    if AB(1,m) < 0
        if AB(1,m) < -a_thr || AB(2,m) > b_thr(1)
            continue;
        end
    end

    if AB(1,m) > 0
        if AB(1,m) > a_thr || AB(2,m) > b_thr(1)
            continue;
        end
    end

    % inlier?
    for i=1:n_pts_valid
        residual(m,i) = abs( AB(1,m)*points_valid(1,i) - points_valid(2,i) + AB(2,m) ) /...
            sqrt(AB(1,m)^2+1)  ;
        if residual(m,i) < thr
            ini_inlier(m,i)=1;
            mask(m,i) = 1;
        end
    end
    
    for j=1:n_pts_valid
        if ini_inlier(m,j)==1
            inlier{m,1}(:, inlier_cnt(m,1))=[points_valid(1,j) , points_valid(2,j)]';
            inlier_cnt(m,1) = inlier_cnt(m,1) + 1;
        end
    end
    
    if ( inlier_cnt(m,1) - 1 ) > mini_inlier
        id_good_fit(m,1)=1;
    end
end

max_cnt_index=find(inlier_cnt==max(inlier_cnt));

mini_pre = 1e3;

if isempty(max_cnt_index)
    figure();
    plot(points_dup(1,:), points_dup(2,:), 'ro'); hold on;
    axis equal;
    legend('nonZeroPts');
    title(['segment\_number: ', num2str(segment_number)])
    return;
end

% select among candidates
if length(max_cnt_index)>1
    n_candi=length(max_cnt_index);
    for i_candi=1:n_candi
        mini=min( mean(residual(max_cnt_index(i_candi,1),:),2), mini_pre );
        if mini<mini_pre
            id_mini=i_candi;
        end
        mini_pre=mini;
    end
    max_cnt_index=max_cnt_index(id_mini,1);
else
    max_cnt_index=max_cnt_index(1,1);
end

best_n_inlier=inlier_cnt(max_cnt_index,1)-1;
% fprintf('          The %d-th has inlier the most (Its number is %d)          \n',max_cnt , best_n_inlier);
if (best_n_inlier < 3)
    fprintf("%d: inlier pts < 3\n",segment_number);
end
if (best_n_inlier == 0)
    fprintf("# of inlier pts = 0\n");
end
%least square
A = zeros(best_n_inlier,3);
for i=1:best_n_inlier
    A(i,:)=[inlier{max_cnt_index,1}(1,i) , inlier{max_cnt_index,1}(2,i), 1];
end 

[~,~,V]=svd(A);

t=V(:,3);

t = -t/t(2,1);

%% second inlier check & Outputs
% inlier?

line = [t(1), t(3)];
for i=1:size(points_dup,2)
    residual_leastsquare = abs( t(1)*points_dup(1,i) + t(2)*points_dup(2,i) + t(3) ) /...
        sqrt(t(1)^2+t(2)^2)  ;
    line_updown = t(1)*points_dup(1,i) + t(2)*points_dup(2,i) + t(3);
    if residual_leastsquare < 2.0*thr || line_updown > 0
        mask_inlier(1,i)=true;
    end
end
inliers = points_dup(:,mask_inlier);

% fprintf("%f %f # of inlier: %d\n",t(1),t(3),nnz(mask_inlier));

%% Outputs
% inliers=( inlier{max_cnt,:} ); %3 X N
% mask_inlier(non_zero_points_mask) = mask(max_cnt,:);
% line = [t(1),t(3)];

% if ~isempty(inliers)
%     figure();
%     plot(points_dup(1,:), points_dup(2,:), 'ro'); hold on;
%     plot(inliers(1,:), inliers(2,:), 'b+');
% %     x = [min(points(1,:)) max(points(1,:))];
%     x = [0 50];
%     y = line(1)*x + line(2);
%     plot(x, y, 'g-')
%     axis equal;
%     legend('nonZeroPts', 'inliers', 'fitting line');
%     title(['segment\_number: ', num2str(segment_number)])
% else
%     figure();
%     plot(points_dup(1,:), points_dup(2,:), 'ro'); hold on;
%     axis equal;
%     legend('nonZeroPts');
%     title(['segment\_number: ', num2str(segment_number)])
% end

% if segment_number == 60 || segment_number == 54
%     figure();
%     plot(points_dup(1,:), points_dup(2,:), 'r.'); hold on;
%     plot(points_sort(1,:), points_sort(2,:), 'bs');
%     plot(inliers(1,:), inliers(2,:), 'go','MarkerSize',10);
% %     x = [min(points(1,:)) max(points(1,:))];
%     x = [0 50];
%     y = line(1)*x + line(2);
%     plot(x, y, 'g-')
%     axis equal;
% %     legend('pts in segment', 'pts in bin', 'inliers');
%     xlabel('rho [m]'); ylabel('z [m]');
% %     title(['segment\_number: ', num2str(segment_number)])
%     xlim([0 60]); ylim([-5 5]);
% %     xlim([0 24]); ylim([-3 1]);
% else
% %     figure();
% %     plot(points_dup(1,:), points_dup(2,:), 'ro'); hold on;
% %     axis equal;
% %     legend('nonZeroPts');
% %     title(['segment\_number: ', num2str(segment_number)])
% end
end