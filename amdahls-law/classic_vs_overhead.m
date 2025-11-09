clear; clc; close all;

% Parameters
S = 0.1;    % Fraction of sequential computation time (non-parallelizable) 
P = 1 - S;  % Fraction of parallelizable computation time
a = 0.01;

% ---------- %

p = 2.^(0:16);
p_fine = logspace(0,16, 500);

% Classical model
speedup = 1 ./ (S + P ./ p_fine);

% Overhead model
S_o = a * p_fine;
P_o = 1 - S_o;
speedup_overhead = 1 ./ (S_o + P_o ./ p_fine);

% Graphs
figure;
plot(p_fine, speedup, 'LineWidth', 4, 'DisplayName','Classic')
hold on
plot(p_fine, speedup_overhead, 'LineWidth', 4, 'DisplayName','Overhead')
hold off

% X-axis
set(gca, 'XScale', 'log')

xlim([1 max(p)])
xticks(p)
xticklabels(string(p))

% Y-axis
y_max = ceil(max([speedup, speedup_overhead]) * 1.1);
yticks(1:y_max)
ylim([0 y_max])

xlabel('Number of processors (p)')
ylabel('Speedup')
%title("Classic vs Overhead")
grid on
legend('Location','northwest')
