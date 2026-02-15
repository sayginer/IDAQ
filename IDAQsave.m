function [] = IDAQsave(FileName)
% IDAQsave - Create a submission zip file for IDAQ Lab assignments.
%   IDAQsave('FileName') creates a single ZIP file containing all files 
%   in the current working directory (excluding existing ZIP files) 
%   and captures all currently open figures.
%
%   This function is part of the Custom MATLAB Toolbox for MEE 2305: 
%   Instrumentation and Data Acquisition Lab at Temple University.
%
%   INPUT:
%      FileName - (Optional) String for the desired output zip file name.
%                 If omitted, the function may prompt for a name.
%
%   EXAMPLE:
%      % To save your current progress for a homework submission:
%      IDAQsave('Homework1_LastName')
%
%   Developed by: Dr. Osman Sayginer
%   Department of Mechanical Engineering, Temple University
%   Version: OS-260214
end