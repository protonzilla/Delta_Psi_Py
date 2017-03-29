

kf   = 1./tCS;                        % forward rate from RC* to RP1 (???Why)
kb   = kf*exp(-params.deltaG/(kT));   % backward rate from RP1 to RC*


%% Open RC
% %  RC*-->RP1      32  meV
% %  RP1-->RP2      59.4meV
% %  RP2-->RP2relax 34.9meV



%% Closed RC 1
% %  RC*-->RP1      33.1  meV
% %  RP1-->RP2      19 meV
% %  RP2-->RP3      10.8 meV



%% Closed RC 2
% %  RC*-->RP1      19.6  meV
% %  RP1-->RP2      13.1  meV
% %  RP2-->RP3      9.2   meV
% %  RP3-->RP4      38.4  meV



%% Closed RC 2 Rates
% %  CP43* --> RC*      200 ns^-1
% %  CP43* <-- RC*      200 ns^-1
% %  CP47* --> RC*      19.6  meV
% %  CP47* <-- RC*      19.6  meV
% %  RC*   --> RP1      19.6  meV
% %  RP1   --> RP2      13.1  meV
% %  RP2   --> RP3      9.2   meV
% %  RP3   --> RP4      38.4  meV
% %  RP4   --> RP4      38.4  meV


