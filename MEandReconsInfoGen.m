function [stego_k, clm] = MEandReconsInfoGen(cover_k, rho_k, msg, lenT, Tn, Tp, e_embed)
% Generate reconstruction information and perform segmented compression

[~, stego_k] = stc_embed(uint8(cover_k(1:lenT)'), uint8(msg'), rho_k(1:lenT)', 15); % Embed message
stego_k = double(stego_k'); % Convert to double
e1 = e_embed;
Tm = ceil((Tp + Tn) / 2);
e1(e_embed >= Tm) = e1(e_embed >= Tm) + stego_k(e_embed >= Tm);
e1(e_embed < Tm) = e1(e_embed < Tm) - stego_k(e_embed < Tm);

% Remove elements that do not need compression (stego_e = [Tm, Tm-1])
e2 = e1(e1 > Tm | e1 < Tm-1);
stego2 = stego_k(e1 > Tm | e1 < Tm-1);

% Segment 1: values outside [Tp+1, Tn-1]
part1 = stego2(e2 > Tp+1 | e2 < Tn-1);
lmm1 = (part1 == 0);
hs1 = sum(lmm1); % Number of shift points
if hs1 == 0 || hs1 == length(lmm1)
    clm1 = [];
else
    clm1 = arithenco(lmm1+1, [length(part1)-hs1, hs1]);
    if length(lmm1) <= length(clm1)
        clm1 = lmm1;
    end
end

% Segment 2: values equal to Tp+1 or Tn-1
part2 = stego2(e2 == Tp+1 | e2 == Tn-1);
lmm2 = (part2 == 0);
hs2 = sum(lmm2);
if hs2 == 0 || hs2 == length(lmm2)
    clm2 = [];
else
    clm2 = arithenco(lmm2+1, [length(part2)-hs2, hs2]);
    if length(lmm2) <= length(clm2)
        clm2 = lmm2;
    end
end

% Segment 3: values equal to Tp or Tn
part3 = stego2(e2 == Tp | e2 == Tn);
lmm3 = (part3 == 1);
hs3 = sum(lmm3);
if hs3 == 0 || hs3 == length(lmm3)
    clm3 = [];
else
    clm3 = arithenco(lmm3+1, [length(part3)-hs3, hs3]);
    if length(lmm3) <= length(clm3)
        clm3 = lmm3;
    end
end

% Segment 4: values within (Tn, Tp)
part4 = stego2(e2 < Tp & e2 > Tn);
lmm4 = (part4 == 1);
hs4 = sum(lmm4);
if hs4 == 0 || hs4 == length(lmm4)
    clm4 = [];
else
    clm4 = arithenco(lmm4+1, [length(part4)-hs4, hs4]);
    if length(lmm4) <= length(clm4)
        clm4 = lmm4;
    end
end

% Combine all compressed information
clm = [clm1 clm2 clm3 clm4];

end
