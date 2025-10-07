function dum = trilinear_interp(x_grid, y_grid, z_grid, val_matrix, xi, yi, zi)
    
    %normalize the coords to a unit cube
    x_norm = (xi - x_grid(1)) / (x_grid(2) - x_grid(1));
    y_norm = (yi - y_grid(1)) / (y_grid(2) - y_grid(1));
    z_norm = (zi - z_grid(1)) / (z_grid(2) - z_grid(1));

    c00 = val_matrix(1,1,1) * (1 - x_norm) + val_matrix(2,1,1) * x_norm;
    c10 = val_matrix(1,2,1) * (1 - x_norm) + val_matrix(2,2,1) * x_norm;
    c01 = val_matrix(1,1,2) * (1 - x_norm) + val_matrix(2,1,2) * x_norm;
    c11 = val_matrix(1,2,2) * (1 - x_norm) + val_matrix(2,2,2) * x_norm;

    c0 = c00 * (1 - y_norm) + c10 * y_norm;
    c1 = c01 * (1 - y_norm) + c11 * y_norm;

    dum = c0 * (1 - z_norm) + c1 * z_norm;
end