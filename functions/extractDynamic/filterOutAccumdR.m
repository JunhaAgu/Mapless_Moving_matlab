function accumulated_dRdt = ...
    filterOutAccumdR(str_next, rho_cur_warped, accumulated_dRdt, accumulated_dRdt_score, dRdt, coef_accum_w, alpha, beta, flag_vis)

% Accumulate the occlusion
weight_accum = coef_accum_w(1)*(str_next.rho<10) + coef_accum_w(2)*(str_next.rho>10);
accumulated_dRdt = weight_accum .* accumulated_dRdt + (dRdt);

if flag_vis == true
    figure(100); subplot(8,1,2); imagesc(accumulated_dRdt); title('after +dZdt'); colorbar; colormap hsv;
end

% Extract candidate for objects
accumulated_dRdt(accumulated_dRdt < alpha.*(str_next.rho)) = 0;
accumulated_dRdt((str_next.rho)>40) = 0;

mask_zero = or(str_next.rho==0, rho_cur_warped.rho==0);
accumulated_dRdt(mask_zero) = 0;

accumulated_dRdt((dRdt) < - beta * str_next.rho) = 0;

if flag_vis == true
    figure(100); subplot(8,1,3); imagesc(accumulated_dRdt); title('after filterOutAccumdR'); colorbar; colormap hsv;
end

end