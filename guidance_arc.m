function [SWBG, wp_grdrange, rad_min, wp_flag] = guidance_arc(wp_lonx, wp_latx, wp_alt, time, FSPV, grav, TIG, dvbe, psivgx, VBEG, SBII, alphax, phimvx, philimx)
    SWII = zeros(3,1);
    POLAR = zeros(3,1);
    TBV = zeros(3,3);
    FSPB = zeros(3,1);
    VH = zeros(3,1);
    SH = zeros(3,1);
    UV = zeros(3,1);
    ZZ = zeros(3,1);
    SWBG = zeros(3,1);
    if time > 49
        test = 0;
    end
    
    %converting to waypoint coords
    lla = [deg2rad(wp_lonx); deg2rad(wp_latx); wp_alt];
    SWII = lla2eci(lla, time);
    
    %displacement of waypoint wrt hyper missle in geographic coord
    SWBG = (TIG.')*(SWII-SBII);

    %projection of displacement vector into horizontal plane, SH
    swbg1 = SWBG(1,1);
    swbg2 = SWBG(2,1);
    SH = [swbg1; swbg2; 0];

    %horizontal ground distance based on hyper missle geographic coords
    dwbh = sqrt(swbg1^2 + swbg2^2);

    %calcualting azimuth angle of waypoint LOS wrt velocity vector, psiwvx
    %projection of velocity vector into horizontal plane, VH
    vbeg1 = VBEG(1,1);
    vbeg2 = VBEG(2,1);
    VH = [vbeg1; vbeg2; 0];
    
    %vector normal to arc plane
    VH_ss = [0, -VH(3), VH(2);
             VH(3), 0, -VH(1);
             -VH(2), VH(1), 0];   %symmetric-skew of WOEB
    UV = VH_ss*SH;

    %steering angle, psiwvx
    psiwvx = rad2deg(angle(VH, SH));

    %steering angle w/ proper signage
    ZZ(3,1) = 1;
    psiwvx = psiwvx*sign(dot(UV, ZZ));

    %transforming specific force to body coordinates and picking third
    %component
    alpha = deg2rad(alphax);
    phimv = deg2rad(phimvx);
    TBV = cadtbv(phimv, alpha);
    FSPB = TBV*FSPV;
    fspb3 = FSPB(3,1);

    %selecting guidance mode
    if abs(psiwvx) < 90
        %guiding on the arc through the waypoint
        num = -2*(dvbe^2)*sin(deg2rad(psiwvx));
        denom = fspb3*dwbh;
        if denom ~= 0
            argument = num/denom;
        end
        if abs(asin(argument)) < deg2rad(philimx)
            phicx = rad2deg(asin(argument));
        else
            phicx = philimx*sign(argument);
        end
    else
        %making a minimum turn
        phicx = philimx*sign(psiwvx);
    end
    %diagnostic: radii
    if phimvx ~= 0
        rad_dynamic = abs((dvbe^2)/(fspb3*sin(deg2rad(phimvx))));
    end
    if psiwvx ~= 0
        rad_geometric = abs(dwbh/(2*sin(deg2rad(psiwvx))));
    end

    %setting waypoint flag (if within 2 tims turning radius)
    % :closing +1 or fleeting -1
    rad_min = (dvbe^2)/(grav*tan(deg2rad(philimx)));
    if dwbh < .2*rad_min
        wp_flag = sign(dot(VH, SH));
    else
        wp_flag = 0;
    end

    %ground range to waypoint
    wp_grdrange = dwbh;
end