%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A function wrapper for investigating the relationship between 
% \delta f_cnt  and \delta w * grad
% 
% Params: 
%        spikes : the binary matrix of the spikes (m x end_time)
%        weights : the vector of the input weights (m x 1)
%        end_time : the end time of the input spike trains
%        vth : the threshold voltage
%        tm : the time constant of the vmem
%
% Output: o_org : the output spike counts
%         a_k_org : the accumulative synaptic effect
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tm = 64;
ts = 8;
vth = 20;
pts = 1000;

end_time = 500; % Set the end simulation time
input_neuron = 10;
freq_level = 0.3;
freq = freq_level * rand(input_neuron, 1) * ones(1, end_time);
weights = 2*rand(1, input_neuron) - 0.5;
errors = zeros(pts, 1);
bigger = 0;
total = 0;

ratio_org = zeros(pts, input_neuron);
ratio_new = zeros(pts, input_neuron);

for it = 1:pts
    spikes = rand(input_neuron, end_time) < freq;
        
    % randomly pick one input neuron
    pivot = [1, 3];
    
    % simulate the original network
    [vmem_org, o_spikes_org, o_org, ~, ~, a_k_org] = VectorizedSNN(spikes, weights, [], vth, tm, ts);
    a_k_org = a_k_org ./ weights;
    if(o_org ~= 0)
        ratio_org(it,:) = a_k_org / (sum(spikes, 2)' * o_org);
    end
    
    % perturb the weight
    delta_w = 0.2 * (2*rand(1, length(pivot)) - 1);
    weights_new = weights;
    weights_new(pivot) = weights(pivot) + delta_w;
    
    
    % simulate the weight changed network
    [vmem_new, o_spikes_new, o_new, ~, ~, a_k_new] = VectorizedSNN(spikes, weights_new, [], vth, tm, ts);
    a_k_new = a_k_new ./ weights_new;
    combined_spikes = [o_spikes_org == 1; o_spikes_new == 1];
    %figure
    %plotSpikeRaster(combined_spikes, 'PlotType', 'vertline');
    
    actual_change = o_new - o_org;
    computed_change = sum(a_k_new(1, pivot) .* delta_w / vth);
    %fprintf('The computed fire count change: %f\n', computed_change);
    %fprintf('The actual fire count change: %f\n', actual_change);
    
    % keep track of the error for any visible changes
%     if(abs(actual_change) > 0)
%         errors(it) = abs(actual_change) - abs(computed_change) / abs(actual_change);
%     end
%     
%     if abs(actual_change) > 0 && abs(actual_change) >= abs(computed_change)
%         bigger = bigger + 1;
%     end
%     if abs(actual_change) > 0
%         total = total + 1;
%     end
    %error = error + abs(actual_change - computed_change);
    %actual_grad =(o_new - o_org) / delta_w;
    %computed_grad = a_k_new(1, pivot) / vth;
    
    %fprintf('The computed derivative w.r.t. to weight change: %f\n', computed_grad);
    %fprintf('The actual derivative w.r.t. to weight change: %f\n', actual_grad)
    
end
%fprintf('The overall error: %f\n', error / pts);
% fprintf('The percentage of actual > computed : %f\n', 100 * (bigger) / total);
% errors(errors == 0) = [];
% fprintf('The mean match error: %f\n and the variance of the match error: %f\n', mean(errors), var(errors));
% figure(3)
% histogram(errors, 'Normalization','probability');
% xlabel({'$\frac{|\Delta f| - |\Delta \hat{f}|}{|\Delta f|}$'}, 'Interpreter', 'latex')
% ylabel('Density');