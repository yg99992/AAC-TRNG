input_folder = './data/';
filename = 'T0NG8_FIT.BIN';
filepath = fullfile(input_folder, filename);
fs = 50e6;
read_bits = 1000000;

fileID = fopen(filepath, 'r');
raw_data = fread(fileID, read_bits/8, 'uint8');
fclose(fileID);

bits_matrix = rem(floor(double(raw_data) * 2.^(0:-1:-7)), 2); 
bits = reshape(bits_matrix', [], 1); 
x = 2 * double(bits(1:read_bits)) - 1;

nfft = 2^16;
[pxx, f] = periodogram(x, rectwin(length(x)), nfft, fs, 'psd'); 
amplitude = sqrt(pxx);
f_mhz = f/1e6;


downsample_factor = floor(length(f_mhz) / 3000); 
if downsample_factor < 1, downsample_factor = 1; end 

f_plot = f_mhz(1:downsample_factor:end);
amp_plot = amplitude(1:downsample_factor:end);

fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1, 1, 13, 3]);
hold on;


h_fill = fill([f_plot; flipud(f_plot)], [amp_plot; zeros(size(amp_plot))], 'k');
set(h_fill, 'EdgeColor', 'none'); 


h_plot = plot(f_plot, amp_plot, 'Color', 'k', 'LineWidth', 1.2);
try set(h_plot, 'JoinStyle', 'round'); catch; end


box on;           
grid off;         
set(gca, 'Layer', 'top'); 


set(gca, 'FontName', 'Arial Narrow', 'FontSize', 14, ...
         'TickDir', 'in', ...         
         'LineWidth', 1.5, ...        
         'XColor', 'k', 'YColor', 'k');

xlim([0, 25]);
ylim([0, 0.00075]); 
xlabel('Frequency (MHz)', 'FontWeight', 'bold');
ylabel('Amplitude', 'FontWeight', 'bold');
title('(a) No attack', 'Units', 'normalized', 'Position', [0, 1.05], ...
      'HorizontalAlignment', 'left', 'FontWeight', 'bold');


