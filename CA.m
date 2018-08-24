%% Accuracy
function ca = CA(C, C_Label)
    ca = 0;
    L = unique(C);
    for i = 1: length(L)
        Idx = find(C==L(i));
        id = mode(C_Label(Idx));
        Idx1 = find(C_Label==id);
        ca = ca + length(intersect(Idx,Idx1));
    end
    ca = ca/length(C_Label);
end