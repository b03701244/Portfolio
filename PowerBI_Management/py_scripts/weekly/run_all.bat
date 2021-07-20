@echo off

for %%A IN ("C:\Users\hlai\OneDrive - Analog Devices, Inc\Documents\Pipeline_PowerBI\py_scripts\weekly\*.py") do start /b /wait "" C:\Users\hlai\Anaconda3\python.exe "%%~fA" 

pause