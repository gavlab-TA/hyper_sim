clear;
clc;
close all;

% table = readtable("plot.csv");

%example of demo 3.2
i = input();
%%tables
i.dbfile = "Hyper.db";

%%initial conditions @ VB_AFB
i.lonx = -120.6;
i.latx = 34.7;
i.alt = 10000;
i.psivgx = 90;
i.thtvgx = 0;
i.dvbe = 1277;
i.alphax = 0;
i.phimvx = 0;

%%Aerodynamics
i.area = 11.6986;

%%Mass properties and propulsion
i.mprop = 2;
i.aintake = .184;
i.mass0 = 1976;
i.fmass0 = 624;
i.phi_min = .5;
i.phi_max = 1.2;
i.qhold = 72000;
i.tq = 10;
i.tlag = 1;

i.mcontrol = 6;
i.altcom = 10000;
i.altdlim = 50;
i.gh = .2;
i.gv = .3;

i.anposlimx = 2;
i.anneglimx = -1;
gacp = 10;
ta = .8;
alpposlimx = 6;
alpneglimx = -4;

%%set rest of params

v = Vehicle(i);
s = State(i);


%main loop
dt = .5;
t_end = 30;
num_steps = floor(t_end/dt) + 1;
x1 = zeros(num_steps, 1);
x2 = zeros(num_steps,1);
x3 = zeros(num_steps,1);
x4 = zeros(num_steps,1);
x5 = zeros(num_steps,1);
x6 = zeros(num_steps,1);
x7 = zeros(num_steps,1);
x8 = zeros(num_steps, 1);
x9 = zeros(num_steps,1);
x10 = zeros(num_steps,1);
y = zeros(num_steps,1);
w = 1;
for time = 0:dt:100
    
    if time > 10
        s.altcom = 10050;
    end
    if time > 60
        s.altcom = 10000;
    end
    s.update_env(time);
    
    v.aero(s);
    v.prop(s, dt, time);
    s.FSPV = v.forces(s);
    v.control(s, dt, time);
    
    s.update_dynamics(s.FSPV, dt, time);
    
    x2(w) = s.alt;
    x3(w) = s.dvbe;
    x4(w) = s.ground_range;
    x5(w) = s.fmassr;
    x6(w) = s.latx;
    x7(w) = s.lonx;
    x8(w) = s.cl;
    x9(w) = s.cd;
    x10(w) = s.phi;
    y(w) = time;
    
    w = w+1;
    
end
% x1r = table.alt;
% x2r = table.dvbe;
% x3r = table.thrust;
% x4r = table.ground_range;
% x5r = table.fmassr;
% x6r = table.latx;
% x7r = table.lonx;
% yr = table.time;





out = [y, x2, x3, x4, x5, x6, x7, x8, x9, x10];

writematrix(out, 'out.csv');