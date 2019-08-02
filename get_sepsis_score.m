function [score, label] = get_sepsis_score(data, model)
% send only last value

Xd1= size(data,1);
score = 0;
label = 0;

X = data;
if Xd1   
    score = 0;
elseif Xd1<10
    %      for short ICU time
    featuresX = mean(X,'omitnan');
    try
        scores(:) = model{1}.trainedModel.predictFcn(featuresX);
        score = scores(end);
    catch
        disp('error 1')
%         disp(Xd1)
        score = 0;
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
            score = 1;
            %         if Xd1>14
            %             scores(end-(8+6):end,1) = 1;
        else
            score = 0;
            %             scores(1:end,1) = 1;
        end
    catch
        disp('error 2')
        disp(Xd1)
        score = 0;
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
            score = 1
            %         scores(end-(8+6):end,1) = 1;
        end
    catch
        disp('error 3')
        disp(Xd1)
        score = 0;
    end
    
end

label = score;
