function [phicx, ancomx, alcomx] = guidance(mguidance, grav, phicx, anposlimx, anneglimx, allimx, range_go)
    APNB = zeros(3,1);
    ALGV = zeros(3,1);
    APGV = zeros(3,1);

    %returning if no guidance
    if mguidance == 0
        alcomx = 0;
        ancomx = 0;
    elseif mguidance == 30
        ALGV = guidance_line();
        alcomx = ALGV(2,1)/grav;
    elseif mguidance == 3
        ALGV = guidance_line();
        alcomx = 0;
        ancomx = -ALGV(3,1)/grav;
    elseif mguidance == 33
        ALGV = guidance_line();
        alcomx = ALGV(2,1)/grav;
        ancomx = -ALGV(3,1)/grav;
    elseif mguidance == 60
        APNB = guidance_pronav();
        alcomx = APNB(2,1)/grav;
        ancomx = 0;
    elseif mguidance == 6
        APNB = guidance_pronav();
        alcomx = 0;
        ancomx = -APNB(3,1)/grav;
    elseif mguidance == 66
        APNB = guidance_pronav();
        alcomx = APNB(2,1)/grav;
        ancomx = -APNB(3,1)/grav;
    elseif mguidance == 43
        ALGV = guidance_line();
        APGV = guidance_point();
        alcomx = APGV(2,1)/grav;
        ancomx = -ALGV(3,1)/grav;
    elseif mguidance == 40
        APGV = guidance_point();
        alcomx = APGV(2,1)/grav;
    elseif mguidance == 44
        APGV = guidance_point();
        alcomx = APGV(2,1)/grav;
        ancomx = APGV(3,1)/grav;
    elseif mguidance == 70
        phicx = guidance_arc();
    end

    %limiting normal load factor command
    if ancomx>anposlimx
        ancomx = anposlimx;
    end
    if ancomx<anneglinx
        ancomx = anneglimx;
    end
    
    %limiting lateral load factor command
    if alcomx>allimx
        alcomx = allimx;
    end
    if alcomx<-allimx
        alcomx = -allimx;
    end
end