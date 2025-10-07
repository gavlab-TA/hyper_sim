function [SBEG, VBEG, SBII, VBII, ABII, TGV, TIG, psivg, thtvg, alt, ...
    dvbe, psivgx, thtvgx, lonx, latx, TGE, altx, ground_range] = ...
    newton(int_step, WEII, lonx_l, latx_l, SBEG, VBEG, SBII, VBII, ABII, ...
    TGV, TIG, time, FSPV, grav)

c = get_constants();
%local variables
lon = 0;
lat = 0;
SBIE = zeros(3,1);
TEMP = zeros(3,1);
VBEI = zeros(3,1);
GRAV = zeros(3,1);
ABII_NEW = zeros(3,1);
VBII_NEW = zeros(3,1);
POLAR = zeros(3,1);
VBEG_NEW = zeros(3,1);
TEI = zeros(3,3);
TGI = zeros(3,3);
TEG = zeros(3,3);

%local module-variables
dvbe = 0;
psivg = 0;
thtvg = 0;
lonx = 0;
latx = 0;
alt = 0;
psivgx = 0;
thtvgx = 0;
altx = 0;
TVG = zeros(3,3);
TGE = zeros(3,3);
ground_range = 0;

%localizing module-variables
%input from initalization
WEII;
lonx_l;
latx_l;
%state variables
SBEG;
VBEG;
SBII;
VBII;
ABII;
%restore saved values
TGV;
TIG;
%input from other modules
time;
FSPV;
grav;





%building gravitional vector in geographic coords
GRAV(3,1) = grav;

%integrate inertial state variables
ABII_NEW = TIG*((TGV*FSPV)+GRAV);
VBII_NEW = int_simp(ABII_NEW, ABII, VBII, int_step);
SBII = int_simp(VBII_NEW, VBII, SBII, int_step);
ABII = ABII_NEW;
VBII = VBII_NEW;



%inertial position in earth coords
xi = c.WEII3*time;
sxi = sin(xi);
cxi = cos(xi);
TEI = [cxi, sxi, 0; -sxi, cxi, 0; 0, 0, 1];
size(SBII)
size(TEI)
SBIE = TEI*SBII;

%GETTING LAT, LON, ALT
sec = mod(time, 60);
minute = time/60;
minute = mod(minute, 60);
hour = minute/60;
hour = mod(hour, 60);
utc = [2025 1 1 hour minute sec]

TEMP = eci2lla(SBIE', utc);
lon = TEMP(1);
lat = TEMP(2);
alt = TEMP(3);
lonx = lon*(180/pi);
latx = lat*(180/pi);
altx = alt/1000;

% calculate TM of geographic wrt earth coords
clon = cos(lon);
slon = sin(lon);
clat = cos(lat);
slat = sin(lat);
TGE = [(-slat*clon), (-slat*slon), clat;
        -slon, clon, 0; 
        -clat*clon, -clat*slon, -slat];

%calculate TM of geographic wrt inertial coords
TGI = TGE*TEI;

%calculate geographic velocity
VBEG_NEW = TGI*(VBII-(WEII*SBII));

%integrate to obtain geographic displacement wrt initial launch point E
SBEG = int_simp(VBEG_NEW, VBEG, SBEG, int_step);
VBEG = VBEG_NEW;

%getting speed, heading, and flight path angle
POLAR = pol_from_cart(VBEG);
dvbe = POLAR(1);
psivg = POLAR(2);
thtvg = POLAR(3);
psivgx = psivg*(180/pi);
thtvgx = thtvg*(180/pi);


%prep TMs for output
TIG = TGI.';
stht = sin(thtvg);
ctht = cos(thtvg);
spsi = sin(psivg);
cpsi = cos(psivg);
TVG = [cpsi*ctht, ctht*spsi, -stht;
       -spsi, cpsi, 0;
       stht*cpsi, stht*spsi, ctht];
TGV = TVG.';

%calculate ground range since launch c = launch, t = vehicle
dum = sin(deg2rad(latx))*sin(deg2rad(latx_l))+cos(deg2rad(latx))*cos(deg2rad(latx_l))*cos(deg2rad(lonx)-deg2rad(lonx_l));
ground_range = c.REARTH*acos(dum);









end