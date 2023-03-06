function res = acoeffs(k, n, p, N)

syms x
fx = cHyperGeom(-n, -x, -N, 1/p);
res = double(coeffs(fx));
% res = temp(k+1);

end

