%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function to test the function: individual_effect
% Try to see if the accumulative effect for the post neuron
% at the time when it fires should be close to vth
%
% Input: input : input spikes (n x end_time)
%        output: output spikes (m x end_time)
%        o_ind : post neuorn index of the synapse
%        weights : the weights from input -> output (m x n)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_individual_effect(input, output, o_ind, weights)

    [n, ~] = size(input);
    measure_times = find(output(o_ind, :) > 0);
    effects = zeros(length(measure_times), 1);
    for i = 1: n
        effects = effects + weights(o_ind, i) * individual_effect(input, i, output, o_ind);
    end
    effects
end