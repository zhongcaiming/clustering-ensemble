%% VAT matrix adapted from https://github.com/scimk/VAT/blob/master/vat.m
function I = VAT(R, X, K1)   
    % *** Input Parameters ***
    % @param R (n*n double): Dissimilarity data input
    % 
    % *** Output Values ***
    % @value RV (n*n double): VAT-reordered dissimilarity data
    % @value C (n int): Connection indexes of MST
    % @value I (n int): Reordered indexes of R, the input data
    
    global R1 RV
    R1 = R;
    [N, ~]=size(R);
    K=1:N;
    J=K;

    [y, i] = max(R);
    [~, j] = max(y);
    I = i(j);
    J(I) = [];
    [~, j] = min(R(I,J));
    I = [I J(j)];
    J(J == J(j)) = [];

    for r=3: N-1,
        [y, ~] = min(R(I,J));
        [~, j] = min(y);
        I = [I J(j)];
        J(J == J(j)) = [];
    end;
    I = [I J];

    %%
    RV = R(I,I);
    RV = (RV - min(RV(:)))./(max(RV(:)) - min(RV(:))) ;

    h = figure('position',[280,100,550,550]);

    imshow(RV,'InitialMagnification','fit');    
    uicontrol('Style', 'pushbutton', 'String', 'SelectRect',...
            'Position', [0 40 70 50],...
            'Callback', {@clearrect, h, I, X, K1});  
        
    % Ncut
    [C,~] = NcutClustering(1-R1, K1);      
    Draw(X,C);  
end

function clearrect(~, ~, h, I, X, K)
    rect = getrect(h);
    global  RV R1
    
    scale = size(R1, 1);   
    if rect(1) < 0        
        rect(3) = rect(3) + rect(1);
        rect(1) = 0; 
    end
    if rect(2) < 0 
        rect(4) = rect(4) + rect(2);
        rect(2) = 0; 
    end
    
    if rect(1) + rect(3) > scale 
        rect(3) = scale - rect(1); 
    end
    if rect(2) + rect(4) > scale 
        rect(4) = scale - rect(2); 
    end
    
    x1 = floor(rect(1) / scale * size(RV, 1)) ;
    y1 = floor(rect(2) / scale * size(RV, 1)) ;
    x2 = floor((rect(1) + rect(3))/ scale * size(RV, 1)) ;
    y2 = floor((rect(2) + rect(4))/ scale * size(RV, 1)) ;
    
    if x1 == 0 
        x1 = 1; 
    end
    if y1 == 0 
        y1 = 1; 
    end
    if x2 > scale 
        x2 = scale; 
    end
    if y2 > scale 
        y2 = scale; 
    end
    
    RV(x1:x2, y1:y2) = 1;
    RV(y1:y2, x1:x2) = 1;
    figure(h);
    imshow(RV,'InitialMagnification','fit');   
    
    R1(I(x1:x2), I(y1:y2)) = 1;
    R1(I(y1:y2), I(x1:x2)) = 1;
    
    [C,~] = NcutClustering(1-R1, K); 
    Draw(X,C);    
end
