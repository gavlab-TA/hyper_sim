function [wp_sltrange, VBEO, wp_grdrange, SWBG, rad_min, wp_flag, APGV] = guidance_point(wp_lonx, wp_latx, wp_alt, point_gain, time, grav, TIG, thtvgx, VBEG, SBII, philimx)
    APGV = zeros(3,1);
    TFG = zeros(3,3);
    SWII = zeros(3,1);
    TOG = zeros(3,3);
    POLAR = zeros(3,1);
    VH = zeros(3,1);
    SH = zeros(3,1);
    VBEO = zeros(3,1);
    SWBG = zeros(3,1);
    if time > 54
        dummy = 0;
    end

    % converting waypoint to inertial coords
    lla = [deg2rad(wp_lonx); deg2rad(wp_latx); wp_alt];
    SWII = lla2eci(lla, time);

    % waypoint wrt hyper missle displacement in geographic coords
    % (synthetic LOS)
    SWBG = (TIG.')*(SWII-SBII);

    % building TM of LOS wrt geographic axes;also getting range-to-go to wp
    POLAR = cart2pol(SWBG);
    wp_sltrange = POLAR(1,1);
    psiog = POLAR(2,1);
    thtog = POLAR(3,1);
    TOG = mat2tr(psiog, thtog);

    % ground range to wp (approx by using hyper missle local-level plane)
    swbg1 = SWBG(1,1);
    swbg2 = SWBG(2,1);
    wp_grdrange = sqrt(swbg1^2 + swbg2^2);

    % converting geographic hyper missle velocity to LOS and LOA coords
    VBEO = TOG*VBEG;
    vbeo2 = VBEO(2,1);
    vbeo3 = VBEO(3,1);

    % point guidance steering law
    apgv1 = grav*sin(deg2rad(thtvgx));
    apgv2 = point_gain*(-vbeo2);
    apgv3 = point_gain*(-vbeo3)-grav*cos(thtvgx);

    APGV = [apgv1; apgv2; apgv3];

    % setting way point flag (if within 2 times turning radius
    % : closing +1 or fleeting -1
    dvbe = abs(VBEG);
    rad_min = (dvbe^2)/(grav*tan(deg2rad(philimx)));
    if wp_grdrange < (2*rad_min)
        % projection of displacement vector into horizontal plane, SH
        SH = [swbg1; swbg2; 0];

        % projection of velocity vector into horizontal plane, VH
        vbeg1 = VBEG(1,1);
        vbeg2 = VBEG(2,1);
        VH = [vbeg1; vbeg2; 0];

        % setting flag either to +1 or -1
        wp_flag = sin(dot(VH, SH));
    else
        wp_flag = 0;
    end
end