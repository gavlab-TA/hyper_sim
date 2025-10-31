function tr = mat2tr(psivg, thtvg)
    a = cos(psivg);
    b = sin(psivg);
    c = cos(thtvg);
    d = sin(thtvg);

    tr = [a*c, c*b, -d;
          -b, a, 0;
          d*a, b*d, c];
end