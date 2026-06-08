%% -------------------------------------------------------------------------
%  LOCAL HELPER FUNCTIONS
% -------------------------------------------------------------------------

function plot_testcase(t, x, y, title_str, filename)
figure('Name', title_str);
plot(t*1000, x, 'b', 'DisplayName', 'Input',  'LineWidth', 1.2); hold on;
plot(t*1000, y, 'r', 'DisplayName', 'Output', 'LineWidth', 1.5);
xlabel('Time (ms)'); ylabel('Amplitude');
title(title_str); legend; grid on;
saveas(gcf, filename);
end

function export_csv(filename, t, x, y, scale)
x_int = round(x * scale);
y_int = round(y * scale);
T = table(t(:), x_int(:), y_int(:), ...
    'VariableNames', {'time_s', 'input_q15', 'output_q15'});
writetable(T, filename);
end

function s = pass_fail(condition)
if condition, s = 'PASS'; else, s = 'FAIL'; end
end

function s = tf_str(condition)
if condition, s = 'YES'; else, s = 'NO'; end
end
