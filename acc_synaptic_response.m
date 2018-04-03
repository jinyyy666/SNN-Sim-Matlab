%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the accumulated synaptic effect of each synapse
% 
% Input : 
%       i_spikes : binary matrix of input spike trains (n x end_time)
%       o_spikes : binary matrix of output spike trains (m x end_time)
%       weights : the weight matrix from the input -> output (m x n)
%       self_weights : the weight matrix describing the recurrent
%       connections of the output neuron group (reservoir)
%
% Output:
%       A_k : the variable to keep track of accumulative effect (m x 1)
%
%       a_k : the break down effect of each synapse (m x n) or 
%       (m x (n + m)) if self_weight is not empty
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A_k, a_k] = acc_synaptic_response(i_spikes, o_spikes, weights, self_weights)
    % m : # of output neurons
    % n : # of input neurons
    [m, n] = size(weights);
    [r, ~] = size(i_spikes);
    assert(r == n, 'The row dim %d of the spike does not match with the input: %d!', r, n);
    
    if(isempty(self_weights))
        a_k = zeros(m, n);
    else
        a_k = zeros(m, n + m);
    end
    
    [o_indices, i_indices] = find(weights ~= 0);
    % for each synapse of input -> output:
    for i = 1:length(i_indices)
        i_idx = i_indices(i);
        o_idx = o_indices(i);
        weight = weights(o_idx, i_idx);
        % the synaptic effect at each firing times of the post
        effects = individual_effect(i_spikes, i_idx, o_spikes, o_idx);
        a_k(o_idx, i_idx) = sum(weight*effects);
    end
    
    
    [i_indices, o_indices] = find(self_weights ~= 0);
    % for each synapse of output -> output:
    for i = 1:length(i_indices)
        i_idx = i_indices(i);
        o_idx = o_indices(i);
        weight = self_weights(o_idx, i_idx);
        % the synaptic effect at each firing times of the post
        effects = individual_effect(o_spikes, i_idx, o_spikes, o_idx);
        a_k(o_idx, i_idx + n) = sum(weight*effects);
    end    
    A_k = sum(a_k, 2);
end