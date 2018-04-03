%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A matlab script to simulate the network using the vectorized simulation
%
% Use to verify the simulator.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For the spoken English letter
cls = 26;
num_samples = 26;

%% Define the network size and params
% Network: input - reservoir - hidden - output
input_size = 78;
reservoir_size = 135;
hidden_size = 64;
output_size = 26;

tm = 64;
ts = 8;

%% load the weights:
input_weights = load_weights('i_weights_info.txt', input_size, reservoir_size);
reservoir_weights = load_weights('r_weights_info.txt', reservoir_size, reservoir_size);
hidden_weights = load_weights('h_weights_info.txt', reservoir_size, hidden_size);
output_weights = load_weights('o_weights_info.txt', hidden_size, output_size);

% transpose them for further use
input_weights = input_weights';
reservoir_weights = reservoir_weights';
hidden_weights = hidden_weights';
output_weights = output_weights';

disp('Successfully load the weights');

%% load the spike information and vmem from the file (training)

[wave_r, wave_h, wave_o, end_time] = ReadVmem('train');
[input, reservoir, hidden, output] = load_spikes_times(end_time, input_size, reservoir_size, hidden_size, output_size, 'train');

disp('Successfully load the spike times and the vmem');



%% conduct the simulation
% 1. input - reservoir
disp('Begin simulating the input -- reservoir layer')
vth = 20;
[vmem, reservoir_spikes, n_reservoir_spikes, A_k, h, a_k] = VectorizedSNN(input, input_weights, reservoir_weights, vth, tm, ts);
% match the vmem and output spike times
assert(sum(sum(abs(vmem - wave_r)))/(input_size*reservoir_size) < 1e-2, 'Reservoir vmem does not match!');
assert(sum(sum(abs(reservoir_spikes - reservoir))) < 1e-2, 'Reservoir spike timing does not match!');
disp('Simulation done! The result is correct!')

% 2. reservoir - hidden
disp('Begin simulating the reservoir -- hidden layer')
[vmem, hidden_spikes, n_hidden_spikes, A_k, h, a_k_rh] = VectorizedSNN(reservoir, hidden_weights, [], vth, tm, ts);
assert(sum(sum(abs(vmem - wave_h)))/(reservoir_size*hidden_size) < 1e-2, 'Hidden vmem does not match!');
assert(sum(sum(abs(hidden_spikes - hidden))) < 1e-2, 'Hidden spike timing does not match!');
disp('Simulation done! The result is correct!')


% 3. hidden - output
vth = 5;
disp('Begin simulating the hidden -- output layer')
[vmem, output_spikes, n_output_spikes, A_k, h, a_k_ho] = VectorizedSNN(hidden, output_weights, [], vth, tm, ts);
assert(sum(sum(abs(vmem - wave_o)))/(hidden_size*output_size) < 1e-2, 'Output vmem does not match!');
assert(sum(sum(abs(output_spikes - output))) < 1e-2, 'Output spike timing does not match!');
disp('Simulation done! The result is correct!')


%% conduct the error-bp training
% 1. output - hidden
disp('Begin the error backprop -- output layer')
output_error = compute_output_error(n_output_spikes, 1);
vth = 5;
% modify the output_spikes for the cls == 1 neuron if it does not fire a
% spike
if(n_output_spikes(1) == 0)
    output_spikes = modify_spikes(output_spikes, 1, max(n_output_spikes), end_time);
end

[output_weights_updated] = error_backprop(hidden_spikes, output_spikes, output_error, output_weights, vth, tm, ts); 
output_weights_u_true = load_weights('o_weights_info_trained.txt', hidden_size, output_size);
assert(sum(sum(abs(output_weights_u_true' - output_weights_updated))) < 1e-2, 'Output updated weights does not match!');
disp('Error back-prop output -> hidden done! The updated output weight is correct!');

% 2. hidden - reservoir
disp('Begin the error backprop -- hidden layer')
hidden_error = compute_hidden_error(output_error, output_weights);
vth = 20;
[hidden_weights_updated] = error_backprop(reservoir_spikes, hidden_spikes, hidden_error, hidden_weights, vth, tm, ts);
hidden_weights_u_true = load_weights('h_weights_info_trained.txt', reservoir_size, hidden_size);
assert(sum(sum(abs(hidden_weights_u_true' - hidden_weights_updated))) < 1e-2, 'Hidden updated weights does not match!');
disp('Error back-prop hidden -> reservoir done! The updated hidden weight is correct!');

%% verify the test phrase:
[wave_r, wave_h_new, wave_o_new, end_time] = ReadVmem('test');
[input, reservoir, hidden_new, output_new] = load_spikes_times(end_time, input_size, reservoir_size, hidden_size, output_size, 'test');

% 1. reservoir - hidden
vth = 20;
disp('Begin test phrase of the reservoir -- hidden layer')
[vmem, hidden_spikes_new, n_hidden_spikes_new, A_k, h, a_k_rh_new] = VectorizedSNN(reservoir, hidden_weights_updated, [], vth, tm, ts);
assert(sum(sum(abs(vmem - wave_h_new)))/(reservoir_size*hidden_size) < 1e-2, 'Hidden vmem does not match!');
assert(sum(sum(abs(hidden_spikes_new - hidden_new))) < 1e-2, 'Hidden spike timing does not match!');
disp('Test phrase done! The result reservoir -> hidden is correct!')


% 2. hidden - output
vth = 5;
disp('Begin simulating the hidden -- output layer')
[vmem, output_spikes_new, n_output_spikes_new, A_k, h, a_k_ho_new] = VectorizedSNN(hidden_spikes_new, output_weights_updated, [], vth, tm, ts);
assert(sum(sum(abs(vmem - wave_o_new)))/(hidden_size*output_size) < 1e-2, 'Output vmem does not match!');
assert(sum(sum(abs(output_spikes_new - output_new))) < 1e-2, 'Output spike timing does not match!');
disp('Test phrase done! The result of hidden -> output is correct!')
