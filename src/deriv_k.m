function derivee = deriv_k(varargin)

if nargin == 1
    x = varargin{1};
    [r,c] = size(x);
    if c ==1
        x = x';
    end
    nbp_x = length(x);
    derivee = circshift(x,[0 -1])-circshift(x,[0 1]);
    derivee(1) = -3*x(1)+4*x(2)-x(3);
    derivee(nbp_x) = 3*x(nbp_x)-4*x(nbp_x-1)+x(nbp_x-2);
    derivee = derivee./2';
else
    x = varargin{1};
    [r,c] = size(x);
    if c ==1
        x = x';
    end
    y = varargin{2};
    [r,c] = size(y);
    if c ==1
        y = y';
    end
    nbp_x = length(x);
    nbp_y = length(y);
    
    dx = x-circshift(x,[0 1]);
    dx = dx(2:end);
    dx_min = min(dx);
    dx_max = max(dx);
    
    % DO SOME CHECKS??
    if (dx_min == dx_max)
        derivee = deriv_k(y)/dx_min;
    else
        x0_x1 = circshift(x,[0 1])-x;
        x1_x2 = x-circshift(x,[0 -1]);
        x0_x2 = circshift(x,[0 1])-circshift(x,[0 -1]);
        
        derivee = circshift(y,[0 1]).*x1_x2./(x0_x1.*x0_x2);
        derivee = derivee+y.*(1./x1_x2-1./x0_x1);
        derivee = derivee-circshift(y,[0 -1]).*x0_x1./(x0_x2.*x1_x2);
        
        derivee(1) = y(1).*(1./x0_x1(2)+1./x0_x2(2));
        derivee(1) = derivee(1)-y(2)*x0_x2(2)/(x0_x1(2)*x1_x2(2));
        derivee(1) = derivee(1)+y(3)*x0_x1(2)/(x0_x2(2)*x1_x2(2));
        
        nm3 = nbp_x-2;
        nm2 = nbp_x-1;
        nm1 = nbp_x;
        
        derivee(nm1) = -y(nm3)*x1_x2(nm2)/(x0_x1(nm2)*x0_x2(nm2));
        derivee(nm1) = derivee(nm1)+y(nm2)*x0_x2(nm2)/(x0_x1(nm2)*x1_x2(nm2));
        derivee(nm1) = derivee(nm1)-y(nm1)*(1/x0_x2(nm2)+1/x1_x2(nm2));
    end
end

end