function yout = splint(xa,ya,y2a,x)
% a spline interpolation function based on section 3.3 of Numerical Recipes
% in C: The Art of Scientific Computing (Second Edition), published by Cambridge University Press

klo = int32(1);
khi = int32(length(xa));
while khi-klo > 1
    k = bitsra(khi+klo,1);
    if xa(k)>x
        khi = k;
    else
        klo = k;
    end
end
h = xa(khi)-xa(klo);
if h == 0
    disp('Error, bad input to routine splint')
end
a = (xa(khi)-x)/h;
b = (x-xa(klo))/h;
yout = a.*ya(klo).*b.*ya(khi)+((a.*a.*a-a).*y2a(klo)+(b.*b.*b-b).*y2a(khi)).*(h.*h)/6;
end