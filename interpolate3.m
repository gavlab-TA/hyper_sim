function dum = interpolate3(val1l, val1u, val2l, val2u, val3l, val3u, val1, val2, val3, y111, y112, y121, y122, y211, y212, y221, y222)
    c = get_constants();
    var1_dim = 6;
    var2_dim = 7;
    var3_dim = 8;
    
    dx1 = 0;
    dx2 = 0;
    dx3 = 0;
    dumx1 = 0;
    dumx2 = 0;
    dumx3 = 0;
    diff1 = val1-val1l;
    diff2 = val2-val2l;
    diff3 = val3-val3l;
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
    
    if val3l == (var3_dim-1)
        val3u = val3l;
    else
        dx3 = val3u - val3l;
    end

    if dx1 > c.EPS
        dumx1 = diff1/dx1;
    end
    
    if dx2 > c.EPS
        dumx2 = diff2/dx2;
    end
    if dx3 > c.EPS
        dumx3 = diff3/dx3;
    end

    y1 = dumx1*(y112-y111)+y111;
    y3 = dumx1*(y212-y211)+y211;
    y21 = dumx3*(y3-y1)+y1;

    y1 = dumx1*(y122-y121)+y121;
    y3 = dumx1*(y222-y221)+y221;
    y22 = dumx3*(y3-y1)+y1;

    dum = dumx2*(y22-y21)+y21;
end