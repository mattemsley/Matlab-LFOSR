function [R,T,P,error]=ReflectionTE(lambda,refractive_index,thickness,theta,Length,User_selection)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ReflectionTE.m                                                   %
%  Date: 2/13/2001                                                  %
%  Version: 1.3                                                     %
%  Authors:  John W. Graff                                          %
%            Matthew K. Emsley                                      %
%                                                                   %
%  Updates:                                                         %
%           v1.3 2/13/2001 - Update to handle string input for      %
%                            layer array instead of previous        %
%                            number assignment                      %
%           v1.2 4/22/2000 - Update to handle matrix inputs for     %
%                            lambda and theta individually          %
%                            output now an array                    %
%           v1.1 4/30/1999 - Corrected return values for error      %
%                            codes R,T,P must return NaN instead    %
%                            of [], Removed index calculations to   %
%                            make external, Theta dependence of     %
%                            incident index fixed for TM            %
%           v1.0 4/29/1999 - First Release                          %
%                                                                   %
%  Description:  ReflectionTE.m calculates the reflection and       %
%                transmission from a layered structure              %
%                using film scattering matrix calculations.         %
%                                                                   %
%  Limitations:  1) Reflection and transmission are only            %
%                calculated for TE polarization.                    %
%                                                                   %
%  Inputs:  Lambda == Wavelength in nanometers  ((x;1)matrix)       %
%           Layer == Layer matrix  ((x;:)matrix) of strings         %
%           Thickness == Thickness matrix nanometers ((1;x) matrix) %
%           Theta == Incident angle of wave in Degrees ((x;1)matrix)%
%                                                                   %
%  Outputs: R == Reflection value (Reflection)((x;1)matrix)         %
%           T == Transmission value (Transmission)((x;1)matrix)     %
%           P == Phase of reflection (Phase(rad/sec)) ((x;1)matrix) %
%           Error == Error coding, 0 = no error, 1 = error          %
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Error Control of Inputs %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambda_m=size(lambda,1);
lambda_n=size(lambda,2);
theta_m=size(theta,1);
theta_n=size(theta,2);
thickness_m=size(thickness,1);
thickness_n=size(thickness,2);
refractive_index_m=size(refractive_index,1);
refractive_index_n=size(refractive_index,2);

if isempty(refractive_index)||refractive_index_n==1
   disp('Invalid or Empty Layer Structure!!!')
   error=1;
   R=NaN;
   T=NaN;
   P=NaN;
   return
elseif isempty(thickness)||length(thickness)==1||any(thickness<0)
   disp('Invalid or Empty Thickness Structure!!!')
   error=1;
   R=NaN;
   T=NaN;
   P=NaN;
   return
elseif any(theta<0)||any(theta>90)||isempty(theta)
   disp('Invalid Theta-Angle Input:  Must be 0<=THETA<=180!!!')
   error=1;
   R=NaN;
   T=NaN;
   P=NaN;
   return
elseif any(lambda<=0)||isempty(lambda)
   disp('Invalid Lambda Input:  Lambda must be greater then Zero!!!!')
   error=1;
   R=NaN;
   T=NaN;
   P=NaN;
   return
elseif refractive_index_n~=thickness_n
   disp(['Invalid Layer and Thickness structure: ',...
      'Number of elements must be indentical!!!!'])
   error=1;
   R=NaN;
   T=NaN;
   P=NaN;
   return
elseif lambda_n>1
   disp(['Invalid Lambda input: Must be [m,1] matrix!!!!'])
   error=1;
   R=NaN;
   T=NaN;
   P=NaN;
   return
elseif theta_n>1
   disp(['Invalid Theta input: Must be [m,1] matrix!!!!'])
   error=1;
   R=NaN;
   T=NaN;
   P=NaN;
   return
elseif lambda_m>1&&theta_m>1&&thickness_m>1
   disp(['Invalid Lambda, Theta, and Thickness input: ',...
      'Can only have one multivariable per run!!!!'])
   error=1;
   R=NaN;
   T=NaN;
   P=NaN;
   return
else
   error=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%End of Input Error control %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=sqrt(-1);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Reflection and Transmission Calculation  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Y=2.6544e-3;            %Admittance of free space (epsilon_0/mu_0)^.5
no_layers=refractive_index_n; %number of layers used in calculation
theta=theta.*pi./180;  %convert theta into radians

%%%%%%%%%%%% Snell's Law at interfaces and TE waves %%%%%%%%%%%%%%%%%%%
%for j=1:no_layers
% %  thetam(:,j)=asin(refractive_index(:,1)./refractive_index(:,j).*sin(theta));
%   thetam(:,j)=asin(real(refractive_index(:,1))./real(refractive_index(:,j)).*sin(theta));
%   eta(:,j)=Y.*refractive_index(:,j).*cos(thetam(:,j)); %TE Polarization layers index
%   delta(:,j)=2.*pi.*refractive_index(:,j).*thickness(:,j).*cos(thetam(:,j))./lambda;
%end

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

if strcmpi(User_selection,'textured') && 1==0
    Textured_Angle=46.*pi./180;
    for j=1:no_layers
        if j>=Length
            thetam(:,j)=asin(real(refractive_index(:,1))./real(refractive_index(:,j)).*sin(theta-Textured_Angle));
        else
            thetam(:,j)=asin(real(refractive_index(:,1))./real(refractive_index(:,j)).*sin(theta));
        end
        eta(:,j)=refractive_index(:,j).*cos(thetam(:,j)); %TE Polarization layers index
        delta(:,j)=2*pi.*refractive_index(:,j).*cos(thetam(:,j)).*temp_thickperlambda(:,j);
    end
    %eta(1,:)
    %delta(1,:)
    %thetam(1,:).*180./pi
else
    for j=1:no_layers
        %   thetam(:,j)=asin(refractive_index(:,1)./refractive_index(:,j).*sin(theta));
        thetam(:,j)=asin(real(refractive_index(:,1))./real(refractive_index(:,j)).*sin(theta));
        eta(:,j)=refractive_index(:,j).*cos(thetam(:,j)); %TE Polarization layers index
        delta(:,j)=2*pi.*refractive_index(:,j).*cos(thetam(:,j)).*temp_thickperlambda(:,j);
    end
end
eta(:,1)=real(eta(:,1)); %Incident medium must be Real (non-absorbing)

%%%%%%%%%%%%% Scattering Matrix Calculation %%%%%%%%%%%%%%%%%%%%%%%%%%%
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
B=TEMP_11(:,1)+TEMP_12(:,1).*eta(:,no_layers); %Partial Scat Matrix
C=TEMP_21(:,1)+TEMP_22(:,1).*eta(:,no_layers); %Partial Scat Matrix

%%%%%%%%%% Reflection and Transmission %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r=(eta(:,1).*B-C)./(eta(:,1).*B+C); %reflection coefficient
R(:,1)=r.*conj(r);  % Reflection
%Transmission
T(:,1)=4.*eta(:,1).*real(eta(:,no_layers))./abs(eta(:,1).*B+C).^2; 
%%%%%%%%% Phase Change of Reflected Wave %%%%%%%%%%%%%%%%%%%%%%%%%%%
TEMP=C./B;
b=imag(TEMP);
a=real(TEMP);
Imag_phase=-2.*b.*eta(:,1);
Real_phase=eta(:,1).^2-a.^2-b.^2;
P(:,1)=angle(Real_phase+i.*Imag_phase).*(180/pi); %Phase change 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% End of Reflection and Transmission Calculation  %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% End of Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
