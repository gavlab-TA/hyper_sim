function [cl, cd, cla, cl_v_cd, cn, ca] = aero(mach, alphax)
    %aeroballistic conversion
    cn = lookup2d_interp(alphax, mach, "cn");
    ca = lookup2d_interp(alphax, mach, "cn");

    %aircraft conventions
    cd = cn*sin(alphax) + ca*cos(alphax);
    cl = cn*sin(alphax) - ca*sin(alphax);
    cl_v_cd = cl/cd;

    %computing lift-alpha derevitive (1/deg) for controllers
    cnp = lookup2d_interp(alphax+2, mach, "cn");
    cnn = lookup2d_interp(alphax-2, mach, "cn");
    cap = lookup2d_interp(alphax+2, mach, "ca");
    can = lookup2d_interp(alphax-2, mach, "ca");
    cna = (cnp-cnn)/4;
    caa = (cap-can)/4;
    cla = cna*cos(alphax) - caa*sin(alphax);
end