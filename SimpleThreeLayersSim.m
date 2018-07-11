%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A matlab script to simulate the network:
% (input - reservoir - hidden_0 - output) based on the dumped response.
%
% Use to verify the simulator.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For the spoken English letter
cls = 26;
num_samples = 26;

weights_vec = load('weights_hidden_output.txt');
reservoir_size = 135;
hidden_size = 64;
output_size = 26;

weight_hidden_vec = weights_vec(1:reservoir_size*hidden_size);
weight_hidden_mat = reshape(weight_hidden_vec, [hidden_size, reservoir_size]);
weight_hidden_mat = weight_hidden_mat';

weight_output_vec = weights_vec(reservoir_size*hidden_size+1: length(weights_vec));
assert(length(weight_output_vec) == hidden_size*output_size);
weight_output_mat = reshape(weight_output_vec, [output_size, hidden_size]);
weight_output_mat = weight_output_mat';

tm = 64;
tep = 8;
vth_hidden = 20;
vth_output = 1;


%refer = [0 1 2 3 4 5 6 7 8 9]; % how samples organize in netlist_new.txt
refer = [0, 1, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 2, 20, 21, 22, 23, 24, 25, 3, 4, 5, 6, 7, 8, 9]; % for letter case
for times = 1:1 % only look at the first 26 samples
    
    maximum = 1000;
    
    for class = 1:1%1:cls % 26 subfigure in each figure (a - z)
        index = find(refer == (class -1));
        ind_speech = (times - 1)*cls + index - 1; % ind_speech : index of the *.dat
        
        % read the data
        filename_input = sprintf('spikes/Input_Response/input_spikes_%d.dat',ind_speech);
        filename_reservoir = sprintf('spikes/Reservoir_Response/reservoir_spikes_%d.dat',ind_speech);
        filename_hidden = sprintf('spikes/Hidden_Response_Supv/train/hidden_0_spikes_%d.dat', ind_speech);
        filename_readout = sprintf('spikes/Readout_Response_Supv/train/readout_spikes_%d.dat', ind_speech);

        data_i = load(filename_input);
        data_r = load(filename_reservoir);
        data_h = load(filename_hidden);
        data_o = load(filename_readout);

        indices_i = find(data_i == -1);
        indices_r = find(data_r == -1);
        indices_h = find(data_h(:, 1) == -1);
        indices_o = find(data_o(:, 1) == -1);
        
        num_i = length(indices_i) - 1;
        num_r = length(indices_r) - 1;
    
        input = zeros(num_i, maximum);
        assert(num_r == reservoir_size);
        
        reservoir = zeros(num_r,maximum);
        hidden = zeros(hidden_size, maximum);
        readout = zeros(output_size, maximum);

        for j = 1:num_i % read the speech samples
            data = data_i(indices_i(j)+1:indices_i(j+1)-1);
            if(data(1) == -99)
                continue;
            end
            for k = 1:length(data)
                input(j,data(k)) = 1;
            end
        end
%     
        for j = 1: num_r % read the response in the reservoir
            data = data_r(indices_r(j)+1:indices_r(j+1)-1);
            if(data(1) == -99)
                continue;
            end
            for k = 1:length(data)
                reservoir(j,data(k)) = 1;
            end
        end
        
        
        end_index = indices_h(end)-1; % read the hidden layer response
        if(end_index ~= 0)
            begin_index = indices_h(length(indices_h)-1)+1;
            data = data_h(begin_index : end_index,:);
            [row, ~] = size(data);
        
            for j = 1:row 
                hidden(data(j,1)+1, data(j,2)) = 1;
            end
        end
        
        end_index = indices_o(end)-1; % read the readout response
        if(end_index ~= 0)
            begin_index = indices_o(length(indices_o)-1)+1;
            data = data_o(begin_index : end_index,:);
            [row, ~] = size(data);
        
            for j = 1:row 
                readout(data(j,1)+1, data(j,2)) = 1;
            end
        end
        
        % Begin the simulation:
        % select several hidden neurons to test
        hidden_test_indices = [1, 2, 3, 5];
        for i = 1:length(hidden_test_indices)
            test_ind = hidden_test_indices(i);
            test_w = weight_hidden_mat(:, test_ind);
            [vmem, x_k, h, o_spikes, hist, A_k, a_k] = SimulateSNN(reservoir, test_w, 1000, 1, vth_hidden, tm);
            simulated_inds = find(vmem > vth_hidden);
            true_inds = find(hidden(test_ind, : )' == 1);
            if(~((isempty(simulated_inds) && isempty(true_inds)) || isequal(simulated_inds, true_inds)))
                disp('Test failed! The firing timings are not matched for the hidden layer!')
                assert(0);
            end
            
        end
        
        % select several output neurons to test
        [wave_r, wave_o, t_end] = ReadVmem;
        output_test_indices = [1, 3, 5, 7, 10];
        for i = 1:length(output_test_indices)
            test_ind = output_test_indices(i);
            test_w = weight_output_mat(:, test_ind);
            [vmem, x_k, h, o_spikes, hist, A_k, a_k] = SimulateSNN(hidden, test_w, 1000, 1, vth_output, tm);
            simulated_inds = find(vmem > vth_output);
            true_inds = find(readout(test_ind, : )' == 1);
            if(~((isempty(simulated_inds) && isempty(true_inds)) || isequal(simulated_inds, true_inds)))
                disp('Test failed! The firing timing are not matched for the output layer!')
                assert(0);
            end
            vmem_true = wave_o(test_ind, : )';
            diff = sum(abs(vmem(1:t_end - 1) - vmem_true(1:t_end - 1)));
            assert(diff < 1e-2);
            
        end
    end
end