function voltage = getCellVoltage(SOC)
    load('SOC_VOLT_LOOKUP.mat');
    voltage = interp1(SOC_VOLT_LOOKUP(:,1),SOC_VOLT_LOOKUP(:,2),SOC,'pchip');

end