%% Initialize images
ZEROS_img = zeros(height,width);
ONES_img = ones(height,width);

accumulated_dRdt = ZEROS_img;
accumulated_dRdt_score = ZEROS_img;

background_mask = ONES_img;