function [n_abs]=absorp_byrindex(wavelength,refractive_index)
%used to calculate absorption in conjunction with n_index.m from LFOSR

n_abs=4.*pi.*abs(imag(refractive_index))./wavelength;  %nm^-1 (units dependent on wavelength variable)

return