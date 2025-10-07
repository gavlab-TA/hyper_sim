function dum = lookup_spi(val1, val2, val3)
    % --- Main lookup function for spi that handles both interpolation and extrapolation ---
    % It acts as a wrapper. If inputs are in bounds, it calls the original
    % lookup3d_interp. If inputs are out of bounds, it sets up the
    % corner points for linear extrapolation and then uses the existing
    % trilinear_interp function to calculate the result.

    % Define database boundaries from your Hyper.db file
    mach_bounds = [4.0, 7.0];
    phi_bounds = [0.5, 1.2];
    alpha_bounds = [-4.0, 6.0];

    % Check if all values are within the interpolation range
    is_inside = (val1 >= mach_bounds(1) && val1 <= mach_bounds(2)) && ...
                (val2 >= phi_bounds(1) && val2 <= phi_bounds(2)) && ...
                (val3 >= alpha_bounds(1) && val3 <= alpha_bounds(2));

    if is_inside
        % If inside, use the original interpolation function directly
        dum = lookup3d_interp(val1, val2, val3);
        return;
    else
        % If outside, we set up the query points for extrapolation
        
        dbfile = 'Hyper.db';
        conn = sqlite(dbfile, 'readonly');

        % --- Determine bracketing values for val1 (Mach) ---
        if val1 > mach_bounds(2)
            val1_up = 7.0; val1_down = 6.5; % Use top two points
        elseif val1 < mach_bounds(1)
            val1_up = 4.5; val1_down = 4.0; % Use bottom two points
        else % Value is inside this specific boundary
            val1_up = ceil(val1*2)/2; val1_down = floor(val1*2)/2;
            if val1_up == val1_down, val1_up = val1_down + 0.5; end
        end

        % --- Determine bracketing values for val2 (phi) ---
        if val2 > phi_bounds(2)
            val2_up = 1.2; val2_down = 1.1;
        elseif val2 < phi_bounds(1)
            val2_up = 0.6; val2_down = 0.5;
        else
            val2_up = ceil(val2*10)/10; val2_down = floor(val2*10)/10;
            if val2_up == val2_down, val2_up = val2_down + 0.1; end
        end

        % --- Determine bracketing values for val3 (alpha) ---
        if val3 > alpha_bounds(2)
            val3_up = 6.0; val3_down = 4.0;
        elseif val3 < alpha_bounds(1)
            val3_up = -2.0; val3_down = -4.0;
        else
            val3_up = ceil(val3/2)*2; val3_down = floor(val3/2)*2;
            if val3_up == val3_down, val3_up = val3_down + 2.0; end
        end

        % Perform the same lookup as your original function, but with our
        % potentially modified corner points.
        val2_up_str = sprintf('%.1f', val2_up);
        val2_down_str = sprintf('%.1f', val2_down);

        q1 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_down + " AND phi == " + val2_down_str + " AND alphax_deg == " + val3_down;
        q2 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_down + " AND phi == " + val2_up_str + " AND alphax_deg == " + val3_down;
        q3 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_up + " AND phi == " + val2_down_str + " AND alphax_deg == " + val3_down;
        q4 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_up + " AND phi == " + val2_up_str + " AND alphax_deg == " + val3_down;
        q5 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_down + " AND phi == " + val2_down_str + " AND alphax_deg == " + val3_up;
        q6 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_down + " AND phi == " + val2_up_str + " AND alphax_deg == " + val3_up;
        q7 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_up + " AND phi == " + val2_down_str + " AND alphax_deg == " + val3_up;
        q8 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_up + " AND phi == " + val2_up_str + " AND alphax_deg == " + val3_up;

        spi_cell_1 = fetch(conn, q1); spi_cell_2 = fetch(conn, q2);
        spi_cell_3 = fetch(conn, q3); spi_cell_4 = fetch(conn, q4);
        spi_cell_5 = fetch(conn, q5); spi_cell_6 = fetch(conn, q6);
        spi_cell_7 = fetch(conn, q7); spi_cell_8 = fetch(conn, q8);

        close(conn);

        % Build the matrix using the corrected indices from last time
        val_matrix = zeros(2, 2, 2);
        val_matrix(1,1,1) = str2double(spi_cell_1{1,1}); val_matrix(2,1,1) = str2double(spi_cell_3{1,1});
        val_matrix(1,2,1) = str2double(spi_cell_2{1,1}); val_matrix(2,2,1) = str2double(spi_cell_4{1,1});
        val_matrix(1,1,2) = str2double(spi_cell_5{1,1}); val_matrix(2,1,2) = str2double(spi_cell_7{1,1});
        val_matrix(1,2,2) = str2double(spi_cell_6{1,1}); val_matrix(2,2,2) = str2double(spi_cell_8{1,1});

        x_grid = [val1_down, val1_up];
        y_grid = [val2_down, val2_up];
        z_grid = [val3_down, val3_up];

        % Use your original, unclamped inputs for the calculation
        xi = val1; yi = val2; zi = val3;

        % Call your original trilinear interpolation function.
        % It will extrapolate automatically because the normalized coordinates will be < 0 or > 1.
        dum = trilinear_interp(x_grid, y_grid, z_grid, val_matrix, xi, yi, zi);
    end
end
