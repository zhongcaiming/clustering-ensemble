%% Demonstrate negative evidence removed clusteirng ensemble
function RemoveNegativeInfo
    clc;
    close all;
    warning('off', 'all');
    addpath([cd '/Ncut']); % For normalized cut
    
    load('X.mat'); % A dataset consisting of 3 Gaussian, Labels

    K = length(unique(C_Label)); % Number of clusters
    M = 500; % Number of base partitions
    It = 4; % Number of iterations of K-means              

    % Produce base partitions
    PI = BasePartitionByKmeans(X, M, It); 
    CM = GenCM( PI);  
    
    % Compute and draw VAT
    VAT(1-CM, X, K);
end

%% To generate based partitions by K-means
% X: data set, one row is one instance
% M: the number of base partitions
% It: the number of iterations for K-means
% Ktype: the type to generate base partitions, 'Fixed' ---sqrt(N)
% PI: base partitions,one column is a partition
% ClusterNum: the number of K in each partition
function PI = BasePartitionByKmeans(X, M, It)
    N = size(X, 1);
    PI = zeros(N, M);                                     
    
    for i = 1: M
        K = ceil(sqrt(N));
        opts = statset('MaxIter', It);        
        C = kmeans(X, K, 'emptyaction', 'drop', 'Options', opts);
        while length(unique(C)) ~= K
            C = kmeans(X, K, 'emptyaction', 'drop', 'Options', opts);
        end   
        PI(:, i) = C;      
    end
end

%% Generate Co-association Matrix
function CM = GenCM( PI)
    N = size(PI,1);
    CM = zeros(N);
    PiNo  = size(PI, 2);      
    
    for i = 1: PiNo
        C = PI(:,i);
        for j = 1: length(unique(PI(:,i)))
            IDX = find(C==j);
            if length(IDX) <=1 
                continue;
            end                  
            n = length(IDX);       
            Pairs = combntns(1:n,2);
            Ind = [IDX(Pairs(1:n*(n-1)/2)),IDX(Pairs(n*(n-1)/2+1:n*(n-1)))];
            CM((Ind(:,2) - 1)* N + Ind(:,1)) = CM((Ind(:,2) - 1)* N + Ind(:,1)) + 1;   
        end
    end    
    CM = (CM + CM') / size(PI,2) + eye(N);
end