clc; clear; close all;
% =========================================================================
% 1. Path and file configuration
% =========================================================================
% This section defines input directory and target binary files.
% The script processes 8 binary files: T0NG1.BIN ~ T0NG8.BIN
input_folder = './data/';
file_list = {
    'T0NG1.BIN', 'T0NG2.BIN', 'T0NG3.BIN', 'T0NG4.BIN', ...
    'T0NG5.BIN', 'T0NG6.BIN', 'T0NG7.BIN', 'T0NG8.BIN'
};
total_bits = 10 * 1000000;
% Struct to store filename, calculated min-entropy and output file size
results = struct('filename', {}, 'min_entropy', {}, 'size_mb', {});

% =========================================================================
% 2. Batch processing loop
% =========================================================================
% Read binary samples, extract target single bit, compute min-entropy,
% repack extracted bit stream into new binary file and save to disk.
for i = 1:length(file_list)
    current_file = file_list{i};
    input_path = fullfile(input_folder, current_file);
    output_path = fullfile(input_folder, ['Processed_', current_file]);
    fprintf('\n--- Processing: %s (%d/8) ---\n', current_file, i);
    if ~isfile(input_path)
        warning('File not found: %s, skipped.', input_path);
        continue;
    end
    % Read raw binary bytes
    fid = fopen(input_path, 'rb');
    raw_bytes = fread(fid, total_bits, '*uint8');
    fclose(fid);
    % Extract bit 1 (LSB) from each byte
    extracted_bits = bitget(raw_bytes,1);
    clear raw_bytes;
    % Calculate single-bit min-entropy
    total_extracted = length(extracted_bits);
    num_ones = sum(extracted_bits);
    p_max = max(num_ones, total_extracted - num_ones) / total_extracted;
    min_entropy = -log2(p_max);
    % Save results into struct
    results(i).filename = current_file;
    results(i).min_entropy = min_entropy;
    % Repack extracted 0/1 bits into uint8 bytes
    num_full_bytes = floor(total_extracted / 8);
    bits_to_pack = extracted_bits(1 : num_full_bytes * 8);
    bit_matrix = reshape(uint8(bits_to_pack), 8, []);
    packed_bytes = sum(bit_matrix .* uint8(2 .^ (0:7))', 1, 'native');
    % Write packed bit stream to new binary file
    fid_out = fopen(output_path, 'wb');
    fwrite(fid_out, packed_bytes, 'uint8');
    fclose(fid_out);
    results(i).size_mb = dir(output_path).bytes / 1024 / 1024;
    fprintf('Completed. Min-entropy: %.6f, saved to: %s\n', min_entropy, output_path);
end

% =========================================================================
% 3. Summary table
% =========================================================================
% Output all batch results to command window
fprintf('\n================== Batch Processing Summary ==================\n');
T = struct2table(results);
disp(T);

% =========================================================================
% 4. Plot section
% =========================================================================
% NOTE: The two plotting blocks below use min-entropy data obtained
% from the above batch bit-extraction & entropy calculation module.
% Uncomment the corresponding block to generate figures.

% -------------------------- Plot 1: Different input challenges --------------------------
% % Data matrix: rows RD0-RD7, columns ET=1 to ET=8
% data = [
% 0.4690 	0.9997 	0.9997 	0.9849 	0.9993 	0.9994 	0.9996 	0.9998
% 0.0414 	0.5258 	0.9998 	0.8594 	0.9756 	0.9999 	0.9994 	0.9992
% 0.0042 	0.9376 	0.9777 	0.8446 	0.7990 	0.9982 	0.9987 	0.9982
% 0	    0.1593 	0.9187 	0.0033 	0.1372 	0.9983 	0.9909 	0.9955
% 0	    0.0132 	0.6361 	0.0027 	0.0116 	0.6538 	0.7533 	0.9496
% 0	    0.0005 	0.5890 	0.0035 	0.0000 	0.5611 	0.4423 	0.7066
% 0	    0	    0	    0	    0	    0.4708 	0.4069 	0.0016
% 0	    0	    0	    0	    0	    0	    0	    0
% ];
%
% %% Figure setup
% figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 750, 500]);
% hold on;
% grid on;
% box on;
% set(gca, 'GridLineStyle', '--');
%
% %% Color palette
% colors = [
%     0      0      0;      % ET1 black
%     1      0      0;      % ET2 red
%     0      0      1;      % ET3 blue
%     0      0.5    0.5;    % ET4 teal
%     1      0      1;      % ET5 magenta
%     0.5    0.5    0;      % ET6 olive
%     0      0      0.5;    % ET7 dark blue
%     0.5    0      0       % ET8 brown-red
% ];
%
% %% Markers for first seven curves
% markers = {'s', 'o', '^', 'v', '<', '>', 'd'};
% marker_size = 10;
%
% for i = 1:7
%     plot(0:7, data(:, i), 'Color', colors(i,:), ...
%         'Marker', markers{i}, ...
%         'MarkerSize', marker_size, ...
%         'MarkerFaceColor', colors(i,:), ...
%         'MarkerEdgeColor', colors(i,:), ...
%         'LineWidth', 1.2, ...
%         'DisplayName', ['ET=', num2str(i)]);
% end
%
% %% Curve for ET=8
% x_data = 0:7;
% y_data = data(:, 8)';
% plot(x_data, y_data, 'Color', colors(8,:), 'LineWidth', 1.2, 'HandleVisibility', 'off');
%
% %% Legend placeholder for ET=8
% plot(nan, nan, '-p', ...
%     'MarkerSize', marker_size, ...
%     'MarkerFaceColor', colors(8,:), ...
%     'MarkerEdgeColor', colors(8,:), ...
%     'Color', colors(8,:), ...
%     'LineWidth', 1.2, ...
%     'DisplayName', 'ET=8');
%
% %% Draw regular pentagon markers in pixel coordinate
% theta = linspace(pi/2, pi/2 + 2*pi, 6);
% theta = theta(1:end-1);
% pent_x = cos(theta);
% pent_y = sin(theta);
%
% drawnow;
% orig_units = get(gca, 'Units');
% set(gca, 'Units', 'pixels');
% ax_pos = get(gca, 'Position');
% set(gca, 'Units', orig_units);
%
% x_range = diff(xlim);
% y_range = diff(ylim);
% x_data_per_pix = x_range / ax_pos(3);
% y_data_per_pix = y_range / ax_pos(4);
%
% pent_pix_dia = 10;
% pent_size_x = pent_pix_dia * x_data_per_pix;
% pent_size_y = pent_pix_dia * y_data_per_pix;
%
% for k = 1:length(x_data)
%     px = pent_x * pent_size_x + x_data(k);
%     py = pent_y * pent_size_y + y_data(k);
%     patch(px, py, colors(8,:), 'EdgeColor', colors(8,:), 'HandleVisibility', 'off');
% end
%
% %% Axes and label settings
% xlabel('Bit Index of RD', ...
%     'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Arial Narrow');
% ylabel('Min-Entropy', ...
%     'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Arial Narrow');
% xticks(0:7);
% ylim([-0.2 1.2]);
% set(gca, 'FontSize', 14, 'FontName', 'Arial Narrow', 'LineWidth', 1.5);
% legend('Location', 'northeast', 'FontSize', 10, 'FontName', 'Arial Narrow');
% exportgraphics(gcf, 'output.emf', 'ContentType', 'vector');
% title('Min-entropy of each bit of counter under different input challenges.', ...
%     'FontSize', 10, 'FontName', 'Arial Narrow');

% -------------------------- Plot 2: Different operating frequencies --------------------------
% % Data matrix: rows RD0-RD7, columns 50M, 25M, 12.5M, 10M, 6.25M, 5M
% data = [
% 0.9811 	0.9998 	0.9998 	0.9995 	0.9997 	0.9997
% 0.8136 	0.9746 	0.9998 	0.9994 	0.9998 	0.9997
% 0.6173 	0.8173 	0.9991 	0.9999 	0.9996 	0.9999
% 0.8996 	0.9366 	0.9995 	0.9998 	0.9999 	0.9996
% 0.0001 	0.0001 	0.9739 	0.9976 	1.0000 	0.9998
% 0	    0	    0.7589 	0.8917 	0.9938 	0.9998
% 0	    0	    0.0010 	0.0014 	0.0049 	0.0115
% 0	    0	    0	    0	    0	    0.0002
% ];
%
% %% Figure setup
% figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 750, 500]);
% hold on;
% grid on;
% box on;
% set(gca, 'GridLineStyle', '--');
%
% %% Color palette
% colors = [
%     0      0      0;      % black
%     1      0      0;      % red
%     0      0      1;      % blue
%     0      0.5    0.5;    % teal
%     1      0      1;      % magenta
%     0.5    0.5    0       % olive
% ];
%
% %% Markers and legend labels
% markers = {'s', 'o', '^', 'v', '<', '>'};
% labels = {'50M', '25M', '12.5M', '10M', '6.25M', '5M'};
%
% %% Plot curves
% for i = 1:6
%     plot(0:7, data(:, i), 'Color', colors(i,:), ...
%         'Marker', markers{i}, ...
%         'MarkerSize', 10, ...
%         'MarkerFaceColor', colors(i,:), ...
%         'MarkerEdgeColor', colors(i,:), ...
%         'LineWidth', 1.2, ...
%         'DisplayName', labels{i});
% end
%
% %% Axes and label settings
% xlabel('Bit Index of RD', ...
%     'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Arial Narrow');
% ylabel('Min-Entropy', ...
%     'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Arial Narrow');
% xticks(0:7);
% xlim([-1, 8]);
% ylim([-0.2 1.2]);
% set(gca, 'FontSize', 14, 'FontName', 'Arial Narrow', 'LineWidth', 1.5);
% legend('Location', 'northeast', 'FontSize', 10, 'FontName', 'Arial Narrow');
% title('Min-entropy of each bit of counter under different frequencies', ...
%     'FontSize', 10, 'FontName', 'Arial Narrow');
% exportgraphics(gcf, 'output_freq.emf', 'ContentType', 'vector');
