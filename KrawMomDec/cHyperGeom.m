function [A] = cHyperGeom(a, b, c, z)
%Custom HYPERGEOM 

A = 0;

for k=0:-a
    A = A + (pochhammer(a, k)* expand(pochhammer(b, k)) * z^k )/ (pochhammer(c,k) * factorial(k));
end
B =0;
for k=0:-a
    B = B + ((gamma(a+k) ./ gamma(a)) * expand((gamma(b+k) ./ gamma(b))) * z^k )/ ((gamma(c+k) ./ gamma(c)) * factorial(k));
end

end

