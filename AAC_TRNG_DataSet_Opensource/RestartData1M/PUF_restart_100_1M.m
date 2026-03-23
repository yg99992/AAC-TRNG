clc; clear; close all;

folder   = './data/';       
filename = 'R0RST1M_CHIP1.BIN';    
filepath = fullfile(folder, filename);

num_restarts  = 100;        
bits_per_run  = 1000000;     
total_bytes   = num_restarts * bits_per_run; 

if isfile(filepath)
    fprintf('正在读取大文件: %s ...\n', filepath);
    fid = fopen(filepath, 'rb');
    raw_data = fread(fid, total_bytes, '*uint8'); 
    fclose(fid);
    
    if length(raw_data) < total_bytes
        error('文件大小不足！预期 %.2f MB, 实际 %.2f MB', ...
            total_bytes/1e6, length(raw_data)/1e6);
    end

    clean_bits = bitget(raw_data, 2); 
    processed_matrix = reshape(clean_bits, bits_per_run, num_restarts); 
    clear raw_data clean_bits; 
else
    fprintf('wrong');
    processed_matrix = randi([0, 1], bits_per_run, num_restarts, 'uint8');
end


R = corrcoef(double(processed_matrix)); 

off_diag_mask = ~eye(size(R)); 
R_values = R(off_diag_mask);
mean_raw  = mean(R_values);           
mean_abs  = mean(abs(R_values));      
max_val   = max(R_values);            
min_val   = min(R_values);            
std_val   = std(R_values);            

theoretical_3sigma = 3 / sqrt(bits_per_run); 

fprintf('最大互相关 (Max):    %+.6f\n', max_val);
fprintf('最小互相关 (Min):    %+.6f\n', min_val);
fprintf('原始均值 (Mean):     %+.6f\n', mean_raw);
fprintf('绝对均值 (Mean Abs):  %.6f\n', mean_abs);

R_plot = R;                 
R_plot(eye(size(R))==1) = 0; 

figWidth  = 12;  
figHeight = 10;  
fontName  = 'Arial Narrow';
fontSize  = 14;
common_font = {'FontName', fontName, 'FontSize', fontSize};

hFig = figure('Color', 'w', 'Units', 'centimeters', 'Position', [2, 2, figWidth, figHeight]);

axesPos = [0.15, 0.15, 0.60, 0.75]; 
ax = axes('Units', 'normalized', 'Position', axesPos);

imagesc(R_plot);
set(ax, common_font{:}, 'TickDir', 'out');
axis square;
set(ax, 'XTick', 0:20:100, 'YTick', 0:20:100);
xlabel('Sequence ID (Restart Index)', common_font{:});
ylabel('Sequence ID (Restart Index)', common_font{:});

bot = [linspace(0, 1, 128)', linspace(0, 1, 128)', ones(128, 1)]; 
top = [ones(128, 1), linspace(1, 0, 128)', linspace(1, 0, 128)']; 
colormap([bot; top]); 

limit_val = 0.005; 
caxis([-limit_val, limit_val]); 

hC = colorbar;
set(hC, common_font{:}); 
ticks = -limit_val:0.001:limit_val;
set(hC, 'Ticks', ticks);
set(hC, 'TickLabels', arrayfun(@(x) sprintf('%.3f', x), ticks, 'UniformOutput', false)); 

ylabel(hC, 'Correlation Coefficient', common_font{:});


export_name = 'Correlation_Matrix_for_Visio.emf';
print(hFig, export_name, '-dmeta', '-r600'); 

