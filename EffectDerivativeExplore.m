%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A function wrapper for investigating the derivative of
% the accumulated synaptic effect w.r.t spike time shifts 
% and input spike count change
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
pts = 1;

end_time = 1000; % Set the end simulation time
input_neuron = 10;
freq = rand(input_neuron, 1)*0.2;
weights = 2*rand(1, input_neuron) - 0.5;

for it = 1:pts
    spikes = rand(length(freq), end_time);
    for i = 1:length(freq)
        spikes(i, :) = spikes(i,:) < freq(i);
    end
    
    % randomly pick one input neuron
    pivot = 1;
    
    % simulate the original network
    [~, ~, o_org, ~, ~, a_k_org] = VectorizedSNN(spikes, weights, [], vth, tm, ts);
    a_k_org = a_k_org ./ weights;
    
    % add/reduct one spike
    pick_more = mod(round(rand() * 100000), end_time) + 1;
    spikes_more = spikes;
    spikes_more(pivot, pick_more) = 1 - spikes_more(pivot, pick_more);
    
    % simulate the add-one spike network
    [~, ~, o_morespike, ~, ~, a_k_morespike] = VectorizedSNN(spikes_more, weights, [], vth, tm, ts);
    a_k_morespike = a_k_morespike ./ weights;
    diff_morespike = sum(abs(a_k_morespike(1, pivot) - a_k_org(1, pivot)));
    str = sprintf('The derivative w.r.t. to input spike count change: %f', diff_morespike);
    disp(str);
    
    % shift the time
    ones_ind = find(spikes(pivot, :) == 1);
    pick_shift = ones_ind(randsample(1:length(ones_ind), 1));
    
    spikes_shift = spikes;
    spikes_shift(pivot, pick_shift) = 0;
    if(pick_shift + 1 > end_time)
        continue;
    end
    spikes_shift(pivot, pick_shift + 1) = 1;
    
    % simulate the time shift network
    [~, ~, o_timeshift, ~, ~, a_k_timeshift] = VectorizedSNN(spikes_shift, weights, [], vth, tm, ts);
    a_k_timeshift = a_k_timeshift ./ weights;
    
    diff_timeshift = sum(abs(a_k_timeshift(1, pivot) - a_k_org(1, pivot)));
    str = sprintf('The derivative w.r.t. to input spike time shifts: %f', diff_timeshift);
    disp(str);
end
