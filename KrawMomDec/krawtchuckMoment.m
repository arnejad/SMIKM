function Q_tilda = krawtchuckMoment(N, f, consts, out)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Codes were implemented by Ali Rahmani Nejad and Dr. Mohammadreza Faraji
% At Computer Vision lab, Institute for Advanced Studies in Basic Sciences
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    f_tilda = consts.W  .* f;
    clear W_xy  w_x w_y f

    % caluclating M_00, M_10, and M_01 using equation (24)
    x= linspace(0, N, N+1);
    y= linspace(0, N, N+1);
    [Y,X]=meshgrid(x,y);

    M_tilda_00 = sum (sum (f_tilda));
    M_tilda_01 = sum (sum (Y .* f_tilda));% X.^0= 1;Y.^1=Y
    M_tilda_10 = sum (sum (X .* f_tilda));

    % computing centroid
    x_tilda = M_tilda_10 / M_tilda_00;
    y_tilda = M_tilda_01 / M_tilda_00;
    clear M_tilda_01 M_tilda_10
    
    shiftedX=X-x_tilda;
    shiftedY=Y-y_tilda;
    clear ro_x ro_y z

    % computing the central moments mu_20, mu_02, and mu_11 
    %based on eq. 18
    mu_tilda_11 = sum (sum ( shiftedX .* shiftedY .*f_tilda));
    mu_tilda_02 = sum (sum ((shiftedY.^2) .*f_tilda));
    mu_tilda_20 = sum (sum ((shiftedX.^2) .*f_tilda));

    % calculating the unique rotation invariance angle based on eq. 20
    %theta = 0.5* atan(2*mu_tilda_11/(mu_tilda_20-mu_tilda_02));
    mu20mu02diff = mu_tilda_20 - mu_tilda_02;
    if mu_tilda_11 == 0
        if mu20mu02diff == 0
            theta = 0;
        else
            if mu20mu02diff > 0
                theta = 0;
            else
                theta = -pi/2;
            end
        end
    end
    if mu_tilda_11 > 0
        if mu20mu02diff == 0
            theta = pi/4;
        else
            if mu20mu02diff > 0
                theta = (1/2)*atan(2 * mu_tilda_11 / mu20mu02diff);
            else
                theta = (1/2)*atan(2 * mu_tilda_11 / mu20mu02diff) + pi/2;
            end
        end
    end  
    if mu_tilda_11 < 0
        if mu20mu02diff == 0
            theta = -pi/4;
        else
            if mu20mu02diff > 0
                theta = (1/2)*atan(2 * mu_tilda_11 / mu20mu02diff);
            else
                theta = (1/2)*atan(2 * mu_tilda_11 / mu20mu02diff) - pi/2;
            end
        end
    end
    clear mu_tilda_11 mu_tilda_20 mu_tilda_02

    % Computing v_tilda based on eq. 25
%     fprintf("computing v_tilda");
    temp1 =(shiftedX * (cos(theta)/sqrt(M_tilda_00))) + (shiftedY * (sin(theta)/sqrt(M_tilda_00)))+N/2;
    temp2 =(-shiftedX * (sin(theta)/sqrt(M_tilda_00))) + (shiftedY * (cos(theta)/sqrt(M_tilda_00)))+N/2;
    v_tilda=zeros(N+1,N+1);
    
%     for i=0:N
%         for j=0:N
%             v_tilda(i+1,j+1) =M_tilda_00 ^ (-(i+j)/2 -1)* sum (sum ( (temp1.^i ) .* (temp2.^j) .* f_tilda));
%         end
%     end
    iteratFTilda = f_tilda;
    for i = 0:N
        if i ~= 0
            iteratFTilda = temp1.*iteratFTilda;
        end
        secIteratFTilda = iteratFTilda;
        for j = 0:N
            if j ~= 0
                secIteratFTilda  = temp2.*secIteratFTilda;
            end
            %v_tilda(i+1,j+1) = (M_tilda_00)^((-(i+j)/2)-1) * sum(sum(secIteratFTilda));
            v_tilda(i+1,j+1) = sum(sum(secIteratFTilda));
        end
    end
%     v_tilda = v_tilda .* ((M_tilda_00*ones(N+1)).^(((X+Y)./2)-1));
    v_tilda = v_tilda / M_tilda_00;
    clear X Y M_tilda_00 f_tilda iteratFTilda secIteratFTilda temp2 temp1
    
    % calculating final Q_tilde_ij based on eq. 27
    Q_tilda=zeros(N+1,N+1);
    for n=0:N
        for m=0:N
%             a_i = zeros(N+1,1);
%             a_j = zeros(N+1,1);
%              a_i(1:n+1)=acoeffs(0:n,n,px,N);
%              a_j(1:m+1)=acoeffs(0:m,m,py,N);
%             Q_tilda(n+1,m+1) = sum(sum((a_i*a_j').*v_tilda));
            Q_tilda(n+1,m+1) = consts.a_x(1:n+1,n+1)' * v_tilda(1:n+1,1:m+1) * consts.a_y(1:m+1,m+1);
        end
    end
    Q_tilda = Q_tilda ./ sqrt(consts.rho);
    
%     if out == "comp"
%         Q_tilda = Q_tilda(:)';
%     else
        Q_tilda = [ Q_tilda(3,1) Q_tilda(1,3) Q_tilda(2,3) Q_tilda(3,2) Q_tilda(4,1) Q_tilda(1,4) ];
%     end
    
end

