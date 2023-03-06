function [consts] = krawPrep(dim, px, py)
%KRAWPREP computes the constants which are independent from the image
%content

    N = dim(1); M = dim(2);
    
    %calculating the weight matrix based on equation (5) and (21)
    fprintf("calculating the weight matrix\n");
    w_x =weightFunc(N, px, linspace(0,N,N+1));
    w_y =weightFunc(N, py, linspace(0,N,N+1));
    
    W = sqrt(w_x)' *  sqrt(w_y);
    consts.W = zeros(N+1);
    consts.W(2:end, 2:end) = W(1:end-1,1:end-1);
    
    % equation (6)
    z=0:N;
    ro_x = sqNorm(N, px, z);
    ro_y = sqNorm(N, py, z);
    consts.rho= ro_x' *ro_y;
    
    % computing a_(n,k,p,N) matrix based on eq. 1
    fprintf("computing a coeffs\n");
    a_x = zeros(N+1);
    a_x(1,:) = ones(1,N+1);
    for i=1:N
        ttemp = acoeffs(0:i,i,px,N)';
        a_x(:,i+1) = [ttemp; zeros(N-length(ttemp)+1,1)];
    end
    
    a_y = zeros(M+1);
    a_y(1,:) = ones(1,M+1);
    for i=1:M
        ttemp = acoeffs(0:i,i,py,M)';
        a_y(:,i+1) = [ttemp; zeros(M-length(ttemp)+1,1)];
    end
    consts.a_x = a_x;
    consts.a_y = a_y;
end

