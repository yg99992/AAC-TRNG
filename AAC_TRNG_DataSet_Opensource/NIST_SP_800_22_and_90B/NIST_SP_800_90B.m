%% NIST SP 800-90B Test Visualization
clear; clc; close all;
%% Global Style Configuration
set(groot, ...
    'defaultAxesFontName', 'Arial Narrow', ...
    'defaultTextFontName', 'Arial Narrow', ...
    'defaultAxesFontSize', 10, ...
    'defaultTextFontSize', 10, ...
    'defaultLineLineWidth', 1.5, ...
    'defaultAxesLineWidth', 1);

%% Raw Data Definition
x_labels = {'MCV','Collision','Markov','Compression','t-Tuple',...
    'LRS','Multi-MCW','Lag-Pred','Multi-MMC','LZ78Y'};
n_x = length(x_labels);

% NIST SP 800-90B estimation results for four FPGAs
fpga_data = [
% FPGA1      FPGA2      FPGA3      FPGA4
0.999631,   0.999682,   0.998966,   0.999624;   % 1. MCV
0.970530,   0.976817,   0.983965,   0.975872;   % 2. Collision
0.999944,   0.999662,   0.999375,   0.999859;   % 3. Markov
0.952546,   0.949838,   0.947763,   0.950397;   % 4. Compression
0.931665,   0.935005,   0.949638,   0.950832;   % 5. t-Tuple
0.981870,   0.993653,   0.999734,   0.999596;   % 6. LRS
0.999702,   0.999746,   0.999704,   0.999612;   % 7. Multi-MCW
0.999623,   0.999654,   0.999791,   0.999874;   % 8. Lag-Pred
0.999742,   0.999583,   0.998985,   0.999710;   % 9. Multi-MMC
0.999768,   0.999428,   0.998971,   0.999742;   %10. LZ78Y
];

fpga_cols = [0 0 0; 1 0 0; 0 0 1; 0 0.5 0.5];
fpga_markers = {'s', 'o', '^', 'v'};
fpga_names = {'FPGA1','FPGA2','FPGA3','FPGA4'};

%% Compute global minimum entropy
all_min_entropy = min(fpga_data(:));
fprintf('Global minimum entropy = %.6f\n', all_min_entropy);

%% Plot
fig = figure('Color','w','Units','centimeters','Position',[2,2,20,11]);
hold on; box on;

% Left Y-axis
yyaxis left;
ylim([0.9, 1.05]);
yticks(0.9:0.025:1);
ylabel('Estimation Value');
ax = gca; ax.YColor = 'k';

% Right Y-axis, mirrored ticks without tick labels
yyaxis right;
ylim([0.9, 1.05]);
yticks(0.9:0.025:1);
yticklabels('');
ylabel('');
ax.YColor = 'k';

% Plot solid lines with markers
for j = 1:4
    plot(1:10, fpga_data(:,j), 'Color',fpga_cols(j,:), ...
        'Marker',fpga_markers{j}, 'MarkerSize',7, ...
        'MarkerFaceColor',fpga_cols(j,:), 'LineStyle', '-');
end

% Global minimum entropy dashed line and annotation
yline(all_min_entropy, '--r', 'LineWidth',1.2);
text(5, all_min_entropy-0.01, sprintf('Min Entropy = %.6f',all_min_entropy),...
    'FontSize',11,'Color','r','HorizontalAlignment','center');

% X-axis setup
xticks(1:n_x);
xticklabels(x_labels);
xtickangle(45);
xlim([0.5, n_x+0.5]);

legend(fpga_names,'Location','southoutside','Orientation','horizontal','NumColumns',4);
title('NIST SP 800-90B Non-iid Test Results of Four FPGA Devices');
hold off;

%% Export vector EMF
set(findall(gcf,'type','axes'),'LooseInset',get(gca,'TightInset')+[0.02,0.03,0.08,0.03]);
exportgraphics(gcf, 'nist_90B.emf', 'ContentType', 'vector');
