function out = sqNorm(N,p,n)
    coef1=gamma(n+1)./pochhammer(-N,n);
    cp=((1.0-p)/p).^n;
    out=coef1.*cp.*(-1).^n;
%     coef1=binomCoef(N,n);
%     cp=((1.0-p)*p)^n;
%     out=coef1*cp;
end

