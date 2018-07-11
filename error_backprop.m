%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform the error back-prop
%
% Input : 
%       i_spikes : n x end_time, binary matrix of input spike trains
%       o_spikes : m x end_time, binary matrix of output spike trains
%       error : m x 1, the error vector
%       
%       weights : m x n, m : number of neurons in input
%                        n : number of neurons in output
%       vth : the threshold voltage
%       tm : the time constant for vmem
%       ts : the time constant for synaptic response
%       
% Output:
%       weights_updated : m x n, updated weights 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [weights_updated] = error_backprop(i_spikes, o_spikes, errors, weights, vth, tm, ts)
    % check the sizes
    [m, n] = size(weights);
    [n_i, end_time_i] = size(i_spikes);
    assert(n_i == n, 'Expect to have %d rows of input spikes, but have: %d', n, n_i);
    [m_o, end_time_o] = size(o_spikes);
    assert(m_o == m, 'Expect to have %d rows of output spikes, but have: %d', m, m_o);
    assert(end_time_i == end_time_o);
    
    weights_updated = weights;
    lr = 0.0001;
    % a_k : m x n, the break-down accumulative synaptic of each input synapses
    [~, a_k] = acc_synaptic_response(i_spikes, o_spikes, weights, []);
    [m_ak, n_ak] = size(a_k);
    assert(m == m_ak && n == n_ak, 'Wrong size of the a_k !');
    % get rid of the weight because the a_k = weight * accumulative_effect
    weights_updated = weights_updated - lr * ((errors * ones(1, n)) .* a_k ./ weights);
    
end