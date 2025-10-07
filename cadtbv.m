function mat = cadtbv(phi, alpha)
    sa = sin(alpha);
    ca = cos(alpha);
    sp = sin(phi);
    cp = cos(phi);

    mat = [ca, sp*sa, -cp*sa;
           0, cp, sp;
           sa, -sp*ca, cp*ca];
end