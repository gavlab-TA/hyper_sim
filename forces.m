function [FSPV] = forces(pdynmc, cl, cd, area, thrust, mass, alphax, phimvx)
    phimv = deg2rad(phimvx);
    alpha = deg2rad(alphax);
    
    fspv1 = (-pdynmc*area*cd+thrust*cos(alpha))/mass;
    fspv2 = sin(phimv)*(pdynmc*area*cl+thrust*sin(alpha))/mass;
    fspv3 = -cos(phimv)*(pdynmc*area*cl+thrust*sin(alpha))/mass;
    
    FSPV = [fspv1; fspv2; fspv3];
end



