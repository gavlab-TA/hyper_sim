classdef input < handle
    properties
        %initial conditions
        lonx
        latx
        alt
        psivgx
        thtvgx
        dvbe
        alphax
        phimvx

        %aerodynamics
        area
               
        %propulsion
        mprop
        mass0
        fmass0
        aintake
        phi_min
        phi_max
        qhold
        tq
        tlag
        phi_const

        %control
        mcontrol
        philimx
        tphi
        alpposlimx
        alpneglimx
        anposlimx
        anneglimx
        allimx
        gacp
        ta
        gain_psivg
        altcom
        altdlim
        gh
        gv
        %other gains like 'gcp'

        %tables
        dbfile
    end
    methods

    end
end