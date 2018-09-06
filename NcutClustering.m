%% Normalized Cut
function [C,V] = NcutClustering(W,nbCluster)

[NcutDiscrete,V,~] = ncutW(W,nbCluster);
C = zeros(size(W,1),1);

for j=1:nbCluster,
    C(NcutDiscrete(:,j)==1) = j;
end
