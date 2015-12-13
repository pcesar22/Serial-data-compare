% Function that captures serial data coming from a serial interface.
% Receives data from up to three different types, and
% plots them in a graph in real time

% Copyright (C) 2015 Paulo Costa
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% 
% GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% INSTRUCTIONs
% 1) Separate the three values you want to plot by commas.
%   Example: "13,2.34,15" (quotations not included in the
%   transmitted signal)
%   The program assumes a string with the floating point
%   values separated by commas.
% 2) Run the program. The data MUST be sent at the same baud rate chosen
%   below. 

clc; clear all; close all;

%% User parameters - EDIT HERE

% Set baudrate. Don't use high values such as 115200+, bit
% error rates increase significantly
baudrate = 9600; 

% Set the com port. On Windows, it's usually the 'COMX'
% ports, where 'X' is a number. if you don't know which
% devices are connected, run the command "instrfindall" on
% MATLAB or go to "device manager" (Windows).
comport = 'COM3';

% Variable names. Indicate the variable names to show them
% in your graph. Will only update in the final graph,
% because graph update is slow during updates, for unknown reasons.

val1name = '\theta';
val2name = '\omega';
val3name = 'u';

%% Initialization

% Kill any previous serial connections
delete(instrfindall);

% Connect to serial port
s = serial(comport);
set(s,'Baudrate',baudrate); 
fopen(s);

% Storage vectors
val1vec = zeros(1,100); 
val2vec = zeros(1,100);
val3vec = zeros(1,100);
% Sample axis
x = 0:1:99;

% Set up plot
figure;
h = plot(x,val1vec,'red', x, val2vec, 'green', ...
    x, val3vec, 'blue');


xlabel('Samples');
title('Mobile Inverted Pendulum Control');
ylim([-110,110]);
xlim([0,99]);
set(h,'LineWidth',1.8);
i = 1;


%% Main loop

% Scan the first value. This, for some reason, makes up for
% some mistakes that occur during the first transmissions.
out = fscanf(s);

while i < 1000
    
   % Get string
   out = fscanf(s);
   
   % Separate string by commas
   C = strsplit(out, ',');
   
   % Transform string values into floats
   val1 = str2double(C(1));
   val2  = str2double(C(2));
   val3 = str2double(C(3));
   
   
   %% Plot
   if(i < 100)
      val1vec(i) = val1;
      val2vec(i) = val2;
      val3vec(i) = val3;
   else
      for j = 1:99
         val1vec(j) = val1vec(j+1); 
         val2vec(j) = val2vec(j+1);
         val3vec(j) = val3vec(j+1);
      end
      val1vec(100) = val1;
      val2vec(100) = val2;
      val3vec(100) = val3;
   end
   totalVec = num2cell([val1vec ; val3vec; val2vec],2);
   set(h,'XData',x,{'YData'},totalVec);
   
   drawnow;   % Updates the graph faster
   i = i +  1;
    
end

% Place legend on plot
legend(val1name, val2name, val3name);

% Clean up serial connection
fclose(instrfindall);
delete(instrfindall);
clear s ;