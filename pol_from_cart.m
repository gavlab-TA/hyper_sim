function pol = pol_from_cart(mat)
    d = 0;
    azimuth = 0;
    elevation = 0;

    v1 = mat(1);
    v2 = mat(2);
    v3 = mat(3);

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

    pol = [d; azimuth; elevation];
end