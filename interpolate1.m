function dum = interpolate1(val, vlow, vhigh, ylow, yhigh)
    dumx = 0;
    c = get_constants();
    diff = val - vlow;
    dx = vhigh - vlow;
    dy = yhigh - ylow;
    if dx > c.EPS
        dumx = diff/dx;
    end
    dy = dumx*dy;

    dum = ylow + dy;

end