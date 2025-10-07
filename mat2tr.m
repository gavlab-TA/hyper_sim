function [output] = mat2tr(psivg, thtvg)
    cpsi = cos(psivg);
    spsi = sin(psivg);
    ctht = cos(thtvg);
    stht = sin(thtvg);
 
    output = [cpsi*ctht, ctht*spsi, -stht;
              -spsi, cpsi, 0;
              stht*cpsi, spsi*stht, ctht];  
end