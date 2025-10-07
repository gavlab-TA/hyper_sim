function alphax = control_flightpath(gain_thtvg, alpposlimx, alpneglimx, pdynmc, thtvg, grav, mass, area, cla, thtvgcx, phimvx)
    avx = gain_thtvg*(deg2rad(thtvgcx)- thtvg);
    anx = ((avx)/cos(deg2rad(phimvx)));
    alphax = ((anx*mass*grav)/(pdynmc*area*cla));

    if alphax > alpposlimx
        alphax = alpposlimx;
    end
    if alphax < alpneglimx
        alphax = alpneglimx;
    end
end