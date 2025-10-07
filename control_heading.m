function phimvx = control_heading(gain_psivg, psivgx, psivgcx)
    if abs(psivgcx) <= 135
        psivgx_comp = psivgx;
    else
        if (psivgx*psivgcx) >= 0
            psivgx_comp = psivgx;
        else
            if psivgx >=0
                sign_psivgx = 1;
            else
                sign_psivgx = -1;
            end
            psivgx_comp = 360-phivgx*sign_psivgx;
        end
    end
    phimvx = gain_psivg*(psivgcx-psivgx_comp);
end