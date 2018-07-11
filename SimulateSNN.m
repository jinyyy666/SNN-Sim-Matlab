%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A function wrapper for running the simulation of SNN
% steps by steps. FE is used here.
% Input: spikes : the binary matrix of the spikes (m x end_time)
%        weights : the vector of the input weights (m x 1)
%        end_time : the end time of the input spike trains
%        leak : the control variable to enable leak. 
%               can be 1 (leak) or 0 (no leak)
%        vth : the threshold voltage
%        tm : the time constant of the vmem
%
% Output: vmem : the of v_mem values at each simulation time
%         xk : the input synaptic response function 
%         h : the \sum_j w_ji*# spike_j, the weighted sum of spikes
%         o_spikes: the number of output spikes
%         hist : the histgram of the spike distribution
%         A_k : the variable to keep track of the accumulative effect
%         a_k : the break down effect of each synapse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vmem, x_k, h, o_spikes, hist, A_k, a_k] = SimulateSNN(spikes, weights, end_time, leak, vth, tm)
tmp = 0;
ep = 0; tep = 8;
en = 0; ten = 8;
ip = 0; tip = 4;
in = 0; tin = 2;
v = 0; % initial vmem
spike_cnt = 0; % the spike count
interval = 10; % sample time step
t_refrac_const = 2; % the refactotry period 
t_refrac = 0;


sample_size = floor(end_time / interval); % sample size for plotting spike cnt
actual = zeros(sample_size+1,1); % actual spike count
estimate = zeros(sample_size+1,1); % estimate spike count

vmem = zeros(end_time, 1);
% the vmem change at each time point:
x_k = zeros(end_time, 1);

A_k_pre = 0; % the accumulated effect from all the pre-spikes;
A_k = zeros(end_time, 1); 

a_k_pre = zeros(length(weights), 1); % the break-down effect for each synapse
a_k = zeros(end_time, length(weights));

last_i = 1; % the last post-synaptic neuron fire time

hist = zeros(3*tm, 1); % the histogram for the spike timing distribution

% the total accumulative spike effect within the time window
effect_auc = 0;

for i = 1:end_time
    
    if(leak == 1)
        v = v - v/tm;
    end
    ep = ep - ep/tep;
    en = en - en/ten;
    ip = ip - ip/tip;
    in = in - in/tin;
    if(i == 1)
        continue;
    end
    for j = 1:length(weights)
        if(spikes(j,i-1) == 1)
            if(weights(j) > 0) % if the pre-synaptic neuron is excitatory
                ep = ep + 1*weights(j); 
                en = en + 1*weights(j);
            else
                ep = ep + 1*weights(j);
                %ip = ip + 1*weights(j);
                %in = in + 1*weights(j);
            end
        end
    end
    %tmp = (ep - en)/(tep - ten) + (ip - in)/(tip - tin);
    tmp = ep/tep;
    v = v + tmp;
    
    % keep track of the v and x_k
    x_k(i) = tmp;
    vmem(i) = v;
    
    % Compute the effective effect for all spikes within the current
    % window
    [effect_auc, indv_effects] = compute_accumulative_effect(i, last_i, spikes, weights, tm, tep);
    % refractory peroid    
    if(t_refrac > 0)
        v = 0;
        t_refrac = t_refrac - 1;
        effect_auc = 0;
        indv_effects = zeros(length(weights), 1);
    end
    A_k(i) = A_k_pre + effect_auc;
    a_k(i, :) = a_k_pre' + indv_effects';
    
    
    if(v >= vth) 
        t_refrac = t_refrac_const;
        v = 0;
%         if(last_i ~= 1)
%            hist = verify_SRM_model(i, last_i, spikes, weights, tm, tep, hist); % verify if the SRM model is correct
%         end
%         s = sprintf('The accumulative effect is %f', effect_auc);
%         disp(s)
        
        % Start from the previous spike
        A_k_pre = A_k(i);
        a_k_pre = a_k(i,:)';
        last_i = i+t_refrac_const; % add the refrac const here to adjust!
        spike_cnt = spike_cnt + 1;
    end
    if(mod(i, interval) == 0)
        ind = 1+i/interval;
        actual(ind) = spike_cnt;
    end
end



o_spikes = spike_cnt;
h = sum(spikes')*weights;

% get the estimate spike count:
for i = 1:sample_size
    estimate(i+1) = A_k(i*interval)/vth; %max(0, floor(A_k_decay_vec(i*interval)/vth));
end

% plot the vmem, cumsum(xk) and spike count curve
if(0)
figure
for i = 1:3
    subplot(1,3,i)
    if(i == 1)
        plot(vmem)
        title('Vmem')
    elseif(i == 2)
        plot(A_k)
        title('Ak')
    else    
        plot(interval*(0:sample_size), actual, 'b', interval*(0:sample_size), estimate, 'r--')
        title('Spike Counts')
    end
end
end

end