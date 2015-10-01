function [license_number,error_code]=lfosr_license(FVersion)
if nargin~=1
    error('Incorrect number of input arguments.')
end

if versionnumber<5.3
    warndlg(['Function not available in Matlab v',num2str(versionnumber),'.  ',...
            'Please contact Matthew K. Emsley (memsley@bu.edu) to check for latest version.'],...
        'Version Check')
    license_number=NaN;
    error_code=1;
    
elseif versionnumber>=5.3
    try
        %      java on  % enable Java
        %      
        %      url = java.net.URL('http://www.mattemsley.com/LFOSR/license_value.txt');
        %      is  = openStream(url);
        %      isr = java.io.InputStreamReader(is);
        %      br  = java.io.BufferedReader(isr);

        %        for i = 1:3
        %            line = readLine(br);
        
        %
        % For version 6.0 and above readLine does not return char so must convert
        %
        %            line=char(line);  
        
        %            if i==1
        %                lines = line; % Add 1st text string
        %           else
        %               lines = str2mat(lines,line); % Add next string
        %           end
        %       end
        br=urlread('http://www.mattemsley.com/LFOSR/license_value.txt');
        lines=char(strread(br,'%s'));
        if ~isequal(str2double(lines(1,:)),FVersion)
            warndlg(['You are running LFOSR v',num2str(FVersion),...
                    '... LFOSR v',num2str(str2double(lines(1,:))),' is now Available.  ',...
                    'Please contact Matthew K. Emsley (memsley@bu.edu) for latest version.'],...
                'Version Check');
            error_code=1;
        else
            msgbox(['You are running LFOSR v',num2str(FVersion),...
                    ' which is the most current version.'],...
                'Version Check');
            error_code=0;
        end
        license_number=str2double(lines(2,:));
        
    catch
        warndlg(['You must be connected to the internet for this function to execute.  ',...
                'If you are connected, the server might be down.  Try again later.']...
            ,'Version Check');
        license_number=NaN;
        error_code=1;
        
    end
    
end

return
