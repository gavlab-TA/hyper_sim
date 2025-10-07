%user input parameters
function [vehicle_list, module_list, sim_time, end_time, num_vehicles, ...
          num_modules, plot_step, int_step, scrn_step, com_step, traj_step, ...
          options, ftabout, plot_ostream_list, combus, status, num_hyper, ...
          num_target, num_satellite, ftraj, title, traj_merge] = input()
    
    
% &vehicle_list =	vehicle array - list of vehicle objects 
% 								and their respective type - hyper
% 								estabished by global function 'set_obj_type'
% module_list = module array - list of modules and their calling sequence
% 								established by global function 'order_modules'
% sim_time = simulation time; called 'time' in output		 
% end_time = time to stop the simulation - read from 'input.asc' 
% 								by global function 'acquire_end'
% num_vehicles = total number of vehicles - read from 'input.asc' (VEHICLES #)
% 								by global function 'number_vehicles'  				
% num_modules = total number of modules - read from 'input.asc'
% 								by global function 'number_modules'
% plot_step = output writing interval to file 'traj.asc' - sec
% 								read from 'input.asc' by global function 'acquire_timing'  				
% int_step = integration step 
% 								read from 'input.asc' by global function 'acquire_timing'  				
% scrn_step = output writing interval to console - sec  				
% 								read from 'input.asc' by global function 'acquire_timing'
% scrn_step = output interval to console
% com_step = output interval to communication bus 'combus'
% traj_step = output interval to 'traj.asc'
% *options = output option list
% &ftabout = output file-stream to 'tabout.asc'
% *plot_ostream_list = output file-steam list of 'ploti.asc' for each individual hyper 
% 								hyper object
% *combus = commumication bus
% *status = health of vehicles
% num_hyper = number of 'Hyper' objects
% num_target = number of 'Target' objects
% num_satellite = number of 'Satellite' objects
% &ftraj = output file-stream to 'traj.asc'
% *title = idenfication of run
% traj_merge = flag for merging runs in 'traj.asc'

vehicle_list =
module_list = ["enviorment", "aero", "prop", "forces", "newton", "targeting", "seeker", "guidance", "control", "intercept"];
sim_time =
end_time = 1300;
num_vehicles = 4;
num_modules = 10;
plot_step = .2;
int_step = .01;
scrn_step = 50;
traj_step = 1;
com_step =
options = 
ftabout =
flot_ostream_list =
combus =
status =
num_hyper =
num_target =
num_satellite =
ftraj = 
title =
traj_merge =

end
