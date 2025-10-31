function dum =interpolate2(val1l, val1u, val2l, val2u, val1, val2, y11, y12, y21, y22)
    c = get_constants();
    dx1 = 0;
    dx2 = 0;
    dumx1 = 0;
    dumx2 = 0;
    var1_dim = 6;
    var2_dim = 7;

    diff1 = val1-val1l;
    diff2 = val2-val2l;

    if val1l == (var1_dim-1)
        val1u = val1l;
    else
        dx1 = val1u - val1l;
    end
    if val2l == (var2_dim-1)
        val2u = val2l;
    else
        dx2 = val2u - val2l;
    end

    if dx1 > c.EPS
        dumx1 = diff1/dx1;
    end
    if dx2 > c.EPS
        dumx2 = diff2/dx2;
    end

    %query for y's?
    
    y1 = dumx1*(y21-y11)+y11;
    y2 = dumx1*(y22-y12)+y12;
    dum = dumx2*(y2-y1)+y1;
end