%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the back prop error of the output layer
% Only implement the counted based method now
%
% Input : 
%       n_spikes : m x 1, the number of spikes of each output neuron
%       cls : the true label
%       
% Output:
%       errors : m x 1, the error of each output neuron
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errors = compute_output_error(n_spikes, cls)
    desired_level = 45;
    undesired_level = 15;
    margin = 5;
    
    [m, ~] = size(n_spikes);
    errors = zeros(m, 1);
    for i = 1 : m
        f_cnt = n_spikes(i);
        if(i == cls && (f_cnt < desired_level - margin || f_cnt > desired_level + margin))
            errors(i) = f_cnt - desired_level;
        end
        if(i ~= cls && (f_cnt < undesired_level - margin || f_cnt > undesired_level + margin))
            errors(i) = f_cnt - undesired_level;
        end
    end
end