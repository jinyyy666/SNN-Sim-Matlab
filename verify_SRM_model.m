%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A function to verify if the SRM model proposed in the
% book: "Spiking Neuron Models", Page 109 is correct
%
% Input: t_i: the firing time of the post-synaptic neuron
%        last_t_i: the last firing time of the post-synaptic neuron
%        spikes: the timing of the pre-synaptic spikes (binary matrix)
%        weights: the weights of the input synaptic (vector)
%        tm: time constant for the vmem
%        ts: time constant for the first order synaptic response
%        hist: the spike time distribution histogram
%   
% Output:
%       hist: the spike time distribution with the current time window
%       considered
%
% Note: ignore the effect of those spikes arrives before the 
%       previous spike of the t_i
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hist = verify_SRM_model(t_i, last_t_i, spikes, weights, tm, ts, hist)
    % Get the pre-synaptic neuron firing timings
    if(last_t_i == 1)
        return
    end
    effect_spikes = spikes(:, last_t_i : t_i);
    sum_effect_spikes = sum(effect_spikes)';
    [~, window_len] = size(effect_spikes); 
    % record the weight distribution here
    if(window_len >  length(hist))
        hist = hist + sum_effect_spikes( window_len - length(hist)+1 : window_len);
    else
        hist(length(hist) - window_len + 1 : length(hist)) = hist(length(hist) - window_len + 1 : length(hist)) + sum_effect_spikes;
    end
    
    [auc_effect, ~] = compute_accumulative_effect(t_i, last_t_i, spikes, weights, tm, ts);
%     s = sprintf('Total effect upon the post-synaptic neuron: %f', auc_effect);
%     disp(s)

%     if(window_len > 1.5*tm)
%         s = sprintf('Needed spikes to fire: %d', sum(sum(effect_spikes(:, window_len - 1.5*tm:window_len))));
%         disp(s)
%     end
%     
%     s = sprintf('Window length: %d', window_len);
%     disp(s)
    
    
end