function dcir = getCellDCIR(voltage)

    load('VOLT_DCIR_LOOKUP.mat');
    dcir = interp1(VOLT_DCIR_LOOKUP(:,1),VOLT_DCIR_LOOKUP(:,2),voltage,'pchip');

end