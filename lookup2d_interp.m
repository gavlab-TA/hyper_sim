function dum = lookup2d_interp(val1, val2, wanted)
    dbfile = 'C:\Users\brayd\GAVLab\matlab\Hyper.db';
    conn = sqlite(dbfile);
    
    %round up/down
    val1_up = ceil(val1/2)*2;
    val1_down = floor(val1/2)*2;
    val2_up = ceil(2*val2)/2;
    val2_down = floor(2*val2)/2;
    if val1_up == val1
        val1_up = val1 + 2;
    end
    if val2_up == val2
        val2_up = val2 + .5;
    end
    
    %format for query
    val1_up_str = sprintf('%.1f', val1_up);
    val1_down_str = sprintf('%.1f', val1_down);
    val2_up_str = sprintf('%.1f', val2_up);
    val2_down_str = sprintf('%.1f', val2_down);
    
    %queries
    sqlquery_uu = "SELECT " + wanted + " FROM " + wanted + " WHERE alphax == " + val1_up_str + ...
               " AND mach == " + val2_up_str;
    
    sqlquery_dd = "SELECT " + wanted + " FROM " + wanted + " WHERE alphax == " + val1_down_str + ...
               " AND mach == " + val2_down_str;
    
    uu = fetch(conn, sqlquery_uu);
    dd = fetch(conn, sqlquery_dd);
    
    uu = str2double(uu{1,1});
    dd = str2double(dd{1,1});
    
    sqlquery_ud = "SELECT " + wanted + " FROM " + wanted + " WHERE alphax == " + val1_up_str + ...
               " AND mach == " + val2_down_str;
    
    sqlquery_du = "SELECT " + wanted + " FROM " + wanted + " WHERE alphax == " + val1_down_str + ...
               " AND mach == " + val2_up_str;
    
    ud = fetch(conn, sqlquery_ud);
    du = fetch(conn, sqlquery_du);
    
    ud = str2double(ud{1,1});
    du = str2double(du{1,1});

    x_grid = [val1_down, val1_up];
    y_grid = [val2_down, val2_up];

    matrix = [dd, ud; du, uu];

    xi = val1;
    yi = val2;

    dum = interp2(x_grid, y_grid, matrix, xi, yi);
    close(conn);
end



