function [J, flag, ED2] = MHM2015(I,M,layer)
[A, B] = size(I);
flag = -1;
tic
%%%%%%%%% location map
[I,LM] = LocationMap(I,layer);
xC = cell(1,1);
xC{1} = LM;
data = Arith07(xC);

%%%%%%%%% location map length
8*length(data);

%%%%%%%%% pre
E = zeros(A,B);
D = zeros(A,B);
%%%%%%%%% Calculation of PE and NL
index = 0;
for i = 2:A-2
    for j = 2:B-2
        if mod(i+j,2) == layer
            index = index+1;
            v1 = I(i-1,j);                   u6 = I(i-1,j+2);
            v2 = I(i  ,j-1); p  = I(i  ,j);  v4 = I(i  ,j+1); u7 = I(i  ,j+2);
            u1 = I(i+1,j-1); v3 = I(i+1,j);  u4 = I(i+1,j+1); u8 = I(i+1,j+2);
            u2 = I(i+2,j-1); u3 = I(i+2,j);  u5 = I(i+2,j+1); u9 = I(i+2,j+2);
            p = ceil((v1+v2+v3+v4)/4);
            E(i,j) = I(i,j)-p;
            D(i,j) = abs(v2-u1)+abs(u1-u2)+abs(v1-p)+abs(p-v3)+abs(v3-u3)+abs(v4-u4)+abs(u4-u5)+abs(u6-u7)+abs(u7-u8)+abs(u8-u9)+...
                abs(v2-p)+abs(p-v4)+abs(v4-u7)+abs(u1-v3)+abs(v3-u4)+abs(u4-u8)+abs(u2-u3)+abs(u3-u5)+abs(u5-u9);
        end
    end
end
%%%%% Calculate T

%%%%%%%%% 2D histogram
H = zeros(511,max(D(:))+1);
for i = 2:A-2
    for j = 2:B-2
        if mod(i+j,2) == layer
           H(E(i,j)+255,D(i,j)+1) = H(E(i,j)+255,D(i,j)+1)+1;
        end
    end
end

%%%%%%%%% Normalize 2D histogram
Scale = 16;
T = zeros(1,Scale);
for i = 1:Scale
    for j = 1:max(D(:))+1
        if sum(sum(H(:,1:j))) >= index/Scale*i
            T(i) = j;
            break
        end
    end
end

%%%%%%%%% Calculate complexity after normalization of 2D histogram
Dbis = zeros(A,B);
for k = Scale:-1:1
    for i = 2:A-2
        for j = 2:B-2
            if mod(i+j,2) == layer
                if D(i,j) < T(k)
                    Dbis(i,j) = k;
                end
            end
        end
    end
end

data = Arith07(xC);
%%%%%%%%% Regenerate 2D histogram
H = zeros(511,Scale);
for i = 2:A-2
    for j = 2:B-2
        if mod(i+j,2) == layer
           H(E(i,j)+255,Dbis(i,j)) = H(E(i,j)+255,Dbis(i,j))+1;
        end
    end
end
%%%%%%%% Auxiliary information length: 16*3, a; 4, 255; LM; 18 message; hist para
s = ceil(log2(T(Scale-1)));
if sum(LM) == 0
    Aux = Scale*3+4+1+17+(Scale-1)*s+4;
else
    Aux = Scale*3+4+1+8*length(data)+17+17+(Scale-1)*s+4;
end
%%%%%%%%% Parameter calculation
EC = length(M) + Aux;
MSEmin = 10000000000000000;
W = [0 1 2 3 4 5 6 7 250];
R = [];
S = zeros(1,Scale);
flagbis = 0;
for a1 = 1:9
    for a2 = a1:9
        for a3 = a2:9
            for a4 = a3:9
                for a5 = a4:9
                    for a6 = a5:9
                        for a7 = a6:9
                            for a8 = a7:9
                                for a9 = a8:9
                                    for a10 = a9:9
                                        for a11 = a10:9
                                            for a12 = a11:9
                                                for a13 = a12:9
                                                    for a14 = a13:9
                                                        for a15 = a14:9
                                                            for a16 = a15:9
                                                                S = [W(a1) W(a2) W(a3) W(a4) W(a5) W(a6) W(a7) W(a8) W(a9) W(a10) W(a11) W(a12) W(a13) W(a14) W(a15) W(a16)];
                                                                x = 0;
                                                                for k = 1:Scale
                                                                    x = x+H(S(k)+255,k)+H(-S(k)-1+255,k);
                                                                end
                                                                if x >= EC
                                                                    flagbis = 1;
                                                                    y = 0;
                                                                    for k = 1:Scale
                                                                        y = y+sum(H(S(k)+255:511,k))+sum(H(1:-S(k)-1+255,k));
                                                                    end
                                                                    if y/x < MSEmin
                                                                        MSEmin = y/x;
                                                                        R = S;
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
if isempty(R)
    J=-1;
    ED2 = -1;
    return;
end
if flagbis == 1
    %%%%%%%% Modify auxiliary information length
    Scalebis = Scale-1;
    for  i = Scale:-1:1
        if R(i) == 250
            Scalebis = i-1;
        end
    end
    s = ceil(log2(T(Scalebis)));
    if sum(LM) == 0
        Aux = Scalebis*3+4+1+17+Scalebis*s+4;
    else
        Aux = Scalebis*3+4+1+8*length(data)+17+17+Scalebis*s+4;
    end
    EC = length(M);
    rng(0);
    ED2 = 0;
    %%%%%%%%% True embedding
    Nend = 0;
    for i = 2:A-2
        for j = 2:B-2
            if mod(i+j,2) == layer && EC > 0
                Nend = Nend+1;
                k = Dbis(i,j);
                if E(i,j) == R(k)
                    EC = EC-1;
                    I(i,j) = I(i,j)+M(EC+1);
                    ED2 = ED2 + M(EC+1);
                end
                if E(i,j) == -R(k)-1
                    EC = EC-1;
                    I(i,j) = I(i,j)-M(EC+1);
                    ED2 = ED2 + M(EC+1);
                end
                if E(i,j) > R(k)
                    I(i,j) = I(i,j)+1;
                    ED2 = ED2 + 1;
                end
                if E(i,j) < -R(k)-1
                    I(i,j) = I(i,j)-1;
                    ED2 = ED2 + 1;
                end
            end
        end
    end
    %%%%%%%%% Random information
    X = randperm(A*B);
    LM = zeros(A,B);
    for i = 1:A
        for j = 1:B
            LM(i,j) = mod(X(B*(i-1)+j),2);
        end
    end
    %%%%%%%%% Embedding auxiliary information
    for i = 2:A-2
        for j = 2:B-2
            if mod(i+j,2) == layer
                if Aux > 0
                    I(i,j) = 2*floor(I(i,j)/2)+LM(i,j);
                    Aux = Aux-1;
                end
            end
        end
    end
end
if EC <= 0
    flag=1;
end
J=I;
end
