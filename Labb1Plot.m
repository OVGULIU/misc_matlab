tid = [5; 15; 25; 35; 45; 55; 65; 75; 85; 95; 105; 115;...
    125; 135; 145; 155; 165; 175; 195; 225; 255; 285; 315;...
    345; 390; 450; 510; 570; 630; 690; 750];

pulserPerSek = [7295; 7271; 5585; 4829; 4031; 3383;...
    2615; 2213; 1979; 1637; 1391; 1229; 1127; 1049;...
    1079; 863; 959; 749; 663; 617; 547; 487; 393; 311;...
    287; 190; 130; 125; 70; 63; 47];

Osakerhet = [209; 209; 183; 170; 156; 143; 126; 116; 109;...
    100; 92; 86; 83; 80; 81; 72; 77; 68; 37; 36; 34; 32;...
    29; 26; 17; 14; 12; 12; 9.5; 9.1; 8.2];

startln = 20;
pulsFit = pulserPerSek(startln:end);
tidFit = tid(startln:end);
semilogy(tid, pulserPerSek);
hold on;
errorbar(tid, pulserPerSek, Osakerhet);
hold on;
coeff = polyfit(tidFit, log(pulsFit), 1);
fitted_y = exp(polyval(coeff, tid));
semilogy(tid, fitted_y);
hold on;
pulsFit2 = pulserPerSek(1:startln);
coeff2 = polyfit(tid(1:startln), log(pulsFit2), 2);
fitted_y2 = exp(polyval(coeff2, tid));
fit2 = fitted_y2 - fitted_y;
semilogy(tid, fit2);

