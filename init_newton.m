function [TGV, TIG, WEII, SB0II, VBEG, TGE, SBII, VBII, lonx_l, latx_l, SBEG, ABII] = init_newton(dvbe, psivgx, thtvgx, lonx, latx, alt)
    
    REARTH = 6370987.308;
    WEII3 = 7.292115E-5;
    temp = 0;
    psivg = 0;
    thtvg = 0;
    TEI = zeros(3, 3);
    SBIE = zeros(3, 1);
    SBIG = zeros(3, 1);
    BVEI = zeros(3, 1);
    TGI = zeros(3, 3);
    TEG = zeros(3, 3);
    TVG = zeros(3, 3);
    
    SB0II = zeros(3, 1);
    TGE = zeros(3, 3);
    TGV = zeros(3, 3);
    TIG = zeros(3, 3);
    WEII = zeros(3, 3);
    VBEG = zeros(3, 1);
    SBII = zeros(3, 1);
    VBII = zeros(3, 1);
    ABII = zeros(3, 1);
    lonx_l = 0;
    latx_l = 0;
    
    dvbe;
    psivgx;
    thtvgx;
    lonx;
    latx;
    alt;
    SBEG = zeros(3, 1);
    
    %calculating initial vehicle position in earth coords
    temp = -(alt+REARTH);
    SBIG(3,1) = temp;
    clon = cos(deg2rad(lonx));
    slon = sin(deg2rad(lonx));
    clat = cos(deg2rad(latx));
    slat = sin(deg2rad(latx));
    TGE = [-slat*clon, -slat*slon, clat;
           -slon, clon, 0;
           -clat*clon, -clat*slon, -slat];
    TEG = TGE.';
    SBIE = TEG*SBIG;
    
    
    %at startg of sim, inertial and earth coordinates coincide
    SBII = SBIE;
    
    %save initial position for later use
    SB0II = SBII;
    
    psivg = deg2rad(psivgx);
    thtvg = deg2rad(thtvgx);
    
    %geographic velocity
    VBEG = dvbe*[cos(psivg)*cos(thtvg); cos(thtvg)*sin(psivg); -sin(thtvg)];
    
    %earths angular velocity tensor in inertial coordinates
    WEII(1, 2) = -WEII3;
    WEII(2, 1) = WEII3;
    
    %at start of sim the earth and inertial axes coincide
    TIG = TEG;
    
    %initalizing velocity state variables
    VBII = TIG*VBEG+WEII*SBII;
    
    %TM of velocity wrt geographic coordinates
    TVG = [cos(psivg)*cos(thtvg), cos(thtvg)*sin(psivg), -sin(thtvg);
           -sin(psivg), cos(psivg), 0;
           sin(thtvg)*cos(psivg), sin(thtvg)*sin(psivg), cos(thtvg)];
    
    TGV = TVG.';


end