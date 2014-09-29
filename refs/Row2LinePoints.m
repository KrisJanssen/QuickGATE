function [ linepoints ] = Row2LinePoints( linerow )
%ROW2LINEPOINTS Summary of this function goes here
%   Detailed explanation goes here

linepoints = [ linerow(1,1) linerow(1,2) ; linerow(1,1) + linerow(1,3) linerow(1,2) + linerow(1,4) ];

end

