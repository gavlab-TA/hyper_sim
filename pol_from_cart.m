function POL = pol_from_cart(MAT)

    d = 0;
    azimuth = 0;
    elevation = 0;

    v1 = MAT(1);
    v2 = MAT(2);
    v3 = MAT(3);

    d = sqrt(v1^2 + v2^2 + v3^2);
    azimuth = atan2(v2, v1);
    denom = sqrt(v1^2 + v2^2);
    if denom > 0
        elevation = atan2(-v3, denom);
    else
        if v3 > 0
            elevation = -pi/2;
        end
        if v3 < 0
            elevation = pi/2;
        end
        if v3 == 0
            elevation = 0;
        end
    end

    POL = [d; azimuth; elevation];
end