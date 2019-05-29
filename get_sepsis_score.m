function [score, label] = get_sepsis_score(data, model)

scores = [];
labels = [];
Xd1= size(data,1);

score = 0;
label = 0;

X = data;

if Xd1<10
    %      for short ICU time
    featuresX = mean(X,'omitnan');
    try
        scores(:) = model{1}.trainedModel.predictFcn(featuresX);
    catch
        scores = 0;
    end
    
    % %%% ---------------------------------------------------------------------
elseif Xd1<61
    % for moderate ICU time
    %     Significant features found using tree training and ANOVA
    featureLabels = [1 3 4 6 7 8 18 23 29];
    %     featureLabels = 1:40;
    ValuesX = mean(X(:,featureLabels),'omitnan');
    %     replace nans for zeros
    ValuesX(isnan(ValuesX)) = 0;
    
    %     feature 2. count of non nan values, for specific(experimentaly) metrics
    nanC_labels = [11 12 13 14 18 22 23 26];
    features_nanC =  mean(sum(~isnan(X(:,nanC_labels)))/Xd1);
    %     select hours of windows
    features_stats = getStatisticalFeatures(X, 7);
    
    %     feature vector
    featuresX = [ValuesX features_nanC features_stats(:)'];
    
    %
    % med3 with 6 hours
     try
    if model{2}.trainedModel.predictFcn(featuresX)
        scores = 1;
        %         if Xd1>14
        %             scores(end-(8+6):end,1) = 1;
    else
        scores = 0;
        %             scores(1:end,1) = 1;
    end
        catch
        scores = 0;
    end


% %%% ---------------------------------------------------------------------
else
    %      for long ICU time
    %     Significant features from tree training and ANOVA
    featureLabels = [1 3 4 6 7 8 18 23 29];
    %     featureLabels = 1:40;
    ValuesX = mean(X(:,featureLabels),'omitnan');
    
    %     feature 2. count of non nan values, for specific(experimentaly) metrics
    nanC_labels = [11 12 13 14 18 22 23 26];
    features_nanC =  mean(sum(~isnan(X(:,nanC_labels)))/Xd1);
    
    features_stats = getStatisticalFeatures(X, 20);
    
    %     feature vector
    featuresX = [ValuesX features_nanC features_stats(:)'];
    
    %     tree4 - 20hours
    try
    if model{3}.trainedModel.predictFcn(featuresX)==4
        scores = 1
%         scores(end-(8+6):end,1) = 1;
    end
        catch
        scores = 0;
    end
    
end


% labels = double([scores>0.5]);

% label = labels(end);
% score = score(end);







%
%
% x_mean = [ ...
%         83.8996 97.0520  36.8055  126.2240 86.2907 ...
%         66.2070 18.7280  33.7373  -3.1923  22.5352 ...
%         0.4597  7.3889   39.5049  96.8883  103.4265 ...
%         22.4952 87.5214  7.7210   106.1982 1.5961 ...
%         0.6943  131.5327 2.0262   2.0509   3.5130 ...
%         4.0541  1.3423   5.2734   32.1134  10.5383 ...
%         38.9974 10.5585  286.5404 198.6777];
%     x_std = [ ...
%         17.6494 3.0163  0.6895   24.2988 16.6459 ...
%         14.0771 4.7035  11.0158  3.7845  3.1567 ...
%         6.2684  0.0710  9.1087   3.3971  430.3638 ...
%         19.0690 81.7152 2.3992   4.9761  2.0648 ...
%         1.9926  45.4816 1.6008   0.3793  1.3092 ...
%         0.5844  2.5511  20.4142  6.4362  2.2302 ...
%         29.8928 7.0606  137.3886 96.8997];
%     c_mean = [60.8711 0.5435 0.0615 0.0727 -59.6769 28.4551];
%     c_std = [16.1887 0.4981 0.7968 0.8029 160.8846 29.5367];
%
%     m = size(data, 1);
%     x = data(m, 1:34);
%     c = data(m, 35:40);
%
%     x_norm = (x - x_mean)./x_std;
%     c_norm = (c - c_mean)./c_std;
%
%     x_norm(isnan(x_norm)) = 0;
%     c_norm(isnan(c_norm)) = 0;
%
%     model.beta = [ ...
%         0.1806  0.0249 0.2120  -0.0495 0.0084 ...
%         -0.0980 0.0774 -0.0350 -0.0948 0.1169 ...
%         0.7476  0.0323 0.0305  -0.0251 0.0330 ...
%         0.1424  0.0324 -0.1450 -0.0594 0.0085 ...
%         -0.0501 0.0265 0.0794  -0.0107 0.0225 ...
%         0.0040  0.0799 -0.0287 0.0531  -0.0728 ...
%         0.0243  0.1017 0.0662  -0.0074 0.0281 ...
%         0.0078  0.0593 -0.2046 -0.0167 0.1239]';
%     model.rho = 7.8521;
%     model.nu = 1.0389;
%
%     xstar = [x_norm c_norm];
%     exp_bx = exp(xstar * model.beta);
%     l_exp_bx = (4 / model.rho).^model.nu * exp_bx;
%
%     score = 1 - exp(-l_exp_bx);
%     label = double(score > 0.45);
