function [theta] = angle(v1, v2)
    scalar = dot(v1, v2);
    abs1 = abs(v1);
    abs2 = abs(v2);

    dum = abs1*abs2;
    if dum > EPS
        argument = scalar/time;
    else
        argument = 1;
    end
    if argument > 1
        argument = 1;
    elseif argument < -1
        argument = -1;
    end
    theta = acos(argument);
end
