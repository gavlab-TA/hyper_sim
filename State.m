classdef State < handle
    properties
        %primary states
        alt
        lonx
        latx
        dvbe
        psivgx
        thtvgx

        %inertial states
        SBII
        VBII
        ABII
        SBEG
        VBEG

        %attitude and control states
        alphax
        phimvx
        phimvxd

        %internal controller states (from control_load)
        xi
        xid
        alp
        alpd

        %propulsion states
        mass
        fmassr
        fmasse
        fmassd
        phi
        phis
        phisd

        %control commands (from guidance
        phicx
        ancomx
        alcomx
        altcom
        psivgcx
        thtvgcx
        alphacx

        %env vals
        gravity
        rho
        pdynmc
        mach
        vsound

        %aero vala
        cl
        cd
        cn
        ca
        cla
        cl_v_cd
        alx

        %prop vals
        thrust
        cin
        spi
        thrst_req
        phi_l

        %transformation matrices
        TGV
        TIG
        TGE
        TBV
        TBG
        
        %reference and sim vals
        ground_range
        WEII
        lonx_l
        latx_l
        SB0II

        %guidance/logging
        wp_sltrange
        wp_grdrange
        wp_flag
        nl_gain

        FSPV
    end
    methods
        function obj = State(i)
            %initalize state with input
            obj.altcom = i.altcom;

            % Set initial state variables
            obj.lonx = i.lonx;
            obj.latx = i.latx;
            obj.alt = i.alt;
            obj.psivgx = i.psivgx;
            obj.thtvgx = i.thtvgx;
            obj.dvbe = i.dvbe;
            obj.alphax = i.alphax;
            obj.phimvx = i.phimvx;

            % Set initial mass & prop
            obj.mass = i.mass0;
            obj.fmassr = i.fmass0;
            obj.phi = i.phi_min;
            obj.phis = 0;
            obj.phisd = 0;
            obj.fmasse = 0;
            obj.fmassd = 0;

            obj.phicx = 0;
            obj.phimvxd = 0;
            obj.lonx_l = i.lonx;
            obj.latx_l = i.latx;

            obj.xi = 0;
            obj.xid = 0;
            obj.alp = i.alphax;
            obj.alpd = 0;

            init_newton(obj);

            obj.TBV = eye(3);
            obj.TBG = eye(3);
            obj.TGV = eye(3);
            obj.TIG = eye(3);

            

            obj.FSPV = zeros(3,1);
        end

        function update_env(obj, time)
            c = get_constants;
            obj.gravity = c.G*c.EARTH_MASS/((c.REARTH+obj.alt)^2);

            %ISO62 standard atmosphere
            if obj.alt < 11000
                k = 288.15-.0065*obj.alt;
                ptemp = 101325*((k/288.15)^5.2559);
            else
                k = 216;
                ptemp = 22630*(exp(-0.00015769*(obj.alt-11000)));
            end
            obj.rho = ptemp/(c.R*k);
            obj.vsound = sqrt(1.4*c.R*k);
            obj.mach = abs(obj.dvbe/obj.vsound);
            obj.pdynmc = .5*obj.rho*(obj.dvbe^2);
        end

        function update_dynamics(obj, FSPV, int_step, time)
            c = get_constants();
            obj.WEII = [0, -c.WEII3, 0;
                        c.WEII3, 0, 0;
                        0, 0, 0];

            GRAV = zeros(3,1);
            GRAV(3,1) = obj.gravity;

            % integrate inertial state vars
           
            ABII_NEW = obj.TIG*((obj.TGV*FSPV)+GRAV);
            VBII_NEW = int_simp(ABII_NEW, obj.ABII, obj.VBII, int_step);
            obj.SBII = int_simp(VBII_NEW, obj.VBII, obj.SBII, int_step);
            obj.ABII = ABII_NEW;
            obj.VBII = VBII_NEW;

            %inertial position in earth coords
            xi_1 = c.WEII3*time;
            sxi = sin(xi_1);
            cxi = cos(xi_1);
            TEI = [cxi, sxi, 0; -sxi, cxi, 0; 0, 0, 1];

            %get lat, lon, alt
            sim_seconds_total = time; % Total elapsed seconds
            
            % Calculate day, hour, minute, and second rollovers
            sim_day    = floor(sim_seconds_total / 86400); 
            sec_in_day = mod(sim_seconds_total, 86400);
            
            sim_hour   = floor(sec_in_day / 3600);
            sec_in_hour= mod(sec_in_day, 3600);
            
            sim_minute = floor(sec_in_hour / 60);
            sim_second = mod(sec_in_hour, 60);

            % Create the valid UTC vector, starting on Jan 1st
            utc = [2025 1 (1 + sim_day) sim_hour sim_minute sim_second];
            
            TEMP = eci2lla(obj.SBII.', utc);

            
            obj.lonx = TEMP(2);
            obj.latx = TEMP(1);
            obj.alt = TEMP(3);

            % calculate TM of geographic wrt earth coords
            lat = deg2rad(obj.latx);
            lon = deg2rad(obj.lonx);

            clon = cos(lon);
            slon = sin(lon);
            clat = cos(lat);
            slat = sin(lat);
            obj.TGE = [(-slat*clon), (-slat*slon), clat;
                       (-slon), clon, 0;
                       (-clat*clon), (-clat*slon), -slat];

            TGI = obj.TGE*TEI;

            VBEG_NEW = TGI*(obj.VBII-(obj.WEII*obj.SBII));
            
            obj.SBEG = int_simp(VBEG_NEW, obj.VBEG, obj.SBEG, int_step);
            obj.VBEG = VBEG_NEW;

            %get speed, heading, flightpath angle
            POLAR = pol_from_cart(obj.VBEG);
            obj.dvbe = POLAR(1);
            psivg_rad = POLAR(2);
            thtvg_rad = POLAR(3);
            obj.psivgx = rad2deg(psivg_rad);
            obj.thtvgx = rad2deg(thtvg_rad);

            obj.TIG = TGI.';
            stht = sin(thtvg_rad);
            ctht = cos(thtvg_rad);
            spsi = sin(psivg_rad);
            cpsi = cos(psivg_rad);
            TVG = [(cpsi*ctht), (ctht*spsi), -stht;
                   -spsi, cpsi, 0;
                   (stht*cpsi), (stht*spsi), ctht];
            obj.TGV = TVG.';
            dlat = deg2rad(obj.latx - obj.latx_l);
            dlon = deg2rad(obj.lonx - obj.lonx_l);
            lat1 = deg2rad(obj.latx_l);
            lat2 = deg2rad(obj.latx);

            a_gr = sin(dlat/2)^2 + cos(lat1)*cos(lat2)*sin(dlon/2)^2;
            c_gr = 2*atan2(sqrt(a_gr), sqrt(1-a_gr));
            obj.ground_range = c.REARTH * c_gr;

        end
    end
end