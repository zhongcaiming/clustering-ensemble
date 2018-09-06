%% Kruskal's minimum spanning tree algorithm 
% Input: W -- distance matrix
% output: Pairs -- edge
% Caiming Zhong 04/2009

function Pairs = MST(W) 
    Pairs = zeros(size(W, 1) - 1, 3);
    D = zeros(size(W, 1) * (size(W, 1)  - 1) / 2, 1);
    I = zeros(size(D), 2);
    m = 1;
    n = 1;

    for i = 1: size(D)
        I(i, 1) = m + 1;
        I(i, 2) = n;
        D(i) = W(m+ 1, n);

        if n == m
            m = m + 1;
            n = 1;
        else
            n = n + 1;
        end
    end

    D = [D, I];
    D = sortrows(D);

    numOfPairsIn = 0;
    for i = 1: size(D, 1)
        rep1 = repElement(Pairs, D(i, 2));
        rep2 = repElement(Pairs, D(i, 3));

        if rep1 ~= rep2 || (rep1 < 0 && rep2 < 0)
            numOfPairsIn = numOfPairsIn + 1;
            Pairs(numOfPairsIn, 1) = D(i, 2);
            Pairs(numOfPairsIn, 2) = D(i, 3);

            if rep1 < 0 && rep2 <0
                Pairs(numOfPairsIn, 3) = D(i, 2);
            elseif rep1 < 0 && rep2 > 0
                Pairs(numOfPairsIn, 3) = rep2;
            elseif rep1 > 0 && rep2 < 0
                Pairs(numOfPairsIn, 3) = rep1;
            else                                                          % if both rep1 and rep2 are greater than 0
                Pairs(numOfPairsIn, 3) = rep1;
                for j = 1: size(Pairs, 1)                           % combine two subtrees 
                    if Pairs(j,3) == rep2
                        Pairs(j,3) = rep1;
                    end
                end
            end
        end

        if numOfPairsIn >= size(W, 1) - 1
            Pairs(:,3) = 0;
            break;
        end
    end
end

%% determine the representative element
function rep = repElement(Pairs, node)
    rep = -1;
    for i = 1: size(Pairs, 1)
        if Pairs(i, 1) == node || Pairs(i, 2) == node
            rep = Pairs(i, 3);
            return;
        end
    end
end
