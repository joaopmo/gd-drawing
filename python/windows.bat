@echo off
set batdir=%~dp0
%batdir%cnn\Scripts\activate.bat && python %batdir%main.py %1