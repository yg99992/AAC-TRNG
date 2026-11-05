% =========================================================================
% Bitwise Min-Entropy Calculation
% =========================================================================
% 1. Path and file configuration
input_folder = './';
file_list = {
    'FPGA3_frequency_5M.DAT', 'FPGA3_frequency_6.25M.DAT', 'FPGA3_frequency_10M.DAT', ...
    'FPGA3_frequency_12.5M.DAT', 'FPGA3_frequency_25M.DAT', 'FPGA3_frequency_50M.DAT'
};
digit = 3;
results = struct('filename', {}, 'min_entropy', {});
bit_pos = 1;  % Bit position extraction; 1 = LSB, adjustable

% =========================================================================
% 2. Batch processing
% =========================================================================
for i = 1:length(file_list)
    current_file = file_list{i};
    input_path = fullfile(input_folder, current_file);
    fprintf('\n--- Processing: %s (%d/%d) ---\n', current_file, i, length(file_list));
    if ~isfile(input_path)
        warning('File not found: %s, skipped.', input_path);
        continue;
    end
    % Read all characters at once
    fid = fopen(input_path, 'r');
    all_chars = fread(fid, '*char');
    fclose(fid);
    % Keep numeric characters only
    digit_chars = all_chars(all_chars >= '0' & all_chars <= '9');
    total_num = length(digit_chars) / digit;
    if mod(length(digit_chars), digit) ~= 0
        warning('File %s: total digits is not multiple of %d, parsing may be incorrect.', current_file, digit);
    end
    % Fast batch conversion
    digit_matrix = reshape(digit_chars - '0', [digit, total_num])';
    raw_data = digit_matrix(:,1)*100 + digit_matrix(:,2)*10 + digit_matrix(:,3);
    raw_data = uint8(raw_data);
    % Extract target bit
    extracted_bits = bitget(raw_data, bit_pos);
    % Compute single-bit min-entropy
    total_len = length(extracted_bits);
    num_ones = sum(extracted_bits);
    p_max = max(num_ones, total_len - num_ones) / total_len;
    min_entropy = -log2(p_max);
    results(i).filename = current_file;
    results(i).min_entropy = min_entropy;
    fprintf('Done. Total samples: %d, min-entropy: %.6f bit\n', total_len, min_entropy);
end

% =========================================================================
% 3. Summary
% =========================================================================
T = struct2table(results);
disp(T);
