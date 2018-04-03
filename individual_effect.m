%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Given the input and output spikes, compute the individual 
% synaptic effect at time points when the output fires.
%
% Input: input : input spikes (n x end_time)
%        i_ind : pre neuron index of the synapse
%        output: output spikes (m x end_time)
%        o_ind : post neuorn index of the synapse
%
% Output: effects : effects for the chosen synapse at each post firing times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [effects] = individual_effect(input, i_ind, output, o_ind)
    tm = 64;
    ts = 8;
    t_ref = 2;
    pre_times = find(input(i_ind,:) == 1);
    post_times = find(output(o_ind,:) == 1);
    effects = zeros(length(post_times), 1);
    % for each time point when the output fires
    for i = 1:length(effects)
        t_post = post_times(i);
        if(i == 1)
            last_post = 1;
        else
            last_post = post_times(i-1) + t_ref; 
        end
        lb = max(1, t_post - 4*tm);
        ub = t_post;
        effect_spike_times = pre_times(pre_times >= lb & pre_times < ub) + t_ref; % compensate the effect of refractory period
        
        if(isempty(effect_spike_times))
            continue;
        end
        
        [r, c] = size(effect_spike_times);        
        ss = (t_post - last_post) * ones(r, c);
        tt = t_post * ones(r, c) - effect_spike_times;
        factor = exp(-max(tt - ss, 0)/ts)/(1 - ts/tm);
        all_spike_resp = factor .* (exp(-min(ss, tt)/tm) - exp(-min(ss, tt)/ts));
        all_spike_resp(effect_spike_times > t_post) = 0;
        effects(i) = sum(all_spike_resp);
        
%         for j = 1:length(effect_spike_times)
%             if(effect_spike_times(j) > t_post)
%                 continue;
%             end
%             ss = t_post - last_post;
%             tt = t_post - effect_spike_times(j);
%             factor = exp(-max(tt - ss, 0)/ts)/(1 - ts/tm);
%             effects(i) = effects(i) + factor*(exp(-min(ss, tt)/tm) - exp(-min(ss, tt)/ts));
%         end
    end
end



