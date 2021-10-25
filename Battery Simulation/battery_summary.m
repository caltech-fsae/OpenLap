figure();
sgtitle("Battery Overview During Race");

subplot(5,1,1)
hold on;
plot(race.time(:),battery.SOC(:));
xlabel('Time [Seconds]');
ylabel('State of Charge');

subplot(5,1,2)
hold on;
plot(race.time(:),battery.voltage(:));
xlabel('Time [Seconds]');
ylabel('Accumulator Voltage [V]');

ss = csaps(race.time(:),battery.current(:),0.5);
subplot(5,1,3)
hold on;
fnplt(ss);
xlabel('Time [Seconds]');
ylabel('Accumulator Current [A]');

subplot(5,1,4)
hold on;
plot(race.time(:),coolant.temp(:));
xlabel('Time [Seconds]');
ylabel('Coolant Temperature [C]');


subplot(5,1,5)
hold on;
plot(race.time(:),0.001*cumsum(coolant.heating(:).*race.timestep(:)));
xlabel('Time [Seconds]');
ylabel('Rejected Heat [kJ]');

%%
rpower = resample(race.power,race.time);
rcurrent = resample(battery.current,race.time);
rheating = resample(coolant.heating,race.time);
rt = linspace(race.time(1),race.time(end),size(race.time,1));
dt = rt(2)-rt(1);

powerProfile = zeros(size(dt,1));
currentProfile = zeros(size(dt,1));
heatingProfile = zeros(size(dt,1));
td = dt*(1:size(rt,2));

for i = 1:size(rt,2)
    powerProfile(i) = max(movmean(rpower,i))/(battery.parallel*battery.series);
    currentProfile(i) = max(movmean(rcurrent,i))/battery.parallel;
    heatingProfile(i) = max(movmean(rheating,i))/(battery.parallel*battery.series);
end

%condition data
for i = 1:size(rt,2)-1
    powerProfile(i) = max(powerProfile(i), max(powerProfile(i+1:end)));
    currentProfile(i) = max(currentProfile(i), max(currentProfile(i+1:end)));
    heatingProfile(i) = max(heatingProfile(i), max(heatingProfile(i+1:end)));
end

figure;
sgtitle("Cell Power and Current Dynamics");
subplot(1,3,1)
semilogx(td(:),powerProfile(:));
hold on
ylabel('Power Draw per Cell (W)');
xlabel('Duration (s)');
grid
subplot(1,3,2)
semilogx(td(:),currentProfile(:));
hold on
ylabel('Current per Cell (A)');
xlabel('Duration (s)');
grid
subplot(1,3,3)
semilogx(td(:),heatingProfile(:));
hold on
ylabel('Heat Generated per Cell (W)');
xlabel('Duration (s)');
grid

figure;
semilogy(td(:),flip(heatingProfile(:)));
hold on;
xlabel('Time [s]');
ylabel('Cell Heating [w]');
title('Worst Case Cell Heting');