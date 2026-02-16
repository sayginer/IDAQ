function [h, p, ci, stats] = IDAQttest2(data1, data2, alpha)
% IDAQttest2 - Independent samples t-test with automated interpretation.
%    [h, p, ci, stats] = IDAQttest2(data1, data2) performs a t-test to 
%    compare the means of two data sets and prints a detailed analysis 
%    report to the Command Window.
%
%    This function is part of the Custom MATLAB Toolbox for MEE 2305: 
%    Instrumentation and Data Acquisition Lab at Temple University.
%
%    INPUTS:
%       data1 - Vector of measurements from the first group/sensor.
%       data2 - Vector of measurements from the second group/sensor.
%       alpha - (Optional) Significance level (Default = 0.05).
%
%    OUTPUTS:
%       h     - Hypothesis result (1: Significant, 0: Not significant).
%       p     - P-value (probability of the result occurring by chance).
%       ci    - 95% Confidence Interval for the difference in means.
%       stats - Structure containing the t-statistic and degrees of freedom.
%
%    EXAMPLE:
%       % Compare two sets of temperature readings:
%       IDAQttest2(sensor_A, sensor_B)
%
%    Developed by: Dr. Osman Sayginer
%    Department of Mechanical Engineering, Temple University

    if nargin < 3
        alpha = 0.05; 
    end

    % 1. Perform the statistical test
    [h, p, ci, stats] = ttest2(data1, data2, 'Alpha', alpha);

    % 2. Automated Lab Report Generation
    fprintf('\n========== IDAQ LAB REPORT: T-TEST ANALYSIS ==========\n');
    
    if h == 1
        fprintf('STATUS: STATISTICALLY SIGNIFICANT (Reject Null)\n');
        fprintf('The instrumentation data shows a true physical difference\n');
        fprintf('between the two measurement sets.\n');
    else
        fprintf('STATUS: NOT SIGNIFICANT (Fail to Reject Null)\n');
        fprintf('The difference between measurement sets is within the\n');
        fprintf('expected range of sensor noise or random variation.\n');
    end
    
    fprintf('------------------------------------------------------\n');
    fprintf('P-VALUE:       %.4f\n', p);
    fprintf('P-Value Meaning: There is a %.2f%% probability that this\n', p*100);
    fprintf('                 difference is due to random noise.\n');

    fprintf('CONF. INT.:    [%.3f, %.3f]\n', ci(1), ci(2));
    fprintf('CI Meaning:    We are %d%% confident that the true difference\n', (1-alpha)*100);
    fprintf('               between these sensors lies in this range.\n');

    fprintf('T-STATISTIC:   %.3f (Signal-to-Noise Ratio)\n', stats.tstat);
    fprintf('DEG. FREEDOM:  %.0f (Sample size power)\n', stats.df);
    fprintf('======================================================\n\n');

    % 3. Automatic Visualization
    figure('Name', 'IDAQ Lab - T-test Comparison');
    group = [ones(size(data1)); 2*ones(size(data2))];
    boxplot([data1(:); data2(:)], group, 'Labels', {'Group 1', 'Group 2'});
    grid on;
    ylabel('Measured Value');
    title(['T-test Comparison (p = ', num2str(p, '%.4f'), ')']);
end