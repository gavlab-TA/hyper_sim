function dum = lookup3d_interp(val1, val2, val3)
    dbfile = 'C:\Users\brayd\GAVLab\matlab\Hyper.db';
    conn = sqlite(dbfile, 'readonly');

    val1_clamped = max(min(val1, 7.0), 4.0);  % Clamp Mach between 4.0 and 7.0
    val2_clamped = max(min(val2, 1.2), 0.5);  % Clamp phi between 0.5 and 1.2
    val3_clamped = max(min(val3, 6.0), -4.0); % Clamp alpha between -4.0 and 6.0

    %round up/down
    val1_up = ceil(val1*2)/2;
    val1_down = floor(val1*2)/2;
    val2_up = ceil(10*val2)/10;
    val2_down = floor(10*val2)/10;
    val3_up = ceil(val3/2)*2;
    val3_down = floor(val3/2)*2;

    % Handle cases where input is exactly on a grid point, which would make up==down
    if val1_up == val1_down
        val1_up = val1_down + 0.5;
    end
    if val2_up == val2_down
        val2_up = val2_down + 0.1;
    end
    if val3_up == val3_down
        val3_up = val3_down + 2.0;
    end

    %format for query
    val2_up_str = sprintf('%.1f', val2_up);
    val2_down_str = sprintf('%.1f', val2_down);

    q1 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_down + " AND phi == " + val2_down + " AND alphax_deg == " + val3_down;
    q2 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_down + " AND phi == " + val2_up + " AND alphax_deg == " + val3_down;
    q3 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_up + " AND phi == " + val2_down + " AND alphax_deg == " + val3_down;
    q4 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_up + " AND phi == " + val2_up + " AND alphax_deg == " + val3_down;
    q5 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_down + " AND phi == " + val2_down + " AND alphax_deg == " + val3_up;
    q6 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_down + " AND phi == " + val2_up + " AND alphax_deg == " + val3_up;
    q7 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_up + " AND phi == " + val2_down + " AND alphax_deg == " + val3_up;
    q8 = "SELECT spi_sec FROM spi WHERE Mach == " + val1_up + " AND phi == " + val2_up + " AND alphax_deg == " + val3_up;

    spi_cell_1 = fetch(conn, q1);
    spi_cell_2 = fetch(conn, q2);
    spi_cell_3 = fetch(conn, q3);
    spi_cell_4 = fetch(conn, q4);
    spi_cell_5 = fetch(conn, q5);
    spi_cell_6 = fetch(conn, q6);
    spi_cell_7 = fetch(conn, q7);
    spi_cell_8 = fetch(conn, q8);

    close(conn);


    val_matrix = zeros(2, 2, 2);
    val_matrix(1,1,1) = str2double(spi_cell_1{1,1}); % (down, down, down)
    val_matrix(2,1,1) = str2double(spi_cell_3{1,1}); % (down, up, down)
    val_matrix(1,2,1) = str2double(spi_cell_2{1,1}); % (up, down, down)
    val_matrix(2,2,1) = str2double(spi_cell_4{1,1}); % (up, up, down)
    val_matrix(1,1,2) = str2double(spi_cell_5{1,1}); % (down, down, up)
    val_matrix(2,1,2) = str2double(spi_cell_7{1,1}); % (down, up, up)
    val_matrix(1,2,2) = str2double(spi_cell_6{1,1}); % (up, down, up)
    val_matrix(2,2,2) = str2double(spi_cell_8{1,1}); % (up, up, up)


    x_grid = [val1_down, val1_up];
    y_grid = [val2_down, val2_up];
    z_grid = [val3_down, val3_up];


    xi = val1;
    yi = val2;
    zi = val3;


    dum = trilinear_interp(x_grid, y_grid, z_grid, val_matrix, xi, yi, zi);
end