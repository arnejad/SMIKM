function out = weightFunc(N,p,x)
%{
    value=zeros(1,length(x));
    for j=1:length(x)
        coef1=binomCoef(N,x(j));
        cp=p^x(j);
        cq=(1.0-p)^(N-x(j));
        value(j)=coef1*cp*cq;
    end
    out=value;
%}
    value=zeros(1,length(x));
    for j=1:length(x)
%         coef1=gamma(N+1)/(gamma(x(j)+1)*gamma(N-x(j)+1));
        coef1 = nchoosek(N, x(j));
        cp=p^x(j);
        cq=(1.0-p)^(N-x(j));
        value(j)=coef1*cp*cq;
    end
    out=value;
end

