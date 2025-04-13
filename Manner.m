function [watermarked, ED1, clm] = Manner(I, msg, layer, alpha, Tn, Tp)
% Data embedding based on local variance prediction
% dir = 0: Cross, dir = 1: Dot

watermarked = I;
[A, B] = size(I);

% Generate location map and encode it
[I, LM] = LocationMap(I, layer);
xC = cell(1,1);
xC{1} = LM;
data = Arith07(xC);

% Simulate auxiliary information
Capacity = length(msg);
msg = [msg, round(rand(1, 8 * length(data)))]; 

% Calculate the number of embeddable pixels
lenT = round((Capacity + 8 * length(data)) / alpha);

v = zeros(1, A*B/2);
difs = zeros(1, A*B/2);
vars = zeros(1, A*B/2);
xpos = zeros(1, A*B/2);
ypos = zeros(1, A*B/2);

pfor = 1;
for i = 2:A-2
    for j = 2:B-2
        if mod(i + j, 2) == layer
            % Neighboring pixels
            v1 = I(i-1,j);     u6 = I(i-1,j+2);
            v2 = I(i  ,j-1);   p  = I(i  ,j);  v4 = I(i  ,j+1); u7 = I(i  ,j+2);
            u1 = I(i+1,j-1);   v3 = I(i+1,j);  u4 = I(i+1,j+1); u8 = I(i+1,j+2);
            u2 = I(i+2,j-1);   u3 = I(i+2,j);  u5 = I(i+2,j+1); u9 = I(i+2,j+2);

            % Local variance measure
            vars(pfor) = abs(v2-u1) + abs(u1-u2) + abs(v1-p) + abs(p-v3) + ...
                         abs(v3-u3) + abs(v4-u4) + abs(u4-u5) + abs(u6-u7) + ...
                         abs(u7-u8) + abs(u8-u9) + abs(v2-p) + abs(p-v4) + ...
                         abs(v4-u7) + abs(u1-v3) + abs(v3-u4) + abs(u4-u8) + ...
                         abs(u2-u3) + abs(u3-u5) + abs(u5-u9);
            p = ceil((v1+v2+v3+v4)/4);
            difs(pfor) = I(i,j) - p;

            xpos(pfor) = i;
            ypos(pfor) = j;
            v(pfor) = p;
            pfor = pfor + 1;
        end
    end
end

pfor = pfor - 1;
if lenT > pfor
    % Insufficient embedding capacity
    watermarked = -1;
    ED1 = -1;
    clm = -1;
    return;
end

% Sort by local variance and select lowest lenT positions
[vars, index] = sort(vars(1:pfor));
index = sort(index(1:lenT)); 
difs = difs(index);
xpos = xpos(index);
ypos = ypos(index);
v = v(index);

pforW = 1;
cover = zeros(1, lenT);
cost = ones(1, lenT);
e_embed = zeros(1, lenT);
wetpoint = 100;

% Construct cost and cover vectors
for i = 1:pfor
    if pforW > lenT
        break;
    end
    
    if difs(i) == Tp || difs(i) == Tn
        e_embed(pforW) = difs(i);
        pforW = pforW + 1;
    elseif difs(i) > Tp || difs(i) < Tn
        cover(pforW) = 1;
        cost(pforW) = wetpoint - 1;
        e_embed(pforW) = difs(i);
        pforW = pforW + 1;
    elseif difs(i) < Tp && difs(i) > Tn
        cost(pforW) = wetpoint + 1;
        e_embed(pforW) = difs(i);
        pforW = pforW + 1;
    end
end

if pforW < lenT
    % Insufficient capacity
    watermarked = -1;
    ED1 = -1;
    clm = -1;
    return;
end

% Perform actual embedding
[T, clm] = MEandReconsInfoGen(cover, cost, msg, lenT, Tn, Tp, e_embed);
ED1 = sum(T);
fprintf('MSE for the first layer: %d\n', ED1);
fprintf('Reconstruction information size: %d\n', length(clm));

if length(clm) >= length(msg)
    % Overflow in reconstruction information
    watermarked = -1;
    ED1 = -1;
    return;
end

% Update pixel differences with embedded data
pforW = 1;
for i = 1:pfor
    if pforW > lenT
        break;
    end
    Tm = ceil((Tp+Tn)/2);
    if difs(i) >= Tm
        difs(i) = difs(i) + T(pforW);
        pforW = pforW + 1;
    elseif difs(i) < Tm
        difs(i) = difs(i) - T(pforW);
        pforW = pforW + 1;
    end
end

% Apply modifications to the image
for i = 1:lenT
    watermarked(xpos(i), ypos(i)) = v(i) + difs(i);
end

end
