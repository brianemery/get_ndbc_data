 function [u,v] = speeddir2uv(speed, dir)
 
%  SPEEDDIR2UV
%  [u,v] = speeddir2uv(speed, dir)
%  converts speed and direction to u/v velocity components. dir is the
%  angle measured in degrees CCW from east, where east = 0 degrees.
%  speed can be +or-, with the angle given in 'dir' defining the heading 
%  of the positive velocity direction. 
%
%  see also uv2magdir, and getNDBCWindData.m in get_other_data.m
%
%  NOTE: 
%  use this for converting wind data with 'from' wind direction in
%  cwN to u and v:
%  [u,v] = speeddir2uv(-wspd,cwN2ccwE(wd));
%  
%  ... and back (such as after filtering):
% [wspd,wd_cwN]=uv2magdir(-u,-v);
%

%  Pirated by Brian Emery 18Dec97

u = speed .* cos((pi/180).*(dir));
v = speed .* sin((pi/180).*(dir));
