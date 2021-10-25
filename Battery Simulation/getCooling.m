function cooling = getCooling(speed, coolantTemp, airTemp)

    cooling = 5.16*speed*(coolantTemp-airTemp);
    
end