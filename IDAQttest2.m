function [h, p, ci, stats] = IDAQttest2(data1, data2, alpha)
% IDAQttest2 - Independent samples t-test with variance check and beginner-friendly explanation.
%    [h, p, ci, stats] = IDAQttest2(data1, data2, alpha) compares the average
%    (mean) of two independent data sets and prints a beginner-friendly report.
%
% What this answers in plain language:
%   "Are these two sets of measurements different in a real way,
%    or is the difference small enough that it could just be random noise?"
%
% OUTPUTS (MATLAB standard):
%   h     = 1 means the function detected a statistically significant difference
%           0 means it did not detect a statistically significant difference
%   p     = p-value (how surprising the result is if there is truly no difference)
%   ci    = confidence interval for (mean(data1) - mean(data2))
%   stats = structure with tstat and df (degrees of freedom)
%
% This function is part of the Custom MATLAB Toolbox for MEE 2305:
% Instrumentation and Data Acquisition Lab at Temple University.
%
% Developed by: Dr. Osman Sayginer
% Department of Mechanical Engineering, Temple University

    if nargin < 3 || isempty(alpha)
        alpha = 0.05;
    end

    % 0) Clean inputs (make column vectors, remove NaNs)
    data1 = data1(:);
    data2 = data2(:);
    data1 = data1(~isnan(data1));
    data2 = data2(~isnan(data2));

    n1 = length(data1);
    n2 = length(data2);

    if n1 < 2 || n2 < 2
        error('IDAQttest2:NotEnoughData', ...
            'Each data set must have at least 2 valid (non-NaN) samples.');
    end

    % 1) Basic descriptive statistics (what you would report even without a t-test)
    m1 = mean(data1);
    m2 = mean(data2);

    s1 = std(data1);
    s2 = std(data2);

    v1 = var(data1);
    v2 = var(data2);

    se1 = s1 / sqrt(n1);
    se2 = s2 / sqrt(n2);

    meanDiff = m1 - m2;  % IMPORTANT: CI is also for (mean1 - mean2)

    % 2) Quick check: do the two data sets have similar "spread" (variance)?
    % If spreads are very different, Welch's t-test is safer.
    pVar = NaN; hVar = 0; ciVar = [NaN NaN]; statsVar = struct();

    try
        [hVar, pVar, ciVar, statsVar] = vartest2(data1, data2, 'Alpha', alpha);
    catch
        % If vartest2 is not available in the user's MATLAB installation,
        % we keep defaults and fall back to a simple ratio heuristic below.
    end

    % Decide test type
    if ~isnan(pVar)
        useUnequal = (hVar == 1);
    else
        % Fallback if vartest2 unavailable: if one variance is > 4x the other, treat as unequal
        ratio = max(v1, v2) / max(min(v1, v2), eps);
        useUnequal = ratio > 4;
    end

    if useUnequal
        vartype = 'unequal';   % Welch's t-test
    else
        vartype = 'equal';     % Pooled variance t-test
    end

    % 3) Perform t-test (this is the main result)
    [h, p, ci, stats] = ttest2(data1, data2, 'Alpha', alpha, 'Vartype', vartype);

    % 4) Effect size (how big is the difference compared to typical scatter?)
    pooledSD = sqrt(((n1-1)*s1^2 + (n2-1)*s2^2) / (n1+n2-2));
    cohensD = meanDiff / pooledSD;
    absD = abs(cohensD);

    % 5) Beginner-friendly report
    fprintf('\n================== IDAQ T-TEST REPORT ==================\n');
    fprintf('What we are trying to learn:\n');
    fprintf('  Are Data1 and Data2 truly different (real change),\n');
    fprintf('  or could the difference be explained by random noise?\n');
    fprintf('--------------------------------------------------------\n');

    fprintf('STEP 1: What do the raw numbers look like?\n');
    fprintf('  Data1: n=%d | average=%.5f | spread(std)=%.5f\n', n1, m1, s1);
    fprintf('  Data2: n=%d | average=%.5f | spread(std)=%.5f\n', n2, m2, s2);
    fprintf('  Difference in averages (Data1 - Data2) = %.5f\n', meanDiff);
    fprintf('  (Positive means Data1 tends to be higher, negative means lower.)\n');
    fprintf('--------------------------------------------------------\n');

    fprintf('STEP 2: Choose the safer version of the t-test\n');
    if ~isnan(pVar)
        fprintf('  We checked whether the spreads (variances) are similar.\n');
        fprintf('  Variance-test p-value = %.6f\n', pVar);
        if useUnequal
            fprintf('  Spreads look different, so we use Welch''s t-test (safer when spreads differ).\n');
        else
            fprintf('  Spreads look similar, so we use the standard pooled t-test.\n');
        end
        if isfield(statsVar, 'fstat')
            fprintf('  Extra detail: F statistic = %.4f, variance ratio CI = [%.4f, %.4f]\n', ...
                statsVar.fstat, ciVar(1), ciVar(2));
        end
    else
        fprintf('  Variance-test tool not available, using a simple variance ratio check.\n');
        if useUnequal
            fprintf('  Spreads look very different, so we use Welch''s t-test.\n');
        else
            fprintf('  Spreads do not look extremely different, so we use the pooled t-test.\n');
        end
    end
    fprintf('--------------------------------------------------------\n');

    fprintf('STEP 3: The t-test decision (this is the main conclusion)\n');
    fprintf('  We used Vartype = %s\n', vartype);
    fprintf('  t = %.4f, df = %.4f, p = %.6f\n', stats.tstat, stats.df, p);

    fprintf('\nHow to understand the p-value (no jargon):\n');
    fprintf('  Imagine there is actually NO real difference between Data1 and Data2.\n');
    fprintf('  Then p tells you how often a difference this big (or bigger) could happen\n');
    fprintf('  just by random chance.\n');
    fprintf('  Here, that chance is about %.3f%%.\n', p*100);

    fprintf('\nWhat alpha means:\n');
    fprintf('  alpha = %.3f is the cutoff we chose for "too unlikely to be random".\n', alpha);
    fprintf('  If p < alpha, we call it a detected difference.\n');
    fprintf('  If p >= alpha, we say we cannot confidently detect a difference.\n');

    fprintf('\nVerdict:\n');
    if h == 1
        fprintf('  RESULT: Detected difference (p < alpha).\n');
        fprintf('  Meaning: The average values are far enough apart that it is unlikely\n');
        fprintf('  to be caused by random noise alone.\n');
    else
        fprintf('  RESULT: No detected difference (p >= alpha).\n');
        fprintf('  Meaning: The averages might still be different, but with this amount\n');
        fprintf('  of noise and this sample size, we cannot be confident it is real.\n');
        fprintf('  (Often improved by collecting more data or reducing noise.)\n');
    end
    fprintf('--------------------------------------------------------\n');

    fprintf('STEP 4: Confidence Interval (CI) for the average difference\n');
    fprintf('  %d%% CI for (mean1 - mean2) = [%.5f, %.5f]\n', round((1-alpha)*100), ci(1), ci(2));
    fprintf('  Meaning: A reasonable range for the true average difference.\n');
    if ci(1) < 0 && ci(2) > 0
        fprintf('  Because the range crosses 0, "no difference" is still plausible.\n');
    else
        fprintf('  Because the range does not cross 0, it supports a real difference.\n');
    end
    fprintf('--------------------------------------------------------\n');

    fprintf('STEP 5: How big is the difference in a practical sense?\n');
    fprintf('  Effect size (Cohen''s d) = %.4f (|d| = %.4f)\n', cohensD, absD);
    fprintf('  Meaning: How large the difference is compared to the typical scatter.\n');
    if absD >= 0.8
        fprintf('  Size: LARGE (difference is big compared to noise/scatter).\n');
    elseif absD >= 0.5
        fprintf('  Size: MEDIUM (difference is noticeable).\n');
    elseif absD >= 0.2
        fprintf('  Size: SMALL (difference is subtle).\n');
    else
        fprintf('  Size: VERY SMALL (difference is tiny compared to scatter).\n');
    end

    fprintf('\nExtra intuition (standard error):\n');
    fprintf('  Data1 SE = %.5f, Data2 SE = %.5f\n', se1, se2);
    fprintf('  Smaller SE usually happens with more samples or less noise.\n');
    fprintf('========================================================\n\n');
end
