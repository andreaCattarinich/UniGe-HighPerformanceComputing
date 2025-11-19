% Nome del file contenente i valori
filename = "omp1_10runs_1-32threads.txt";

% Legge i valori dal file (una colonna)
values = readmatrix(filename);

% Numero di valori da mediare per ogni configurazione di thread
n = 10;

% Calcola la media ogni n valori
numBlocks = floor(length(values) / n);
meanTimes = zeros(numBlocks, 1);

for i = 1:numBlocks
    startIdx = (i-1)*n + 1;
    endIdx = i*n;
    meanTimes(i) = mean(values(startIdx:endIdx));
end

% Numero di thread utilizzati (1..numBlocks)
threads = (1:numBlocks)';

% --- Speedup ---
speedup = meanTimes(1) ./ meanTimes;

% --- Efficienza ---
efficiency = speedup ./ threads;


%% ===========================
%       GRAFICO TEMPI
% ============================
figure;
plot(threads, meanTimes, "o-", 'LineWidth', 2);
title("Execution Time (mean of 10 runs)");
xlabel("Threads");
ylabel("Time [s]");
grid on;


%% ===========================
%       GRAFICO SPEEDUP
% ============================
figure;
plot(threads, speedup, "o-", 'LineWidth', 2);
title("Speedup");
xlabel("Threads");
ylabel("Speedup");
grid on;


%% ===========================
%       GRAFICO EFFICIENZA
% ============================
figure;
plot(threads, efficiency, "o-", 'LineWidth', 2);
title("Efficiency");
xlabel("Threads");
ylabel("Efficiency");
grid on;
