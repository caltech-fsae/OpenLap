clc;
clear;
%%

addpath('C:\Users\Isaac\Documents\Lap Simulations');
addpath('C:\Users\Isaac\Documents\Laclose p Simulations\Battery Simulation');

%%

run('OpenTRACK.m');
run('OpenVEHICLE.m');
run('OpenLAP.m');
run('initialization.m');

for i = 2:race.size
    
    battery.voltage(i) = battery.series*getCellVoltage(battery.SOC(i-1));
    battery.dcir(i) = (battery.series/battery.parallel)*getCellDCIR(battery.voltage(i)/battery.series);
    
    battery.current(i) = abs((battery.voltage(i)-sqrt((battery.voltage(i)^2)-4*battery.dcir(i).*race.power(i)))./(2*battery.dcir(i)));
    
    if isnan(battery.current(i))
        battery.current(i) = race.power(i).battery.voltage(i);
    end
    
    battery.voltage_true(i) = battery.voltage(i) - battery.dcir(i)*battery.current(i);
    battery.SOC(i) = max(0,battery.SOC(i-1)-(battery.current(i)*race.timestep(i))/(battery.parallel*cell.charge));
    
    coolant.heating(i) = (battery.current(i)^2)*battery.dcir(i);
    coolant.cooling(i) = Radiator_Cooling_Sim(race.speed(i),coolant.temp(i-1),30);
    
    coolant.temp(i) = coolant.temp(i-1)+(race.timestep(i)/(coolant.cp*coolant.mass))*(coolant.heating(i)-coolant.cooling(i));
    
end

run('battery_summary.m');