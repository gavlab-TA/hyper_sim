function [phis, phisd, fmasse, fmassd, phi, mass, thrust, mprop, cin, thrst_stoch, spi, mass_flow, fmassr, thrst_req] = prop(mass, fmassr, phis, phisd, fmasse, fmassd, time, rho, pdynmc, mach, dvbe, ca, area, alphax, int_step, mprop, aintake, qhold, tq, tlag, phi_prev)
    i = get_init(); % <--- Get init structure here
    c = get_constants();
    AGRAV = c.AGRAV;
    time

    % --- FIX 1: Define constants (like phi_min) outside the 'time == 0' block ---
    phi_min = i.phi_min; 
    phi_max = i.phi_max;
    mass0 = i.mass0;
    fmass0 = i.fmass0;
    % --------------------------------------------------------------------------

    if time == 0
        phi_const = 0;
        phid = 0;
        phis = 0;
        phisd = 0;
        
        phi = 0;
        
        cin = 0;
        
        fmasse = 0;
        fmassd = 0;
        thrst_stoch = 0;
        spi = 0;
        thrust = 0;
        mass_flow = 0;
        fmassr = 0;
        
        mprop = i.mprop;
        aintake = i.aintake;
        qhold = i.qhold;
        tq = 10;
        tlag = 1;
        mass = mass0;
        phi = phi_min;
    else
        % FIX 2: Ensure phi is set from the previous time step for time > 0
        phi = phi_prev;
    end
    
    thrst_req = 0; % Ensure output variable is defined
    
    if mprop > 0

        if mprop
            cin = lookup2d_interp(alphax, mach, "cin");
            spi = lookup_spi(mach, phi, alphax);
            phi
        end
        
        if mprop == 1
            thrust = .0676*phi_const*spi*AGRAV*rho*dvbe*cin*aintake;
        end

        if mprop == 2
            thrst_stoch = .0676*spi*AGRAV*rho*dvbe*cin*aintake;
            thrst_req = area*ca*qhold;
            phi_req = thrst_req/thrst_stoch;
            gainq = 2*mass/(rho*dvbe*thrst_stoch*tq);
            ephi = gainq*(qhold-pdynmc);
   
            phis = phi;
            phi = phi_req+ephi;
            
            phisd_new = (phi-phis)/tlag;
            phis = int_simp(phisd_new, phisd, phis, int_step);
            phisd = phisd_new;
            phi = phis;

            if phi<phi_min
                phi = phi_min;
            end
            if phi>phi_max
                phi = phi_max;
            end
            phi
            phi_l = phi/.0676;
            mach
            phi_l
            alphax
            spi = lookup_spi(mach, phi_l, alphax);
            thrust = .0676*phi*spi*AGRAV*rho*dvbe*cin*aintake;
        end

        if mprop == 3
            spi = lookup_spi(mach, phi/.0676, alphax);
            thrust = .0676*phi*spi*AGRAV*rho*dvbe*cin*aintake;
        end

        % calculate fuel consumption
        fmassd_next = thrust/(spi*AGRAV); %mass flow
        fmasse = int_simp(fmassd_next, fmassd, fmasse, int_step);
        fmassd = fmassd_next;

        mass = mass0 - fmasse;
        fmassr = fmass0-fmasse;
        
        mass_flow = thrust/(AGRAV*spi);


        %shutdown when empty
        if fmassr <= 0
            mprop = 0;

        end
    end

    if mprop == 0
        fmassd = 0;
        thrust = 0;
    end
end
