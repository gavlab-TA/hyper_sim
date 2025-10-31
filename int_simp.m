function out = int_simp(dydx_new, dydx, y, int_step)
    out = y+(dydx_new+dydx)*int_step/2;
end