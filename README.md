# Matlab-LFOSR
Layered Film Optical Simulation Routine - includes both film reflectance calculator and photodetector efficiency calculator

The Layer Film Optical Simulation Routine package contains a toolkit of files to simulate the optical properties of layered films of finite thickness. There is also a part of the package that can simulate the Quantum Efficiency of a detector based on absorption in a specific region of the layered structure. The toolkit was created at Boston University in the Picosecond Spectroscopy and Near-Field Microscopy Lab for use on our various optics projects as well as our photodetector work.

The LFOSR package relies on the Scattering Matrix method to calculate the electric field intensity in various regions of a layered film structure. The simulation is for normal and non-normal incidence of plane waves, and assumes that the exit medium is infinite in length or completely absorping so that the backward reflected wave is zero. Using this method the TM and TE reflection and transmission coefficients are calculated and are plotted as Reflectivity, Transmittance, and Phase. The simulation can vary either the incident wavelength, incident angle, or a single layer thickness. When wavelength is varied the output plots can show the Reflectivity, etc. as a function of either wavelength or energy. The output plots also offer the option for saving data, saving figures, or changing between Reflectivity, Transmittance, or Phase. Perhaps the most powerful aspect of the package is the ability to see the affect of varying layer thickness or incident angle and or wavelength with the adjustment slider bars on the output plot. One can compare simulation with results and tune the Reflectivity, Transmittance, or Phase to the best-fit thickness of the layers in the structure.

References:
Macleod, H. A. (Hugh Angus), Thin Film Optical Filters, 2nd Edition, New York: McGraw-Hill, ISBN-0070446946, 1989.
Yeh, Pochi, Optical Waves in Layered Media, New York: John Wiley & Sons, Inc., ISBN-0471828661, 1988.

Matlab Setup:
Copy all files to a local directory on your computer and add the path, including subfolders (common_files and common_files/index_data) to Matlab.  Run film.m or detector.m at the Matlab command prompt to launch the film or detector graphical interface.

More information can be found here: http://mattemsley.com/lfosr/index.html
