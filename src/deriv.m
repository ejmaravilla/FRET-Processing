function d = deriv(x,y)

d = zeros(1,length(x));
for i = 1:length(x)
    if i == 1
        p = polyfit(x(i:i+1),y(i:i+1),1);
    elseif i == length(x)
        p = polyfit(x(i-1:i),y(i-1:i),1);
    else
        p = polyfit(x(i-1:i+1),y(i-1:i+1),1);
    end
    d(i) = p(1);
end

end