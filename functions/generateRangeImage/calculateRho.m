function [rho, phi, theta] = calculateRho(xyz)
twopi = 2*pi;

n_pts = size(xyz,1);
rho   = zeros(n_pts,1);
theta   = zeros(n_pts,1);
phi = zeros(n_pts,1);
    
offset_theta = pi;

rhophitheta = zeros(n_pts, 3);

for i = 1:n_pts
    
    X = xyz(i,:);
    rho(i) = norm(X);
    phi(i) = asin(X(3)/rho(i));
    invrhocos = 1/(rho(i)*cos(phi(i)));
    
    cospsi = X(1)*invrhocos;
    if cospsi > 1
        fprintf(" cospsi > 1 ");
    elseif cospsi < -1
        fprintf(" cospsi < -1 ");
    end

    sinpsi = X(2)*invrhocos;
    if(cospsi >= 0)
        if(sinpsi >=0) % 1 quadrant
            theta(i) = acos(cospsi)+offset_theta;
        else % 4 quadrant
            theta(i) = twopi-acos(cospsi)+offset_theta;
        end
    else
        if(sinpsi >=0) % 2 quadrant
            theta(i) = pi-acos(-cospsi)+offset_theta;
        else % 3 quadrant
            theta(i) = pi+acos(-cospsi)+offset_theta;
        end
    end
    if(theta(i) >= twopi)
        theta(i) = theta(i)-twopi;
    end
    rhophitheta(i,:) = [rho(i), phi(i), theta(i)];
end

theta = real(theta);

end