function [grav, rho, pdynmc, mach, vsound] = environment(alt, dvbe, time)
    if time == 0
        i = get_init();
        alt = i.alt;
        dvbe = i.dvbe;
    end
    c = get_constants();
    grav = c.G*c.EARTH_MASS/((c.REARTH+alt)^2);

    %iso 62 std atm
    if alt < 11000
        k = 288.15-.0065*alt;
        ptemp = 101325*((k/288.15)^5.2559);
    else
        k = 216;
        ptemp = 22630*(exp(-.00015769*(alt-11000)));
    end

    rho = ptemp/(c.R*k);
    vsound = sqrt(1.4*c.R*k);
    mach = abs(dvbe/vsound);
    pdynmc = .5*rho*(dvbe^2);
end