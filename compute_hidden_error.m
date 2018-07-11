%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the back prop error of the hidden layers
% Only implement the counted based method now
%
% Input : 
%       errors_l_layer : m x 1, the error comming from the l_th layer
%
%       weights : m x n, m : number of neurons in l_th layer, 
%                        n : number of neurons in the (l-1)_th layer
%       
%       
% Output:
%       errors : n x 1, the error prop-backed down to (l-1)_th layer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errors = compute_hidden_error(errors_l_layer, weights)
    [m, ~] = size(weights);
    [n_neurons_l, ~] = size(errors_l_layer);
    assert(m == n_neurons_l, 'The row dim: %d of the errors_l_layer does not match with row dim: %d the weight matrix', m, n_neurons_l);
    errors = weights' * errors_l_layer;
end