function [phix, phixd] = control_bank(phicx, int_step, philimx, tphi, phix, phixd)
    if phicx > philimx
        phicx = philimx;
    end
    if phicx < -philimx
        phicx = -philimx;
    end

    phixd_new = (phicx-phix)/tphi;
    phix = integrate(phixd_new, phixd, phix, int_step);
    phixd = phixd_new;
end