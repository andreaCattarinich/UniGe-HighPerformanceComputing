clear; clc; close all;

% Parameters
S_values = [0.8 0.6 0.4 0.2 0.15 0.10 0.05];   % Varia S da 0.8 a 0.05
a = 0.01;

% ---------- %

p = 2.^(0:16);
p_fine = logspace(0,16, 500);

% Graphs
figure;
hold on
colors = jet(length(S_values)); % Colormap per distinguere le curve

for i = 1:length(S_values)
    S = S_values(i);
    P = 1 - S;
    
    % Classical model
    speedup = 1 ./ (S + P ./ p_fine);
    
    % Plot
    plot(p_fine, speedup, 'LineWidth', 2, 'Color', colors(i,:), ...
        'DisplayName', ['P = ' num2str(P*100) '%']);
end

% X-axis
set(gca, 'XScale', 'log')
xlim([1 max(p)])
xticks(p)
xticklabels(string(p))

% Y-axis
y_max = ceil(max(1 ./ S_values) * 1.1); % massimo speedup teorico
yticks(0:2:y_max)
ylim([0 y_max])

xlabel('Number of processors (p)')
ylabel('Speedup')
%title("Speedup vs Processors for different S")
grid on
lgd = legend('Location','northwest');
lgd.Title.String = 'Parallel portion';
