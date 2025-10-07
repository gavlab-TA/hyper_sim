function [phicx, TBV, TBG, alphax, phimvx, ancomx] = control(mcontrol, psivgcx, thtvgcx, alphacx, ancomx, alcomx, altcom, phicx, TGV)
    i = get_init;
    int_step = i.int_step;
    
    if mcontrol == 0
        phimvx = 0;
        alphax = 0;
    end
    if mcontrol == 1
        phimvx = 0;
        alphax = control_flightpath(thtvgcs, phimvx);
    end
    if mcontrol == 10
        phicx = control_heading(psigcx);
        phimvx = control_bank(phicx, int_step);
        alphax = alphacx;
    end
    if mcontrol == 11
        phicx = control_heading(psivgcx);
        phimvx = control_bank(phicx, int_step);
        alphax = control_flightpath(thtvgcx, phimvx);
    end
    if mcontrol == 3
        phimvx = control_bank(phicx, int_step);
        alphax = alphacx;
    end
    if mcontrol == 4
        alphax = control_load(ancomx, int_step);
    end
    if mcontrol == 40
        phicx = control_lateral(alcomx);
        phimvx = control_bank(phicx, int_step);
    end
    if mcontrol == 44
        phicx = control_lateral(alcomx);
        phimvx = control_bank(phicx, int_step);
        alphax = control_load(ancomx, int_step);
    end
    if mcontrol == 6
        ancomx = control_lateral(altcom, phimvx);
        alphax = control_load(ancomx, int_step);
    end
    if mcontrol == 16
        phicx = control_heading(psivgcx);
        phimvx = control_bank(phicx, int_step);

        ancomx = control_altitude(altcomx, int_step);
        alphax = control_load(ancomx, int_step);
    end
    if mcontrol == 46
        phicx = control_lateral(alcomx);
        phimvx = control_bank(phicx, int_step);

        ancomx = control_altitude(altcom, phimvx);
        alphax = control_load(ancomx, int_step);
    end
    if mcontrol == 36
        phimvx = control_bank(phicx, int_step);

        ancomx = control_altitude(altcom, phimvx);
        alphax = control_load(ancomx, int_step);
    end

    TBV = cadtbv(deg2rad(phimvx), deg2rad(alphax));
    TVG = TGV.';
    TBG = TBV*TVG;

end