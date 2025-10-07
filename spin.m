

i = get_init();
alt = i.alt;
dvbe = i.dvbe;
alphax = i.alphax;
mass0 = i.mass0;
mass = mass0;
fmassr = i.fmass0;
phis = 0;
phisd = 0;
fmasse = 0;
fmassd = 0;
area = i.area;
int_step = .01;
mprop = i.mprop;
aintake = i.aintake;
qhold = i.qhold;
tq = i.tq;
tlag = i.tlag;
mcontrol = i.mcontrol;
psivgcx = i.psivgcx;
thtvgcx = i.thtvgcx;
alphacx = i.alphacx;
ancomx = i.ancomx;
alcomx = i.alcomx;
altcom = i.altcom;
phicx = i.phicx;
phi = i.phi_min;
alphax = i.alphax;
phimvx = i.phimvx;



[TGV, TIG, WEII, SB0II, VBEG, TGE, SBII, VBII, lonx_l, latx_l, SBEG, ABII] = init_newton(i.dvbe, i.psivgx, i.thtvgx, i.lonx, i.latx, i.alt);

for time = 0:25
    if time > 5
        phicx = 30;
    elseif time > 10
        phicx = 0;
    elseif time > 15
        phicx = -30;
    elseif time > 20
        phicx = 0;
    end
    
    [grav, rho, pdynmc, mach, vsound] = environment(alt, dvbe, time);
    [cl, cd, cla, cl_v_cd, cn, ca] = aero(mach, alphax);
    [phis, phisd, fmasse, fmassd, phi, mass, thrust, mprop, cin, thrst_stoch, spi, mass_flow, fmassr, thrst_req] = prop(mass, fmassr, phis, phisd, fmasse, fmassd, time, rho, pdynmc, mach, dvbe, ca, area, alphax, int_step, mprop, aintake, qhold, tq, tlag, phi);
    [FSPV] = forces(pdynmc, cl, cd, area, thrust, mass, alphax, phimvx);
    [SBEG, VBEG, SBII, VBII, ABII, TGV, TIG, psivg, thtvg, alt, ...
    dvbe, psivgx, thtvgx, lonx, latx, TGE, altx, ground_range] = ...
    newton(int_step, WEII, lonx_l, latx_l, SBEG, VBEG, SBII, VBII, ABII, ...
    TGV, TIG, time, FSPV, grav);
    [phicx, TBV, TBG, alphax, phimvx, ancomx] = control(mcontrol, psivgcx, thtvgcx, alphacx, ancomx, alcomx, altcom, phicx, TGV);
    
    results = [time, rho, pdynmc, mach, lonx, latx, alt, dvbe; ...
               psivgx, thtvgx, SBEG(1), SBEG(2), SBEG(3), VBEG(1), VBEG(2), VBEG(3); ...
               ground_range, phi, mass, cin, spi, thrust, fmassr, thrst_req; ...
               cl, cd, cl_v_cd, cla, cn, ca, mcontrol, 0; ...
               0, alphax, phimvx, phicx, ancomx, alcomx, mprop, 0];
end
