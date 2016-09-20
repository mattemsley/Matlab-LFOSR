function [QE,error,A,B]=QuantumEffTE(lambda,refractive_index,thickness,theta,active_layer)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  QuantumEffTM.m                                                   %
%  Version: 2.0                                                     %
%  Authors:  Gokhan Ulu                                             %
%            Matthew K. Emsley                                      %
%                                                                   %
%  Updates: v2.0 05/11/2000 - Update to handle matrix inputs for    %
%                            lambda and theta individually          %
%                            output now an array                    %
%           v1.0 12/16/1999 - First Release                         %
%                                                                   %
%  Description:  QuantumEffTE.m calculates the quantum efficiency   %
%                of an active layer placed between two mirrors      %
%                using film scattering matrix calculations.         %
%                                                                   %
%  Limitations:  1) Quantum Efficiency are only                     %
%                calculated for TE Polarization                     %
%                2) Supported materials only include Silicon,       %
%                Air, and Silicon Dioxide.                          %
%                                                                   %
%  Inputs:  ALL POINTS IN NANOMETERS!!!                             %
%           Lambda == Wavelength in nanometers  (scaler)            %
%           Layer == matrix containing material types ((1;x)matrix) %
%           Thickness == matrix containing layer thicknesses        %
%                        in nanometers ((1;x) matrix)               %
%           Theta == Incident angle of wave in Degrees (scaler)     %
%           active_layer == Indentified active region (integer)     %
%                                                                   %
%  Outputs: QE == Quantum Efficiency value (QE)(scaler)             %
%           Error == Error coding, 0 = no error, 1 = error          %
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Error Control of Inputs %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lambda_m,lambda_n]=size(lambda);
[theta_m,theta_n]=size(theta);
[thickness_m,thickness_n]=size(thickness);
[refractive_index_m,refractive_index_n]=size(refractive_index);

if isempty(refractive_index)==1||refractive_index_n==1
    disp('Invalid or Empty Layer Structure!!!')
    error=1;
    QE=NaN;
    return
elseif isempty(thickness)==1||length(thickness)==1
    disp('Invalid or Empty Thickness Structure!!!')
    error=1;
    QE=NaN;
    return
elseif any(theta(:)<0)||any(theta(:)>90)||isempty(theta)==1
    disp('Invalid Theta-Angle Input:  Must be 0<=THETA<=180!!!')
    error=1;
    QE=NaN;
    return
elseif any(lambda(:)<=0)||isempty(lambda)==1
    disp('Invalid Lambda Input:  Lambda must be greater then Zero!!!!')
    error=1;
    QE=NaN;
    return
elseif refractive_index_n~=thickness_n
    disp(['Invalid Layer and Thickness structure: ',...
        'Number of elements must be indentical!!!!'])
    error=1;
    QE=NaN;
    return
elseif any(thickness(:)<0)
    disp(['Invalid Thickness structure: ',...
        'No elements can be less then Zero thickness!!!!'])
    error=1;
    QE=NaN;
    return
elseif lambda_n>1
    disp(['Invalid Lambda input: Must be [m,1] matrix!!!!'])
    error=1;
    QE=NaN;
    return
elseif theta_n>1
    disp(['Invalid Theta input: Must be [m,1] matrix!!!!'])
    error=1;
    QE=NaN;
    return
elseif lambda_m>1&&theta_m>1&&thickness_m>1
    disp(['Invalid Lambda, Theta, and Thickness input: ',...
        'Can only have one multivariable per run!!!!'])
    error=1;
    QE=NaN;
    return
elseif isempty(active_layer)==1
    disp(['Unspecified Active Layer: ',...
        'You must specify the active region!!!!'])
    error=1;
    QE=NaN;
    return
elseif length(active_layer)>1
    disp(['Invalid Active Layer input: ',...
        'Can only calculate for single layer (scaler)!!!!'])
    error=1;
    QE=NaN;
    return
else
    error=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%End of Input Error control %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Input multi-variable control %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if lambda_m>1
    length_of_run=lambda_m;
elseif theta_m>1
    length_of_run=theta_m;
elseif thickness_m>1
    length_of_run=thickness_m;
else
    length_of_run=lambda_m;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%End of Input mulit-variable control %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=sqrt(-1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Quantum Efficiency Calculation  %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
no_layers=refractive_index_n; %number of layers used in calculation
theta=theta.*pi./180;  %convert theta into radians

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1|2   3|4   5|6   7|8       Interface Structure
% I|  2  |  3  |  4  | S      Layer Structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

before=2*active_layer-3; %Interface before Active region
after=2*active_layer; %Interface after Active region

%%%%%%%%%%% Snell's Law at interfaces and TM waves %%%%%%%%%%%%%%%%%%%
%
% This code is to fix a singularity that exists due to absorption length
% being much less than the layer thickness.  in that case i limit the
% thickness to be no longer than the absorption length
%
for j=1:no_layers
    temp_thickperlambda(:,j)=thickness(:,j)./lambda;
    if 1==1
        wavelength_threshold=500;
        if min(lambda)<wavelength_threshold
            limited_thickness=min(-log(1e-15)./absorp_byrindex(lambda,refractive_index(:,j)),...
                thickness(:,j));
            temp_thickperlambda(:,j)=limited_thickness./lambda;
        end
    end
end

for j=1:no_layers
    %   thetam(:,j)=asin(refractive_index(:,1)./refractive_index(:,j).*sin(theta));
    thetam(:,j)=asin(real(refractive_index(:,1))./real(refractive_index(:,j)).*sin(theta));
    eta(:,j)=refractive_index(:,j).*cos(thetam(:,j)); %TE Polarization layers index
    %delta(:,j)=2.*pi.*refractive_index(:,j).*thickness(:,j).*cos(thetam(:,j))./lambda;
    delta(:,j)=2*pi.*refractive_index(:,j).*cos(thetam(:,j)).*temp_thickperlambda(:,j);
end
eta(:,1)=real(eta(:,1)); %Incident medium must be Real (non-absorbing)

%%%%%%%%%%%% Scattering Matrix Calculation %%%%%%%%%%%%%%%%%%%%%%%%%%%
TEMP_11=ones(length_of_run,1); %Scattering Matrix calculation
TEMP_12=zeros(length_of_run,1); %Scattering Matrix calculation
TEMP_21=zeros(length_of_run,1); %Scattering Matrix calculation
TEMP_22=ones(length_of_run,1); %Scattering Matrix calculation
if no_layers>2  %Matrix formulation not used for two layer structure
    for j=2:no_layers-1  %middle layer matrix
        z_11(:,j)=TEMP_11(:,1).*cos(delta(:,j))+TEMP_12(:,1).*i.*sin(delta(:,j)).*eta(:,j);
        z_12(:,j)=TEMP_11(:,1).*i.*sin(delta(:,j))./eta(:,j)+TEMP_12(:,1).*cos(delta(:,j));
        z_21(:,j)=TEMP_21(:,1).*cos(delta(:,j))+TEMP_22(:,1).*i.*sin(delta(:,j)).*eta(:,j);
        z_22(:,j)=TEMP_21(:,1).*i.*sin(delta(:,j))./eta(:,j)+TEMP_22(:,1).*cos(delta(:,j));
        TEMP_11(:,1)=z_11(:,j);
        TEMP_12(:,1)=z_12(:,j);
        TEMP_21(:,1)=z_21(:,j);
        TEMP_22(:,1)=z_22(:,j);
    end
end

D1_11=ones(length_of_run,1);
D1_12=ones(length_of_run,1);
D1_21=eta(:,1);
D1_22=-eta(:,1);

det_D1=D1_11.*D1_22-D1_12.*D1_21;

%D1 Inverse
D1_11=-eta(:,1)./det_D1;
D1_12=-ones(length_of_run,1)./det_D1;
D1_21=-eta(:,1)./det_D1;
D1_22=ones(length_of_run,1)./det_D1;

Dm_11=ones(length_of_run,1);
Dm_12=ones(length_of_run,1);
Dm_21=eta(:,no_layers);
Dm_22=-eta(:,no_layers);

M_11=D1_11.*TEMP_11+D1_12.*TEMP_21;
M_12=D1_11.*TEMP_12+D1_12.*TEMP_22;
M_21=D1_21.*TEMP_11+D1_22.*TEMP_21;
M_22=D1_21.*TEMP_12+D1_22.*TEMP_22;

M_11=M_11.*Dm_11+M_12.*Dm_21;
M_12=M_11.*Dm_12+M_12.*Dm_22;
M_21=M_21.*Dm_11+M_22.*Dm_21;
M_22=M_21.*Dm_12+M_22.*Dm_22;

% Set up A and B matrix
A=zeros(length_of_run,(2*no_layers-2));
B=zeros(length_of_run,(2*no_layers-2));

%Incident right going E field component
A(:,1)=1;

%Incident left going E field component =A*reflection coeff
B(:,1)=M_21./M_11.*A(:,1);

%%%%% E field calculation through interface after active layer %%%%%
for r=1:active_layer
    D1_11=ones(length_of_run,1);
    D1_12=ones(length_of_run,1);
    D1_21=eta(:,r);
    D1_22=-eta(:,r);

    D2_11=ones(length_of_run,1);
    D2_12=ones(length_of_run,1);
    D2_21=eta(:,r+1);
    D2_22=-eta(:,r+1);

    det_D2=D2_11.*D2_22-D2_12.*D2_21;

    %D2 inverse
    D2_11=-eta(:,r+1)./det_D2;
    D2_12=-ones(length_of_run,1)./det_D2;
    D2_21=-eta(:,r+1)./det_D2;
    D2_22=ones(length_of_run,1)./det_D2;

    P_11=exp(i.*delta(:,r+1));
    P_12=zeros(length_of_run,1);
    P_21=zeros(length_of_run,1);
    P_22=exp(-i.*delta(:,r+1));

    det_P=P_11.*P_22-P_12.*P_21;

    %P inverse
    P_11=exp(-i.*delta(:,r+1))./det_P;
    P_12=-zeros(length_of_run,1)./det_P;
    P_21=-zeros(length_of_run,1)./det_P;
    P_22=exp(i.*delta(:,r+1))./det_P;

    j=2*r;
    k=2*r-1;
    %[A;B]=D_2^-1*D_1*[A(k);B(k)];
    %Right going E field
    A(:,j)=(D2_11.*D1_11+D2_12.*D1_21).*A(:,k)+...
        (D2_11.*D1_12+D2_12.*D1_22).*B(:,k);
    %Left going E field
    B(:,j)=(D2_21.*D1_11+D2_22.*D1_21).*A(:,k)+...
        (D2_21.*D1_12+D2_22.*D1_22).*B(:,k);

    j=j+1;
    k=k+1;
    %[A;B]=P^-1*[A(k);B(k)];
    A(:,j)=P_11.*A(:,k)+P_12.*B(:,k); %Right going E field
    B(:,j)=P_21.*A(:,k)+P_22.*B(:,k); %Left going E field
end
%%%%% Quantum Efficiency %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Sz_before=real(refractive_index(:,active_layer-1).*conj(cos(thetam(:,active_layer-1))).*...
    (A(:,before)+B(:,before)).*(conj(A(:,before)-B(:,before))));

Sz_after=real(refractive_index(:,active_layer+1).*conj(cos(thetam(:,active_layer+1))).*...
    (A(:,after)+B(:,after)).*(conj(A(:,after)-B(:,after))));

Sz_incident=real(refractive_index(:,1).*conj(cos(thetam(:,1))).*...
    A(:,1).*conj(A(:,1)));

QE=(Sz_before-Sz_after)./Sz_incident;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% End of Quantum Efficiency Calculation  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% End of Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
