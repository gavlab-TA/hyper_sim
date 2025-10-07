function [alpx, xi, xid, alp, alpd, anx, qq, tip] = control_load(ancomx, int_step, anposlimx, anneglimx, phimvx, gacp, ta, alphax, alpposlimx, alpneglimx, FSPV, grav, xi, xid, alp, alpd, mass, dvbe, pdynmc, thrust, area, cla)
    alpha = deg2rad(alphax);
    phimv = deg2rad(phimvx);
    TBV = cadtbv(phimv, alpha);
    FSPB = TBV*FSPV;

    if ancomx > anposlimx
        ancomx = anposlimx;
    end
    if ancoms < anneglimx
        ancomx = anneglimx;
    end

    fspb3 = FSPB(3,1);
    anx = -fspb3/grav;

    eanx = ancomx - anx;

    tip = dvbe*mass/(pdynmc*area*cla/0.0174532925199432+thrust);

    if ta > 0
        gr = gacp*tip/dvbe;
        gi=gr/ta;
        xid_new = gi*eanx;
        xi = int_simp(xid_new, xid, xi, int_step);
        xid = xid_new;
    else
        xi = 0;
    end

    qq = gr*eanx+xi;

    alpd_new = qq-alp/tip;
    alp = int_simp(alpd_new, alpd, alp, int_step);
    alpd = alpd_new;

    alpx = rad2deg(alp);

    if alpx > alpposlimx
        alpx = alpposlimx;
    end
    if alpx < alpneglimx
        alpx = alpneglimx;
    end
end