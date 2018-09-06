%% Draw the result 
% Input: X -- data; C -- labels

function Draw(X, C)
    figure('position',[10,200,250,250], 'WindowButtonDownFcn',{@tmouse, X'});
    C_uq = unique(C);
    color = 'rgbmck';
    shape = '+o<xvp*>d'; 
    for j = 1: length(C_uq)
            IDX = find(C==C_uq(j));
            plot(X(IDX,1),X(IDX,2),shape(mod(j, 9)+1), 'MarkerEdgeColor', color(mod(j, 6)+1),'MarkerSize',5); axis equal; hold on;
            %text(X(IDX(1),1), X( IDX(1),2), num2str(j),'FontSize',10);axis equal; hold on;  
    end 
end

function tmouse(~,~, data)
    currPt = get(gca, 'CurrentPoint');
    x = currPt(1,1);
    y = currPt(1,2);
    
    minimumD = -1;
    minimumIndex = 0;
    for i = 1: size(data,2)
        d = sqrt((data(1,i)-x).^2 + (data(2,i)-y).^2);
        if d < minimumD || minimumD < 0
            minimumD = d;
            minimumIndex = i;
        end;
    end;   
    disp(minimumIndex);
end    