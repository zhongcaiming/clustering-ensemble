%% Negative evidence removed clustering ensemble
% draw -  1: draw the best clustering;
function CluEnsemble(draw)
    clc;
    close all;
    addpath([cd '/Datasets']);
    addpath([cd '/Ncut']);
    warning('off', 'all');
    
    if nargin == 0
        draw = 1;
    end
    
    % 16 datasets: 8 synthetic and 8 real datasets
    filename = char( 'pathbased','spiral','jain','flame','aggregation',...
                                'd31','r15','s1','iris','ionosphere','wine','diabetes',...
                                'segmentation','glass','wdbc','wpbc');    
                            
    % Each base clustering has fixed number of clusters
    Ktype = 'Fixed'; 

    for i =1 :16
        X = load(['Datasets\', strtrim(filename(i,:)), '.txt']);
        C_Label = load(['Datasets\', strtrim(filename(i,:)), '_label.txt']);   

        K = length(unique(C_Label)); % Number of clusters
        M = 500; % Number of base partitions
        It = 4; % Number of iterations of K-means      
        
        % Produce base partitions
        PI = BasePartitionByKmeans(X, M, It, Ktype); 
        CM = GenCM(PI);    
        
        % Produce clustering candidates
        disp(['Dataset: ',  strtrim(filename(i,:)), ', MM value (The smaller, the better)']);
        disp('========================================');
        Smallest_MM = -1;
        for delta = 0.01: 0.01: 0.5
            CM1 = CM;
            CM1(CM1<=delta)=0; % Remove the evidences less than delta
            [C,~] = NcutClustering(CM1, K); % Ncut to generate a candidate
            
            k = 3; % Number of nearest neighbors for MM
            CA_value = CA(C, C_Label); % Accuracy
            MM_value = minimax(C, CM, k);% Internal validity index,
            
            str = sprintf(['CA value: ', num2str(CA_value, '%5.4f'), ',\t MM value: ', num2str(MM_value, '%5.4f') ]);
            disp(str);
            if Smallest_MM == -1 ||  Smallest_MM > MM_value
                Smallest_MM = MM_value;
                Best_C = C;
            end
        end     
        
        % Draw the best
        if draw == 1
            Draw(X, Best_C);
        end
        
        disp('Press any key to continue...');
        pause; 
    end    
end

%% Generate base partitions by K-means
% X: data set, one row is one instance
% M: the number of base partitions
% It: the number of iterations for K-means
% Ktype: the type to generate base partitions, 'Fixed' ---sqrt(N)
% PI: base partitions,one column is a partition
% ClusterNum: the number of K in each partition
function [PI] = BasePartitionByKmeans(X, M, It, Ktype)
    N = size(X, 1);
    PI = zeros(N, M);                                     
    
    for i = 1: M
        if strcmp(Ktype,'Fixed')
            K = ceil(sqrt(N)); % For dataset Spiral, if K = 2 *  ceil(sqrt(N)), then a good clustering will be produced
        else
            K = randsample(2:ceil(sqrt(N)),1);
        end

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


%% Produce robust pathbased similarity
function CM = PathbasedSimi(W, k)
    N = size(W, 1);
    if k <= 10
        S = sumOfNeighbors(W, k);    
        W = W .* repmat(S', 1, N) .* repmat(S, N, 1);    
    end
    W = PathbasedDist(W.^(-1)) + eye(N);  % minimax (or pathbased) similarity
    CM = W.^(-1);
end

%% Compute the Knnbased density
function M = sumOfNeighbors(W, numOfNeighbours)
    M = sort(W, 'descend');
    M= sum(M(2:numOfNeighbours+1,:));
    M = M / max(M); % Normalized
end

%% MM index
% C - Labels
% CM0 - Co-association matrix
% k - number of nearest neighbors
function s = minimax(C, CM0, k)
    CM = PathbasedSimi(CM0, k);
    s = 0;
    
    NumC = length(unique(C));
    for i = 1: NumC
        a = find(C == i);
        if length(a) <= k
            s = Inf;
            return;
        end
        s1 = max(max(CM(a, C ~= i))); % Cohesion
        
        CM0_a = CM0(a, a);
        CM_a = PathbasedSimi(CM0_a, k);
        
        try
            [C1, ~] = NcutClustering(CM_a, 2); % Cut the cluster to evaluate the stability
            flag = 1;
        catch e
            flag = 0;
        end
   
        if flag == 1
            s2 = min(min(CM_a(C1==1, C1==2))); % Stability
        else
            s2 = Inf;
        end
        s = s + s1 / s2;
    end
end