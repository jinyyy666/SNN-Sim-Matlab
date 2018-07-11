%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A matlab script to simulate the readout based 
% on the dumped response with the laterial inihibition.
%
% To double check if the accumulative effect model 
% is correct or not.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SimpleReadoutSim

% Only look at the vmem of output_0

% combine all the weights and response
combined_response = [reservoir; readout];
combined_weight = [weights; ones(26, 1)*(-8)];
combined_weight(length(weights)+1) = 0;


[vmem, x_k, h, o_spikes, hist, A_k, a_k] = SimulateSNN(combined_response, combined_weight, combined_weight, 1000, 1, 20, 64);

% load the v_mem from the simulator:
PlotVmem
v_mem = wave_o(1,:)';

vmem = vmem(1:length(v_mem));
vmem = [vmem, v_mem];