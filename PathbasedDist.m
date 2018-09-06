%% To generate pathbased distance matrix, i.e. minmax distance matrix
% Input: W -- Dissimilarity matrix
% Output: PathBased -- PathBased dissimilarity matrix
% Caiming Zhong, 2014/05/08

function PathbasedW = PathbasedDist(W)
    Pairs = MST(W); 
    N = size(W,1);
    PathbasedW = zeros(N);
    Degrees = zeros(N, 1);
    
    Connections = zeros(N);
    for i = 1: N - 1
        Degrees(Pairs(i,1)) = Degrees(Pairs(i,1)) + 1;
        Degrees(Pairs(i,2)) = Degrees(Pairs(i,2)) + 1;        
        Connections(Pairs(i,1), Degrees(Pairs(i,1))) = Pairs(i,2);
        Connections(Pairs(i,2), Degrees(Pairs(i,2))) = Pairs(i,1);
    end
    
    for i = 1: N
        if Degrees(i) == 1  % first node with one edge
            break;
        end;
    end;    
    
    CloseT = zeros(N,1);
    OpenT = zeros(N,1);
    cursor_C = 0;
    cursor_T = 0;
    
    cursor_C = cursor_C + 1;
    CloseT(cursor_C) = i;
    Visited = zeros(N, 1);
    Visited(i) = 1;

    while cursor_C < N
        % nodes connected to the current node in close table
        Nodes1 = Connections( CloseT(cursor_C), 1: Degrees(CloseT(cursor_C)));
        Nodes = Nodes1(Visited(Nodes1)==0);

        for i = 1: length(Nodes)
            % Nodes to Close table 
            for j = 1: cursor_C
                PathbasedW(CloseT(j), Nodes(i)) = max(PathbasedW(CloseT(j), CloseT(cursor_C)), W(CloseT(cursor_C),  Nodes(i)));
                PathbasedW(Nodes(i), CloseT(j) )= PathbasedW(CloseT(j), Nodes(i)) ;
            end

            % Nodes to Open table
            for j = 1: cursor_T          
                PathbasedW(OpenT(j), Nodes(i)) = max(PathbasedW(OpenT(j), CloseT(cursor_C)), W(CloseT(cursor_C),  Nodes(i)));
                PathbasedW(Nodes(i), OpenT(j) )= PathbasedW(OpenT(j), Nodes(i)) ;
            end
        end
              
        % Nodes each other
        for i = 1: length(Nodes) - 1
            for j = i  + 1: length(Nodes)
                PathbasedW(Nodes(i), Nodes(j)) = max(W(Nodes(i), CloseT(cursor_C)), W(Nodes(j), CloseT(cursor_C)));
                PathbasedW(Nodes(j), Nodes(i)) = PathbasedW(Nodes(i), Nodes(j));
            end
        end
        for i = 1: length(Nodes)
            % Nodes are added into OpenT
            cursor_T = cursor_T + 1;
            OpenT(cursor_T) = Nodes(i);
        end        
        cursor_C = cursor_C + 1;
        CloseT(cursor_C) = OpenT(cursor_T);
        Visited(OpenT(cursor_T)) = 1;
        cursor_T = cursor_T - 1;                
    end    
end
   


