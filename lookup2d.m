function [z] = lookup2d(csvpath, x, y)

    x_up = ceil(x);
    x_down = floor(x);
    y_up = ceil(y*2)/2;
    y_down = floor(y*2)/2;

    table = readtable(csv_path);

    


    
end