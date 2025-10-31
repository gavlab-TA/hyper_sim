classdef Vehicle < handle
    properties
        % aero properties
        area

        % mass properties
        mass0
        fmass0

        % propulsion
        mprop
        aintake
        phi_min
        phi_max
        qhold
        tq
        tlag
        phi_const

        % control/constraints
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
        gv
        altdlim
        gain_psivg
        ancomx
        gh
        %other gains

        dbfile
    end
    methods
        function obj = Vehicle(i)
            obj.area = i.area;

            obj.mass0 = i.mass0;
            obj.fmass0 = i.fmass0;

            obj.mprop = i.mprop;
            obj.aintake = i.aintake;
            obj.qhold = i.qhold;
            obj.tq = i.tq;
            obj.tlag = i.tlag;
            obj.phi_min = i.phi_min;
            obj.phi_max = i.phi_max;

            obj.mcontrol = i.mcontrol;
            obj.philimx = 70;
            obj.tphi = 1;
            obj.dbfile = i.dbfile;
            obj.phi_const = i.phi_const;
            obj.gain_psivg = i.gain_psivg;

            obj.anposlimx = i.anposlimx;
            obj.anneglimx = i.anneglimx;
            obj.gacp = 10;
            obj.ta = .8;
            obj.alpposlimx = 6;
            obj.alpneglimx = -4;
            obj.gv = i.gv;
            obj.gh = i.gh;
            obj.altdlim = i.altdlim;

            %other params from input
        end
        function aero(obj, s)
            % Use adaptive finite difference step
            delta = 1.0;  % 1 degree step instead of 2
            
            % Ensure we stay within database bounds [-4, 6]
            alpha_up = min(s.alphax + delta, 6);
            alpha_down = max(s.alphax - delta, -4);
            actual_delta = alpha_up - alpha_down;
            
            s.cn = lookup2d_interp(s.alphax, s.mach, "cn", obj.dbfile);
            s.ca = lookup2d_interp(s.alphax, s.mach, "ca", obj.dbfile);
        
            alpha = deg2rad(s.alphax);
            s.cd = s.cn*sin(alpha) + s.ca*cos(alpha);
            s.cl = s.cn*cos(alpha) - s.ca*sin(alpha);
            s.cl_v_cd = s.cl/s.cd;
            
            % Computing lift alpha derivative with bounded lookups
            cnp = lookup2d_interp(alpha_up, s.mach, "cn", obj.dbfile);
            cnn = lookup2d_interp(alpha_down, s.mach, "cn", obj.dbfile);
            cap = lookup2d_interp(alpha_up, s.mach, "ca", obj.dbfile);
            can = lookup2d_interp(alpha_down, s.mach, "ca", obj.dbfile);
            
            cna = (cnp-cnn)/actual_delta;
            caa = (cap-can)/actual_delta;
            s.cla = cna*cos(alpha) - caa*sin(alpha);
        end

        function FSPV = forces(obj, s)
            phimv = deg2rad(s.phimvx);
            alpha = deg2rad(s.alphax);

            fspv1 = (-s.pdynmc*obj.area*s.cd+s.thrust*cos(alpha))/s.mass;
            fspv2 = sin(phimv)*(s.pdynmc*obj.area*s.cl+s.thrust*sin(alpha))/s.mass;
            fspv3 = -cos(phimv)*(s.pdynmc*obj.area*s.cl+s.thrust*sin(alpha))/s.mass;

            FSPV = [fspv1; fspv2; fspv3];
        end

        function prop(obj, s, int_step, time)
            c = get_constants();

            AGRAV = c.AGRAV;

            s.thrst_req = 0;
            if obj.mprop > 0
                s.cin = lookup2d_interp(s.alphax, s.mach, "cin", obj.dbfile);
                
                % temp = lookup2d_interp(s.alphax, s.mach, "cin", obj.dbfile);
                if obj.mprop == 1
                    s.phi = obj.phi_const;
                    s.spi = lookup_spi(s.mach, s.phi, s.alphax, obj.dbfile);
                    s.thrust = .0676*s.phi*s.rho*s.spi*AGRAV*s.dvbe*s.cin*obj.aintake;
                end
                if obj.mprop == 2
                    if s.phi < obj.phi_min
                        s.phi = obj.phi_min;
                    end
                    if s.phi > obj.phi_max
                        s.phi = obj.phi_max;
                    end
                    s.phi_l = s.phi/.0676;

                    s.phi_l = max(.5, min(1.2, s.phi_l));

                    s.spi = lookup3d_interp(s.mach, s.phi_l, s.alphax, obj.dbfile);
                    thrst_stoch = .0676*s.spi*AGRAV*s.rho*s.dvbe*s.cin*obj.aintake;
                    thrst_req = obj.area*s.ca*obj.qhold;
                    phi_req = thrst_req/thrst_stoch;

                    if thrst_stoch <= 0
                        phi_req = obj.phi_min;
                    else
                        phi_req = thrst_req/thrst_stoch;
                    end

                    gainq = 2*s.mass/(s.rho*s.dvbe*thrst_stoch*obj.tq);
                    ephi = gainq*(obj.qhold-s.pdynmc);

                    s.phis = s.phi;
                    s.phi = phi_req+ephi;

                    phisd_new = (s.phi-s.phis)/obj.tlag;
                    s.phis = int_simp(phisd_new, s.phisd, s.phis, int_step);
                    s.phisd = phisd_new;
                    s.phi = s.phis;

                    if s.phi<obj.phi_min
                        s.phi = obj.phi_min;
                    end
                    if s.phi>obj.phi_max
                        s.phi = obj.phi_max;
                    end
                    s.phi_l = s.phi/.0676;
                    s.phi_l = max(.5, min(1.2, s.phi_l));
                    s.spi = lookup_spi(s.mach, s.phi_l, s.alphax, obj.dbfile);
                    s.thrust = .0676*s.phi*s.spi*AGRAV*s.rho*s.dvbe*s.cin*obj.aintake;
                    if s.thrust <= 0
                        warning('Negative thrust computed, check model')
                        s.thrust = 0;
                    end
                end
                if obj.mprop == 3
                    s.spi = lookup_spi(s.mach, s.phi/.0676, s.alphax, obj.dbfile);
                    s.thrust = .0676*s.phi*s.spi*AGRAV*s.rho*s.dvbe*s.cin*obj.aintake;
                end
                %calculate fuel use
                fmassd_next = s.thrust/(s.spi*AGRAV); %mass flow
                s.fmasse = int_simp(fmassd_next, s.fmassd, s.fmasse, int_step);
                s.fmassd = fmassd_next;

                s.mass = obj.mass0 - s.fmasse;
                s.fmassr = obj.fmass0 - s.fmasse;

                if s.fmassr <= 0
                    obj.mprop = 0;
                end
            end
            if obj.mprop == 0
                s.fmassd = 0;
                s.thrust = 0;
            end
        end

        function control(obj, s, int_step, time)
            if obj.mcontrol == 6
                obj.ancomx = obj.control_altitude(s, s.altcom, s.phimvx);
                s.altcom
                obj.ancomx
                s.alphax = obj.control_load(s, obj.ancomx, int_step);
            end

            s.TBV = cadtbv(deg2rad(s.phimvx), deg2rad(s.alphax));
            TVG = s.TGV';
            s.TBG = s.TBV*TVG;
        end

        function alpx = control_load(obj, s, ancomx, int_step)
            
            
            alpha = deg2rad(s.alphax);
            phimv = deg2rad(s.phimvx);
            s.TBV = cadtbv(phimv, alpha);
            FSPB = s.TBV*s.FSPV;
            
            if ancomx > obj.anposlimx
                ancomx = obj.anposlimx;
            end
            if ancomx < obj.anneglimx
                ancomx = obj.anneglimx;
            end

            fspb3 = FSPB(3,1);
            anx = -fspb3/s.gravity;
            
            
            eanx = ancomx-anx;
            
            

            tip = s.dvbe*s.mass/(s.pdynmc*obj.area*s.cla/(pi/180)+s.thrust);
            
            
            if obj.ta > 0
                gr = obj.gacp*tip/s.dvbe;
                
                gi = gr/obj.ta;
                xid_new = gi*eanx;
                s.xi = int_simp(xid_new, s.xid, s.xi, int_step);
                s.xid = xid_new;
            else
                s.xi = 0;
                gr = 0;
            end
            
            
            
            qq = gr*eanx+s.xi;
            

            alpd_new = qq-s.alp/tip;
            
            s.alp = int_simp(alpd_new, s.alpd, s.alp, int_step);
            s.alpd = alpd_new;
            
            
            alpx = rad2deg(s.alp);
            
            
            
            if alpx > obj.alpposlimx
                alpx = obj.alpposlimx;
            end
            if alpx < obj.alpneglimx
                alpx = obj.alpneglimx;
            end
            
        end

        function ancomx = control_altitude(obj, s, altcom, phimvx)
          
            
            ealt = obj.gh*(altcom-s.alt);

            if ealt > obj.altdlim
                ealt = obj.altdlim;
            end
            if ealt < -obj.altdlim
                ealt = -obj.altdlim;
            end

            altd = -s.VBEG(3,1);
            
            
            ancomx = (obj.gv*(ealt-altd)/s.gravity+1)*(1/cos((pi/180)*phimvx));

            if ancomx > obj.anposlimx
                ancomx = obj.anposlimx;
            end
            if ancomx < obj.anneglimx
                ancomx = obj.anneglimx;
            end
        end
    end
end