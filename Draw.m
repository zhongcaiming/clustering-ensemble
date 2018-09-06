%% Draw the result 
% Input: X -- data; C -- labels

function Draw(X, C)
    figure('position',[10,200,250,250]);
    C_uq = unique(C);
    color = 'rgbmck';
    shape = '+o<xvp*>d'; 
    for j = 1: length(C_uq)
            IDX = find(C==C_uq(j));
            plot(X(IDX,1),X(IDX,2),shape(mod(j, 9)+1), 'MarkerEdgeColor', color(mod(j, 6)+1),'MarkerSize',5); axis equal; hold on;
    end 
end
