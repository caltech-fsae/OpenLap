%% import data in from openlap sim object and then multiplies as needed

laps = 12;

for i = 1:laps
    if i == 1
        race = struct();
        race.power = sim.engine_power.data;
        race.speed = sim.speed.data;
        race.time = sim.time.data;
    else
        race.power = vertcat(race.power,sim.engine_power.data);
        race.speed = vertcat(race.speed,sim.speed.data);
        race.time = vertcat(race.time,(sim.time.data+race.time(end)));
    end    
end

%multiplier for efficiency
race.power = race.power/(veh.n_final*veh.n_gearbox*veh.n_primary*veh.n_thermal);
race.speed = race.speed;


timeshift = vertcat(0,race.time(1:end-1));
race.timestep = race.time-timeshift;

race.size = size(race.time,1);

%% battery

battery = struct();

%initial state and battery characterisitics
battery.initialSOC = 1;
battery.initialTemp = 30;
battery.parallel = 6;
battery.series = 96;

battery.SOC          = zeros(race.size,1);
battery.voltage      = zeros(race.size,1);
battery.voltage_true = zeros(race.size,1);
battery.dcir         = zeros(race.size,1);
battery.current      = zeros(race.size,1);
battery.temp         = zeros(race.size,1);

battery.SOC(1) = battery.initialSOC;
battery.temp(1) = battery.initialTemp;

%% cell

cell = struct();

cell.charge = 10800; %coulombs

%% coolant

coolant = struct();

coolant.intialTemp = 30;
coolant.cp = 4186;
coolant.mass = 1;

coolant.temp = zeros(race.size,1);
coolant.heating = zeros(race.size,1);
coolant.cooling = zeros(race.size,1);

coolant.temp(1) = coolant.intialTemp;