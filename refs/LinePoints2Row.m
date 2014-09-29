function [ linerow ] = LinePoints2Row( linepoints )
%LINEPOINTS2ROW Summary of this function goes here
%   Detailed explanation goes here

linerow = [ linepoints(1,1), linepoints(1,2), linepoints(2,1) - linepoints(1,1), linepoints(2,2) - linepoints(1,2)];
end

