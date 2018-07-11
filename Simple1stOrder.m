
%-------------------------------------------------------------------
% A simple function to study the characteristics of the first order
% response
%-------------------------------------------------------------------
vmem = []; tm = 32;
cal = []; tc = 64;
ep = 0; tp = 4;
en = 0; tn = 8;
ip = 0; % not use at this time
in = 0;
v = 0; % initial vmem
c = 0;
vth = 20; % threshold
end_time = 500;
for i = 1:end_time
    % keep track of the v
    vmem = [vmem, v];
    cal = [cal, c];
    
    v = v - v/tm;
    c = c - c/tc;
    if(1)
        v = v+2;
    end
    if(v > vth)
        v = 0;
        c = c+1;
        %i
    end
end
figure(1)
plot(1:length(cal), cal, 'r-');
figure(2)

plot(1:length(vmem), vmem, 'b-')