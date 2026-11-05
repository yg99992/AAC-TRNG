%% NIST SP 800-22 Test Visualization
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
% Temperature-variant measurement data
temp_cols = {'-20℃', '25℃', '80℃'};
temp_p = [
    0.759756, 0.964259, 0.699313;   % 1 Frequency
    0.319084, 0.678686, 0.289667;   % 2 Block Frequency
    0.867692, 0.883171, 0.090936;   % 3 Cumulative Sums-1
    0.534146, 0.334538, 0.289667;   % 4 Cumulative Sums-2
    0.145326, 0.514124, 0.534146;   % 5 Runs
    0.998821, 0.075719, 0.946308;   % 6 Longest Run
    0.202268, 0.911413, 0.678686;   % 7 Rank
    0.574903, 0.304126, 0.574903;   % 8 FFT
    0.5115, 0.5305,0.4771;          % 9 NonOverlap
    0.224821, 0.455937, 0.616305;   %10 Overlap Template
    0.401199, 0.213309, 0.249284;   %11 Universal
    0.262249, 0.474986, 0.383827;   %12 Approximate Entropy
    0.552555, 0.2874, 0.589167;     %13 Random Excursions
    0.598540, 0.6450, 0.514575;     %14 Random Excursions Variant
    0.350485, 0.955835, 0.474986;   %15 Serial-1
    0.213309, 0.678686, 0.971699;   %16 Serial-2
    0.249284, 0.739918, 0.437274    %17 Linear Complexity
];
temp_passrate = {
'98/100','98/100','100/100';
'100/100','99/100','100/100';
'98/100','98/100','100/100';
'98/100','98/100','100/100';
'96/100','97/100','97/100';
'100/100','99/100','98/100';
'98/100','100/100','100/100';
'99/100','97/100','97/100';
'98/100','99/100','98/100';
'100/100','99/100','99/100';
'96/100','98/100','96/100';
'99/100','99/100','100/100';
'98/100','98/100','98/100';
'97/100','99/100','98/100';
'98/100','99/100','99/100';
'97/100','99/100','100/100';
'99/100','98/100','99/100'
};

% Multi-FPGA measurement data
fpga_cols = {'FPGA1', 'FPGA2', 'FPGA3', 'FPGA4'};
fpga_p = [
    0.275709,0.474986,0.759756,0.401199;
    0.534146,0.000555,0.637119,0.616305;
    0.883171,0.883171,0.759756,0.798139;
    0.851383,0.236810,0.289667,0.816537;
    0.275709,0.987896,0.514124,0.534146;
    0.739918,0.304126,0.514124,0.897763;
    0.816537,0.534146,0.897763,0.55442;
    0.867692,0.946308,0.437274,0.678686;
    0.516497,0.515227,0.5100,0.504624;
    0.171867,0.191687,0.494392,0.55442;
    0.924076,0.534146,0.946308,0.534146;
    0.090936,0.554420,0.062821,0.275709;
    0.598776,0.380227,0.528679,0.511004;
    0.527715,0.446906,0.523471,0.401703;
    0.455937,0.058984,0.005358,0.23681;
    0.719747,0.494392,0.834308,0.108791;
    0.534146,0.991468,0.137282,0.897763
];
fpga_passrate = {
'100/100','100/100','100/100','97/100';
'99/100','99/100','98/100','98/100';
'100/100','100/100','100/100','97/100';
'100/100','100/100','100/100','97/100';
'98/100','99/100','98/100','99/100';
'98/100','100/100','100/100','99/100';
'99/100','98/100','100/100','99/100';
'98/100','99/100','99/100','100/100';
'98/100','98/100','99/100','98/100';
'99/100','99/100','100/100','98/100';
'99/100','100/100','98/100','98/100';
'96/100','99/100','100/100','97/100';
'98/100','99/100','99/100','98/100';
'99/100','97/100','98/100','99/100';
'99/100','99/100','100/100','100/100';
'98/100','98/100','99/100','100/100';
'99/100','100/100','99/100','99/100'
};

%% Preprocessing
x_labels = {'Freq.','Blck Freq.','Cum.Sums*','Runs','Long.Run',...
    'Rank','FFT','N.Ov.Templ*','Ov.Templ.','Univ.',...
    'Appr.Entr.','Rand.Exc.*','Rand.Exc.Var*','Serial*','Lin.Compl.'};
x_idx = {1, 2, [3,4], 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, [15,16], 17};
n_x = length(x_labels);

temp_pass_num = zeros(17,3);
fpga_pass_num = zeros(17,4);
for i=1:17
    for j=1:3
        s = temp_passrate{i,j};
        if contains(s,'/')
            parts = split(s,'/');
            temp_pass_num(i,j) = str2double(parts{1})/str2double(parts{2});
        else
            temp_pass_num(i,j) = 1.0;
        end
    end
    for j=1:4
        s = fpga_passrate{i,j};
        if contains(s,'/')
            parts = split(s,'/');
            fpga_pass_num(i,j) = str2double(parts{1})/str2double(parts{2});
        else
            fpga_pass_num(i,j) = 1.0;
        end
    end
end

temp_p_plot = zeros(n_x,3);
temp_pass_plot = zeros(n_x,3);
fpga_p_plot = zeros(n_x,4);
fpga_pass_plot = zeros(n_x,4);
for i=1:n_x
    idx = x_idx{i};
    temp_p_plot(i,:) = mean(temp_p(idx,:), 1);
    temp_pass_plot(i,:) = mean(temp_pass_num(idx,:), 1);
    fpga_p_plot(i,:) = mean(fpga_p(idx,:), 1);
    fpga_pass_plot(i,:) = mean(fpga_pass_num(idx,:), 1);
end
temp_min_p = min(temp_p_plot,[],1);
fpga_min_p = min(fpga_p_plot,[],1);

temp_colors = [0 0 0; 1 0 0; 0 0 1];
temp_markers = {'s','o','^'};
fpga_colors = [0 0 0; 1 0 0; 0 0 1; 0 0.5 0.5];
fpga_markers = {'s', 'o', '^', 'v'};

%% Plot: Dual Y-axis line chart
fig = figure('Color','w','Units','centimeters','Position',[2,2,20,22]);
center_x = (n_x + 1) / 2;

% Subplot (a): Temperature test
subplot(2,1,1); hold on; box on;
yyaxis left;
for j=1:3
    plot(1:n_x, temp_pass_plot(:,j), 'Color',temp_colors(j,:), ...
        'Marker',temp_markers{j}, 'MarkerSize',6, ...
        'MarkerFaceColor',temp_colors(j,:), 'LineStyle', '-');
end
ylabel('Proportion');
ylim([0.95, 1.04]);
yticks([0.95, 0.96, 0.97,0.98,0.99 1.00]);
yline(0.96,'--k','LineWidth',1);
text(center_x, 0.96, 'pass threshold = 0.96','FontSize',10, ...
    'HorizontalAlignment','center','VerticalAlignment','bottom');
yline(1.00, '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5);
ax = gca; ax.YColor = 'k';

yyaxis right;
for j=1:3
    plot(1:n_x, temp_p_plot(:,j), 'Color',temp_colors(j,:), ...
        'Marker',temp_markers{j}, 'MarkerSize',6, ...
        'MarkerFaceColor',temp_colors(j,:), 'LineStyle', '-');
end
ylabel('P_T value');
ylim([-2.0, 1.2]);
yticks([0, 0.5,  1]);
yline(1e-4,'--k','LineWidth',1);
text(center_x, 1e-4, 'pass threshold = 10^{-4}','FontSize',10, ...
    'HorizontalAlignment','center','VerticalAlignment','bottom');
ax.YColor = 'k';

xticks(1:n_x); xticklabels(x_labels); xtickangle(45);
xlim([0.5, 15.5]);
min_p_str = ['P_T value: ', sprintf('%.1e  ', temp_min_p)];
text(0.01,1.07,min_p_str,'Units','normalized','FontSize',10,'HorizontalAlignment','left');
legend(temp_cols,'Location','southoutside','Orientation','horizontal','NumColumns',3);
text(0.99,0.02,'* Tests with multiple subtests use averaged subtest results',...
    'Units','normalized','FontSize',10,'HorizontalAlignment','right','VerticalAlignment','bottom');
hold off;

% Subplot (b): FPGA devices test
subplot(2,1,2); hold on; box on;
yyaxis left;
for j=1:4
    plot(1:n_x, fpga_pass_plot(:,j), 'Color',fpga_colors(j,:), ...
        'Marker',fpga_markers{j}, 'MarkerSize',6, ...
        'MarkerFaceColor',fpga_colors(j,:), 'LineStyle', '-');
end
ylabel('Proportion');
ylim([0.95, 1.04]);
yticks([0.95, 0.96, 0.97,0.98,0.99 1.00]);
yline(0.96,'--k','LineWidth',1);
text(center_x, 0.96, 'pass threshold = 0.96','FontSize',10, ...
    'HorizontalAlignment','center','VerticalAlignment','bottom');
yline(1.00, '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5);
ax = gca; ax.YColor = 'k';

yyaxis right;
for j=1:4
    plot(1:n_x, fpga_p_plot(:,j), 'Color',fpga_colors(j,:), ...
        'Marker',fpga_markers{j}, 'MarkerSize',6, ...
        'MarkerFaceColor',fpga_colors(j,:), 'LineStyle', '-');
end
ylabel('P_T value');
ylim([-2.0, 1.2]);
yticks([0, 0.5, 1]);
yline(1e-4,'--k','LineWidth',1);
text(center_x, 1e-4, 'pass threshold = 10^{-4}','FontSize',10, ...
    'HorizontalAlignment','center','VerticalAlignment','bottom');
ax.YColor = 'k';

xticks(1:n_x); xticklabels(x_labels); xtickangle(45);
xlim([0.5, 15.5]);
min_p_str = ['P_T value: ', sprintf('%.1e  ', fpga_min_p)];
text(0.01,1.07,min_p_str,'Units','normalized','FontSize',10,'HorizontalAlignment','left');
legend(fpga_cols,'Location','southoutside','Orientation','horizontal','NumColumns',4);
text(0.99,0.02,'* Tests with multiple subtests use averaged subtest results',...
    'Units','normalized','FontSize',10,'HorizontalAlignment','right','VerticalAlignment','bottom');
hold off;

%% Export vector EMF
set(findall(gcf,'type','axes'),'LooseInset',get(gca,'TightInset')+[0.02,0.03,0.08,0.03]);
exportgraphics(gcf, 'nist.emf', 'ContentType', 'vector');
