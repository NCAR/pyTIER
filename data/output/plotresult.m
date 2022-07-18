clc
clear all
close all



finalField10 = ncread('caliOutput_prcp_10sta.nc', 'finalField');
finalField11 = ncread('caliOutput_prcp_11sta.nc', 'finalField');
finalField12 = ncread('caliOutput_prcp_12sta.nc', 'finalField');
finalField13 = ncread('caliOutput_prcp_13sta.nc', 'finalField');
finalField14 = ncread('caliOutput_prcp_14sta.nc', 'finalField');
finalField15 = ncread('caliOutput_prcp_15sta.nc', 'finalField');

% symapUncert = ncread('caliOutput_prcp_13sta.nc', 'symapUncert');
% slopeUncert  = ncread('caliOutput_prcp_13sta.nc', 'slopeUncert');
