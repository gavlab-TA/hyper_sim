
function dum = lookup3d_interp(val1, val2, val3, dbfile)
    
    conn = sqlite(dbfile, 'readonly');


    %round up/down
    val1_up = ceil(val1*2)/2;
    val1_down = floor(val1*2)/2;
    val2_up = ceil(10*val2)/10;
    val2_down = floor(10*val2)/10;
    val3_up = ceil(val3/2)*2;
    val3_down = floor(val3/2)*2;
    if val3_up == val3
        val3_up = val3 + 2;
    end
    if val1_up == val1
        val1_up = val1 + .5;
    end
    if val2_up == val2
        val2_up = val2 + .1;
    end

    
    
    %format for query
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

    spi_cell_1 = fetch(conn, q1);
    spi_cell_2 = fetch(conn, q2);
    spi_cell_3 = fetch(conn, q3);
    spi_cell_4 = fetch(conn, q4);
    spi_cell_5 = fetch(conn, q5);
    spi_cell_6 = fetch(conn, q6);
    spi_cell_7 = fetch(conn, q7);
    spi_cell_8 = fetch(conn, q8);

    close(conn);


    
    y111 = str2double(spi_cell_1{1,1}); % (down, down, down)
    y112 = str2double(spi_cell_3{1,1}); % (down, up, down)
    y121 = str2double(spi_cell_2{1,1}); % (up, down, down)
    y122 = str2double(spi_cell_4{1,1}); % (up, up, down)
    y211 = str2double(spi_cell_5{1,1}); % (down, down, up)
    y212 = str2double(spi_cell_7{1,1}); % (down, up, up)
    y221 = str2double(spi_cell_6{1,1}); % (up, down, up)
    y222 = str2double(spi_cell_8{1,1}); % (up, up, up)

    dum = interpolate3(val1_down, val1_up, val2_down, val2_up, val3_down, val3_up, val1, val2, val3, y111, y112, y121, y122, y211, y212, y221, y222);
end
