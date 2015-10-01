function [StartFigTextColor,StartFigBackColor,OutputFigTextColor,OutputFigBackColor,...
    ButtonTextColor,ButtonBackColor,EditTextColor,EditBackColor,...
    FrameTextColor,FrameBackColor,FontName,FontUnits,FontWeight,FontAngle,...
    TitleTextFontSize,HeaderTextFontSize,BodyTextFontSize,Body2TextFontSize,...
    SmallTextFontSize,ButtonFontSize,SmallButtonFontSize,...
    StartFigWidth,StartFigHt,OutputFigWidth,OutputFigHt]=lfosr_fontscolors()

% This is the font set up for Unix systems
if isunix==1
    fid = fopen('lfosr_unixfont.txt','r');
    if fid==-1 %check for error on open
        error('Unable to open file.')
    end

    % This is the font set up for all other systems
else
    fid = fopen('lfosr_pcfont.txt','r');
    if fid==-1 %check for error on open
        error('Unable to open file.')
    end
end

FontName            = fgetl(fid);
FontUnits           = fgetl(fid);
FontSize            = str2double(fgetl(fid));
FontWeight          = fgetl(fid);
FontAngle           = fgetl(fid);
StartFigTextColor   = str2num(fgetl(fid));
StartFigBackColor   = str2num(fgetl(fid));
OutputFigTextColor  = str2num(fgetl(fid));
OutputFigBackColor  = str2num(fgetl(fid));
ButtonTextColor     = str2num(fgetl(fid));
ButtonBackColor     = str2num(fgetl(fid));
EditTextColor       = str2num(fgetl(fid));
EditBackColor       = str2num(fgetl(fid));
FrameTextColor      = str2num(fgetl(fid));
FrameBackColor      = str2num(fgetl(fid));
StartFigWidth       = str2double(fgetl(fid));
StartFigHt          = str2double(fgetl(fid));
OutputFigWidth      = str2double(fgetl(fid));
OutputFigHt         = str2double(fgetl(fid));
fclose(fid);
%%%%%%%%%%%%%%%%
TitleTextFontSize   = FontSize+6;
HeaderTextFontSize  = FontSize+2;
BodyTextFontSize    = FontSize+4;
Body2TextFontSize   = FontSize+1;
SmallTextFontSize   = FontSize;
ButtonFontSize      = FontSize+1;
SmallButtonFontSize = FontSize;

return