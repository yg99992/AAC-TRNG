clc; clear; close all;

folder   = './data';       
filename = 'r0RST1000_CHIP1.BIN';    
filepath = fullfile(folder, filename);

H_input = 0.950397;  

num_restarts  = 1000;     
bits_per_run  = 1000;    
total_needed_bytes = num_restarts * bits_per_run; 



fid = fopen(filepath, 'rb');
raw_data = fread(fid, total_needed_bytes, '*uint8');
fclose(fid);

clean_bits = bitget(raw_data, 2); 

bit_matrix = reshape(clean_bits, bits_per_run, num_restarts)'; 
clear raw_data clean_bits;


row_ones  = sum(bit_matrix, 2);
row_zeros = bits_per_run - row_ones;
row_max   = max(row_ones, row_zeros); 

col_ones  = sum(bit_matrix, 1)';
col_zeros = num_restarts - col_ones;
col_max   = max(col_ones, col_zeros); 


all_counts = [row_max; col_max]; 
X_global_max = max(all_counts); 

p_val = 2^(-H_input);      
alpha_nist = 0.000005;      

cutoff = binoinv(1 - alpha_nist, 1000, p_val) + 1; 


fig_w = 12; fig_h = 8;
figure('Units', 'centimeters', 'Position', [5, 5, fig_w, fig_h], 'Color', 'w');
common_font = {'FontName', 'Arial', 'FontSize', 9};


h = histogram(all_counts, 'BinMethod', 'integers', ...
    'FaceColor', [0.4, 0.6, 0.8], 'EdgeColor', 'w', 'FaceAlpha', 0.8);
hold on; grid on;

y_limits = ylim;
line([cutoff cutoff], [0 y_limits(2)], 'Color', [0.8 0 0], 'LineStyle', '--', 'LineWidth', 1.5);


text(double(cutoff) + 2, y_limits(2)*0.85, ...
    ['NIST Cutoff', char(10), sprintf('(X_{max}=%d)', cutoff)], ...
    'Color', [0.8 0 0], common_font{:}, 'FontWeight', 'bold');


plot(X_global_max, y_limits(2)*0.02, 'kv', 'MarkerFaceColor', 'y', 'MarkerSize', 7);
text(double(X_global_max), y_limits(2)*0.12, sprintf('Max: %d', X_global_max), ...
    common_font{:}, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');


title(['Restart Health Test (2000 Sequences, H = ', num2str(H_input, '%.4f'), ')'], ...
    'FontSize', 10, 'FontWeight', 'bold');
xlabel('Max Frequency of 0 or 1 in a Sequence', common_font{:});
ylabel('Sequence Count (Total 2000)', common_font{:});


if X_global_max >= cutoff
    res_str = 'FAIL'; res_color = [0.8 0 0];
else
    res_str = 'PASS'; res_color = [0 0.5 0];
end

annotation('textbox', [0.8, 0.75, 0.12, 0.1], 'String', res_str, ...
    'Color', res_color, 'FontWeight', 'bold', 'EdgeColor', res_color, ...
    'LineWidth', 2, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');


fprintf('\n--- NIST 800-90B Restart Sanity Check ---\n');
fprintf('H: %.6f\n', H_input);
fprintf(' X_max: %d\n', cutoff);
fprintf('conclusion: %s\n', res_str);
