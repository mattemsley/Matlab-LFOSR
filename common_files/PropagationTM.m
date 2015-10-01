function [x_position,lambda_position,magnitude_E,error]=PropagationTM(lambda,refractive_index,thickness,incremental_distance,theta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  QuantumEffTM.m                                                   %%
%%  Version: 2.0                                                     %%
%%  Authors:  Gokhan Ulu                                             %%
%%            Matthew K. Emsley                                      %%
%%                                                                   %%
%%  Updates: v2.0 05/11/2000 - Update to handle matrix inputs for    %%
%%                            lambda and theta individually          %%
%%                            output now an array                    %%
%%           v1.0 12/16/1999 - First Release                         %%
%%                                                                   %%
%%  Description:  QuantumEffTM.m calculates the quantum efficiency   %%
%%                of an active layer placed between two mirrors      %%
%%                using film scattering matrix calculations.         %%
%%                                                                   %%
%%  Limitations:  1) Quantum Efficiency are only                     %%
%%                calculated for TM Polarization                     %%
%%                2) Supported materials only include Silicon,       %%
%%                Air, and Silicon Dioxide.                          %%
%%                                                                   %%
%%  Inputs:  ALL POINTS IN NANOMETERS!!!                             %%  
%%           Lambda == Wavelength in nanometers  (scaler)            %%
%%           Layer == matrix containing material types ((1;x)matrix) %%
%%           Thickness == matrix containing layer thicknesses        %%
%%                        in nanometers ((1;x) matrix)               %%
%%           Theta == Incident angle of wave in Degrees (scaler)     %%
%%           active_layer == Indentified active region (integer)         %% 
%%                                                                   %%
%%  Outputs: QE == Quantum Efficiency value (QE)(scaler)             %%
%%           Error == Error coding, 0 = no error, 1 = error          %%
%%                                                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Error Control of Inputs %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lambda_m,lambda_n]=size(lambda);
[theta_m,theta_n]=size(theta);
[thickness_m,thickness_n]=size(thickness);
[refractive_index_m,refractive_index_n]=size(refractive_index);

if isempty(refractive_index)==1|refractive_index_n==1
    disp('Invalid or Empty Layer Structure!!!')
    error=1;
    magnitude_E=NaN;
    x_position=NaN;
    return
elseif isempty(thickness)==1|length(thickness)==1
    disp('Invalid or Empty Thickness Structure!!!')
    error=1;
    magnitude_E=NaN;
    x_position=NaN;
    return
elseif any(theta<0)|any(theta>90)|isempty(theta)==1
    disp('Invalid Theta-Angle Input:  Must be 0<=THETA<=180!!!')
    error=1;
    magnitude_E=NaN;
    x_position=NaN;
    return
elseif any(lambda<=0)|isempty(lambda)==1
    disp('Invalid Lambda Input:  Lambda must be greater then Zero!!!!')
    error=1;
    magnitude_E=NaN;
    x_position=NaN;
    return
elseif refractive_index_n~=thickness_n
    disp(['Invalid Layer and Thickness structure: ',...
            'Number of elements must be indentical!!!!'])
    error=1;
    magnitude_E=NaN;
    x_position=NaN;
    return
elseif any(thickness<0)
    disp(['Invalid Thickness structure: ',...
            'No elements can be less then Zero thickness!!!!'])
    error=1;
    magnitude_E=NaN;
    x_position=NaN;
    return
elseif lambda_n>1
    disp(['Invalid Lambda input: Must be [m,1] matrix!!!!'])
    error=1;
    magnitude_E=NaN;
    x_position=NaN;
    return
elseif theta_n>1
    disp(['Invalid Theta input: Must be [m,1] matrix!!!!'])
    error=1;
    magnitude_E=NaN;
    x_position=NaN;
    return
elseif lambda_m>1&theta_m>1&thickness_m>1
    disp(['Invalid Lambda, Theta, and Thickness input: ',...
            'Can only have one multivariable per run!!!!'])
    error=1;
    magnitude_E=NaN;
    x_position=NaN;
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
for j=1:no_layers
    thetam(:,j)=asin(refractive_index(:,1)./refractive_index(:,j).*sin(theta));
    eta(:,j)=refractive_index(:,j)./cos(thetam(:,j)); %TM Polarization layers index
    delta(:,j)=2.*pi.*refractive_index(:,j).*thickness(:,j).*cos(thetam(:,j))./lambda;
end
eta(:,1)=real(eta(:,1)); %Incident medium must be Real (non-absorbing)

%%%%%%%%%%%% Scattering Matrix Calculation %%%%%%%%%%%%%%%%%%%%%%%%%%%
TEMP_11=ones(length_of_run,1); %Scattering Matrix calculation
TEMP_12=zeros(length_of_run,1); %Scattering Matrix calculation
TEMP_21=zeros(length_of_run,1); %Scattering Matrix calculation
TEMP_22=ones(length_of_run,1); %Scattering Matrix calculation
if no_layers>2  %Matrix formulation not used for two layer structure
    for j=2:no_layers-1  %middle layer matrix
        z_11(:,j)=TEMP_11(:,1).*cos(delta(:,j))...
            +TEMP_12(:,1).*i.*sin(delta(:,j)).*eta(:,j);
        z_12(:,j)=TEMP_11(:,1).*i.*sin(delta(:,j))./eta(:,j)...
            +TEMP_12(:,1).*cos(delta(:,j));
        z_21(:,j)=TEMP_21(:,1).*cos(delta(:,j))...
            +TEMP_22(:,1).*i.*sin(delta(:,j)).*eta(:,j);
        z_22(:,j)=TEMP_21(:,1).*i.*sin(delta(:,j))./eta(:,j)...
            +TEMP_22(:,1).*cos(delta(:,j));
        TEMP_11(:,1)=z_11(:,j);
        TEMP_12(:,1)=z_12(:,j);
        TEMP_21(:,1)=z_21(:,j);
        TEMP_22(:,1)=z_22(:,j);
    end
end

%D1 Inverse
ID1_11=ones(length_of_run,1)./2;
ID1_12=1./eta(:,1)./2;
ID1_21=ones(length_of_run,1)./2;
ID1_22=-1./eta(:,1)./2;

Dm_11=ones(length_of_run,1);
Dm_12=ones(length_of_run,1);
Dm_21=eta(:,no_layers);
Dm_22=-eta(:,no_layers);

M_11=ID1_11.*TEMP_11+ID1_12.*TEMP_21;
M_12=ID1_11.*TEMP_12+ID1_12.*TEMP_22;
M_21=ID1_21.*TEMP_11+ID1_22.*TEMP_21;
M_22=ID1_21.*TEMP_12+ID1_22.*TEMP_22;

M_11=M_11.*Dm_11+M_12.*Dm_21;
M_12=M_11.*Dm_12+M_12.*Dm_22;
M_21=M_21.*Dm_11+M_22.*Dm_21;
M_22=M_21.*Dm_12+M_22.*Dm_22;

%
% Set up A and B matrix
%
A=zeros(length_of_run,(2*no_layers-2));
B=zeros(length_of_run,(2*no_layers-2));

%
%Incident right going E field component
%
A(:,1)=1; 

%
%Incident left going E field component =A*reflection coeff
%
B(:,1)=M_21./M_11.*A(:,1); 

%%%%% E field calculation through interface after active layer %%%%%
for r=1:no_layers-1
    D1_11=ones(length_of_run,1);
    D1_12=ones(length_of_run,1);
    D1_21=eta(:,r);
    D1_22=-eta(:,r);
    
    %D2 inverse
    ID2_11=ones(length_of_run,1)./2;
    ID2_12=1./(2*eta(:,r+1));
    ID2_21=ones(length_of_run,1)./2;
    ID2_22=1./(-2*eta(:,r+1));
    
    %P inverse
    P_11=exp(-i.*delta(:,r+1));
    P_12=zeros(length_of_run,1);
    P_21=zeros(length_of_run,1);
    P_22=exp(i.*delta(:,r+1));
    
    j=2*r;
    k=2*r-1;
    %[A;B]=D_2^-1*D_1*[A(k);B(k)];
    %Right going E field
    temp_A=(ID2_11.*D1_11+ID2_12.*D1_21);
    temp_B=(ID2_11.*D1_12+ID2_12.*D1_22);
    A(:,j)=temp_A.*A(:,k)+temp_B.*B(:,k);
    
    %Left going E field
    temp_A=(ID2_21.*D1_11+ID2_22.*D1_21);
    temp_B=(ID2_21.*D1_12+ID2_22.*D1_22);
    B(:,j)=temp_A.*A(:,k)+temp_B.*B(:,k);
    
    if r~=no_layers-1
        j=j+1;
        k=k+1;
        %[A;B]=P^-1*[A(k);B(k)];
        A(:,j)=P_11.*A(:,k)+P_12.*B(:,k); %Right going E field
        B(:,j)=P_21.*A(:,k)+P_22.*B(:,k); %Left going E field
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% End of Quantum Efficiency Calculation  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_position=0;
thickness_total=thickness(1:end-1);
thickness_total(1)=0;
for r=2:no_layers-1
    thickness_total(r)=thickness_total(r)+thickness_total(r-1);
    
end
x_position=(0:incremental_distance:thickness_total(end))';

E=zeros(length(x_position),length(lambda));
mat_n=zeros(length(x_position),length(lambda));

for r=2:no_layers-1
    rightinterface = 2*r-2;
    leftinterface  = 2*r-1;
    
    x_current_points=x_position>=thickness_total(r-1) & x_position<thickness_total(r);
    
    PosRight=(x_position-thickness_total(r-1));
    PosLeft=(x_position-thickness_total(r));
    
    [mat_A mat_PosRight]=meshgrid(A(:,rightinterface),PosRight);
    [mat_B mat_PosLeft]=meshgrid(B(:,leftinterface),PosLeft);
    mat_Beta=repmat(beta(:,r)',length(x_position),1);
    x_current_points=repmat(x_current_points,1,length(lambda));
    
    mat_n=mat_n+real(refractive_index(r)).*x_current_points;
    
    E=E+(mat_A.*exp(-i.*mat_Beta.*mat_PosRight)+mat_B.*exp(i.*mat_Beta.*mat_PosLeft)).*x_current_points;
end

magnitude_E=mat_n.*(E.*conj(E));

magnitude_E=magnitude_E./max(max(magnitude_E));

lambda_position=lambda;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% End of Quantum Efficiency Calculation  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% End of Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
