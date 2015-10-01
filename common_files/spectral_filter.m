function [RR_filtered,TT_filtered,PP_filtered,error_film_calculation]=spectral_filter(lambda,theta,thickness,refractive_index,Layer,Sweep_Variable,Timedebug,Line_suppress)

lambda_interest=1800;
Line_suppress=1;
No_Averages=10;
filter_points=5;
material_interest='Si';

if 0
    prompt = {'Wavelength of interest:','Material:','Which Layer'};
    title  = 'Data Scale Factor';
    lines  = 1;
    def    = {'850','Si','4'};
    answer = inputdlg(prompt,title,lines,def);
    %
    % If cancel is press then the plotting of the line is not performed
    %  and the routine returns without error
    %
    if ~isempty(answer)
        lambda_interest = str2double(answer{1});
        material_interest = answer{2};
        %if ischar(scale(i))|isempty(scale(i))
        %    error('Invalid entry, must be number.')
        %end
    else
        return    
    end        
end
    
deviation_max=lambda_interest./abs(n_index(lambda_interest,material_interest,0))/2; %nm

if 1
    for q=1:No_Averages
        r=q-1;
        thickness(:,end-1)=thickness(:,end-1)+deviation_max*(r-1)/No_Averages;
        
        [RR(:,:,q),TT(:,:,q),PP(:,:,q),error_film_calculation] = film_calculation(lambda,theta,thickness,refractive_index,Layer,Sweep_Variable,Timedebug,Line_suppress);
    end
    RR_temp=mean(RR,3);
    TT_temp=mean(TT,3);
    PP_temp=mean(PP,3);
else
    [RR,TT,PP,error_film_calculation] = film_calculation(lambda,theta,thickness,refractive_index,Layer,Sweep_Variable,Timedebug,Line_suppress);
    RR_temp=RR;
    TT_temp=TT;
    PP_temp=PP;
end

[temp12(1,:) temp12(2,:)]=mysmooth(RR_temp(1,:),RR_temp(2,:),filter_points);
[temp13(1,:) temp13(2,:)]=mysmooth(RR_temp(1,:),RR_temp(3,:),filter_points);
RR_filtered=[temp12(1,:); temp12(2,:); temp13(2,:)];

[temp12(1,:) temp12(2,:)]=mysmooth(TT_temp(1,:),TT_temp(2,:),filter_points);
[temp13(1,:) temp13(2,:)]=mysmooth(TT_temp(1,:),TT_temp(3,:),filter_points);
TT_filtered=[temp12(1,:); temp12(2,:); temp13(2,:)];

[temp12(1,:) temp12(2,:)]=mysmooth(PP_temp(1,:),PP_temp(2,:),filter_points);
[temp13(1,:) temp13(2,:)]=mysmooth(PP_temp(1,:),PP_temp(3,:),filter_points);
PP_filtered=[temp12(1,:); temp12(2,:); temp13(2,:)];

return
