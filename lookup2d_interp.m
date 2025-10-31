function dum = lookup2d_interp(val1, val2, wanted, dbfile)

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
    
    y22 = str2double(uu{1,1});
    y11 = str2double(dd{1,1});
    
    sqlquery_ud = "SELECT " + wanted + " FROM " + wanted + " WHERE alphax == " + val1_up_str + ...
               " AND mach == " + val2_down_str;
    
    sqlquery_du = "SELECT " + wanted + " FROM " + wanted + " WHERE alphax == " + val1_down_str + ...
               " AND mach == " + val2_up_str;
    
    ud = fetch(conn, sqlquery_ud);
    du = fetch(conn, sqlquery_du);
    
    y21 = str2double(ud{1,1});
    y12 = str2double(du{1,1});

    

    dum = interpolate2(val1_down, val1_up, val2_down, val2_up, val1, val2, y11, y12, y21, y22);
    close(conn);
end


