function APNB = guidance_pronav(pronav_gain, bias, grav, TBG, range_go, WOEB, closing_speed, psisbx, thtsbx, UTBB)
    APNB = zeros(3,1);
    GRAV_G = zeros(3,1);

    GRAV_G(3,1) = grav+bias;
    WOEB_ss = [0, -WOEB(3), WOEB(2);
               WOEB(3), 0, -WOEB(1);
               -WOEB(2), WOEB(1), 0];   %symmetric-skew of WOEB
    APNB = WOEB_ss*UTBB*(pronav_gain*closing_speed)-TBG*GRAV_G;
end