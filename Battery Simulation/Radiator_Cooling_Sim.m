function heatFlowRate = Radiator_Cooling_Sim(air_massflow, coolantTemp, airTemp)

%% Script to simulate heat ejection in radiatord (Effectiveness-NTU)
% Used https://www.lamar.edu/engineering/_files/documents/mechanical/dr.-fan-publications/2012/No%2031%202012%20ASEE%20Radiator%20Final.pdf
% as the source for these equations.
%% radiator constants
% MMPS-YFM660-01 
% the following dimensions in units of meters
% for clarity, since y6 radiator is vertical, switched height and length
% values to better match paper definitions
w_tube = 0.020574; % 0.785" (radiator core thickness / 2 rows)
h_tube =  0.003175; % estimation from y4
l_radiator =  0.3048; %12" (radiator core height dimension)
h_radiator = 0.200914; %7.910" (radiator core width dimension)
w_fin = 0.039878; % 1.57" (radiator core thickness)
l_fin = 0.0100457; % 0.3955" (radiator core width / 20 )
h_fin = 0.000396875; % estimation from y4
% inlet area of radiator, m^2
a_radiator = l_radiator * h_radiator;
% number of fins and tubes
n_tube = 19;
n_fin = 150; %estimation from y4
%% constants for radiator water 
% reference temp = 40C
% reference pressure (absolute) = 172 kPa (25psi)
% density of water, kg/m^3
rho_water = 997;
% volumetric flow rate of water through radiator, m^3 / sec*****
Q_water = 16.0 / 60 / 1000;
% dynamic viscosity of water at 50C, Pa-s
mu_water = 0.000652; 
% nusselt number of water  
Nu_water = 5.60;
% thermal conductivity of water, W/(K * m)
k_water = 0.631;
% specific heat capacity of water, J/(kg * K)
c_water = 4180.0; 
% total water mass flow rate, kg/sec
m_water = rho_water * Q_water; 
% total heat capacity of water, J / (K * s)
C_water = m_water * c_water;
% temp of the water entering the radiator, Celsius
t_water_in = coolantTemp;
%% constants for air
% flow rate of air into radiator, m^3 / sec <-- NEED AN UPDATED VALUE FROM
% AERO TEAM
q_air = air_massflow;
% density of ambient air, kg/m^3
rho_air = 1.14; 
% temp of the air entering radiator, degrees Celsius
t_air_in = airTemp;
% dynamic viscosity of air, Pa-s
mu_air = 0.000019;
% kinematic viscosity of air, m^2/s  
nu_air = mu_air / rho_air;
% Prandt number of air
Pr_air = 0.713;
% thermal conductivity of air, W/(m * K)
k_air = 0.0268;
% specific heat capacity of air, J/(kg * K)
c_air = 1010.0;
% air mass flow rate into radiator, kg/s
m_air = q_air * rho_air;
% total heat capacity of air, W / K 
C_air = m_air * c_air;
%% constants for fin efficiency
% thermal conductivity of aluminum (fin material), W/(m * K)
k_aluminum = 237.0; 
% area of radiator water tube, m^2
a_tube = w_tube * h_tube;
% perimeter of radiator water tube, m
p_tube = 2 * w_tube + 2 * h_tube;
% hydraulic diameter of water tube, m
d_hydraulic = 4 * a_tube / p_tube;
% speed of water through tube, m/sec
v_water = Q_water / (n_tube * a_tube);
% reynolds number of radiator water
Re_water = rho_water * v_water * d_hydraulic / mu_water;
% heat transfer coefficient of the radiator water, W/(m^2 * K)
h_water = Nu_water * k_water / d_hydraulic; 
%% External Flow of Air
% speed of air through radiator, m/sec
v_air = q_air / (a_radiator - (n_tube * h_tube * l_radiator));
% reynolds number of air through radiator
Re_air = v_air * w_fin / nu_air; 
% nusselt number of the air
Nu_air = 0.664 * sqrt(Re_air) * Pr_air^(1/3); 
% heat transfer coefficient of the air, W/(m^2 * K) 
h_air = Nu_air * k_air / w_tube; 
%% Fin Dimensions / Efficiency
% coefficient for calculating efficiency, 1/m
m = sqrt(2 * h_air / (k_aluminum * h_fin));
% corrected fin length, m
l_c = l_fin + h_fin / 2;
% efficiency of fin
eta_fin = tanh(m * l_c) / (m * l_c);
% base surface area, m^2
a_b = 2 * l_radiator * w_tube - h_fin * w_fin * n_fin;
% fin surface area, m^2
a_f = 2 * w_fin * l_c;
% fin and base area of tube
a_fin_base = n_fin * a_f + a_b; 
% overall surface efficiency
eta_o = 1 - (n_fin * a_f) * (1 - eta_fin) / a_fin_base; 
%% Effectiveness/NTU Method
% total external surface area, m^2
a_external = a_fin_base * n_tube; 
% total internal surface area, m^2
a_internal = (2 * w_tube + 2 * h_tube) * l_radiator * n_tube; 
% overall heat transfer coefficient, W / K
UA = 1 / (1 / (eta_o * h_air * a_external) + 1 / (h_water * a_internal));
% min/max total heat capacity, W / K
C_min = min(C_water, C_air); 
C_max = max(C_water, C_air); 
% min/max heat capacity ratio
C_r = C_min / C_max;
% number of heat transfer units
NTU = UA / C_min;
% effectiveness
epsilon = 1 - exp((NTU^(0.22) / C_r) * (exp(NTU^(0.78) * (-1 * C_r)) - 1)); 
%% Heat transfer rate
% max heat transfer rate from radiator at air temp
q_max = C_min * (t_water_in - t_air_in);

% predicted heat transfer from radiator at various air temps, W
q_predicted = epsilon*q_max;

heatFlowRate = q_predicted;

end