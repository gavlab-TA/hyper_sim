function [altd, ancomx] = control_altitude(altcom, phimvx, anposlimx, anneglimx, altdlim, gh, gv, alt, grav, VBEG)
    ealt = gh*(altcom-alt);

    if ealt > altdlim
        ealt = altdlim;
    end
    if ealt < -altdlim
        ealt = -ealtdlim;
    end

    altd = -VBEG(3, 1);

    ancomx = (gv*(ealt-altd)/grav+1)*(1/cos(rad2deg(phimvx)));

    if ancomx > anposlimx
        ancomx = anposlimx;
    end
    if ancomx < anneglimx
        ancomx = anneglimx;
    end
end