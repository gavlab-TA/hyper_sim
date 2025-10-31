function init_newton(s)
    
    c = get_constants();
    s.WEII = zeros(3,3);
    s.ABII = zeros(3,1);
    s.SBEG = zeros(3,1);
    
    %calculating initial vehicle position in earth coords
    temp = (s.alt+c.REARTH);
    
    clon = cos(deg2rad(s.lonx));
    slon = sin(deg2rad(s.lonx));
    clat = cos(deg2rad(s.latx));
    slat = sin(deg2rad(s.latx));

    SBIE = [temp*clat*clon; temp*clat*slon; temp*slat];

    s.TGE = [-slat*clon, -slat*slon, clat;
           -slon, clon, 0;
           -clat*clon, -clat*slon, -slat];
    TEG = s.TGE';
    
    
    
    
    %at startg of sim, inertial and earth coordinates coincide
    s.SBII = SBIE;
    
    %save initial position for later use
    s.SB0II = s.SBII;
    
    psivg = deg2rad(s.psivgx);
    thtvg = deg2rad(s.thtvgx);
    
    %geographic velocity
    s.VBEG = s.dvbe*[cos(psivg)*cos(thtvg); cos(thtvg)*sin(psivg); -sin(thtvg)];
    
    %earths angular velocity tensor in inertial coordinates
    s.WEII(1, 2) = -c.WEII3;
    s.WEII(2, 1) = c.WEII3;
    
    %at start of sim the earth and inertial axes coincide
    s.TIG = TEG;
    

    %initalizing velocity state variables
    s.VBII = s.TIG*s.VBEG+s.WEII*s.SBII;
    
    %TM of velocity wrt geographic coordinates
    TVG = [cos(psivg)*cos(thtvg), cos(thtvg)*sin(psivg), -sin(thtvg);
           -sin(psivg), cos(psivg), 0;
           sin(thtvg)*cos(psivg), sin(thtvg)*sin(psivg), cos(thtvg)];
    
    s.TGV = TVG.';


end