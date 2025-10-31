function mat = cadtbv(phi, alpha)
    a = sin(alpha);
    b = cos(alpha);
    c = sin(phi);
    d = cos(phi);

    mat = [b, c*a, -d*a;
           0, d, c;
           a, -c*b, d*b];
end