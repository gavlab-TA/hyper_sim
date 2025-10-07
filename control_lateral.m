function [alx, phicx] = control_lateral(alcomx, allimx, FSPV, grav, phimvx, alphax)
    alpha = deg2rad(alphax);
    phimv = deg2rad(phimvx);
    TBV = cadtbv(phimv, alpha);
    FSPB = TBV*FSPV;

    fspb3 = FSPB(3,1);
    anx = -fspb3/grav;

    if alcomx > allimx
        alcomx = allimx;
    end
    if alcomx < -allimx
        alcomx = -allimx;
    end

    phic = atan2(alcomx, anx);
    phicx = rad2deg(phic);

    fspv2 = FSPV(2,1);
    alx = fspv2/grav;
end