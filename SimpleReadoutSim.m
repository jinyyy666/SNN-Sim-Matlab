%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A matlab script to simulate the readout based 
% on the dumped response.
%
% To double check if the accumulative effect model 
% is correct or not.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For the spoken English letter
cls = 26;
num_samples = 26;

weights_vec = load('weights.txt');
weights_mat = reshape(weights_vec, [cls, length(weights_vec)/cls]);
weights_mat = weights_mat';
% test for the first readout neuron
weights = weights_mat(:, 1);

tm = 64;
tep = 8;

%refer = [0 1 2 3 4 5 6 7 8 9]; % how samples organize in netlist_new.txt
refer = [0, 1, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 2, 20, 21, 22, 23, 24, 25, 3, 4, 5, 6, 7, 8, 9]; % for letter case
for times = 1:1 % only look at the first 26 samples
    
    maximum = 1000;
    
    for class = 1:1%1:cls % 26 subfigure in each figure (a - z)
        index = find(refer == (class -1));
        ind_speech = (times - 1)*cls + index - 1; % ind_speech : index of the *.dat
        
        % read the data
        filename_input = sprintf('Input_Response/input_spikes_%d.dat',ind_speech);
        filename_reservoir = sprintf('Reservoir_Response/reservoir_spikes_%d.dat',ind_speech);
        filename_readout = sprintf('Readout_Response_Supv/train/readout_spikes_%d.dat', ind_speech);

        data_i = load(filename_input);
        data_r = load(filename_reservoir);
        data_o = load(filename_readout);

        indices_i = find(data_i == -1);
        indices_r = find(data_r == -1);
        indices_o = find(data_o(:, 1) == -1);
        num_i = length(indices_i) - 1;
        num_r = length(indices_r) - 1;
%     
    
        input = zeros(num_i, maximum);
        reservoir = zeros(num_r,maximum);
        readout = zeros(cls, maximum);

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
        
        end_index = indices_o(end)-1;
        if(end_index ~= 0)
            begin_index = indices_o(length(indices_o)-1)+1;
            data = data_o(begin_index : end_index,:);
            [row, ~] = size(data);
        
            for j = 1:row % read the readout response in the reservoir
                readout(data(j,1)+1, data(j,2)) = 1;
            end
        end
        
        A_k = zeros(length(find(readout(1,:) == 1)), 1);
        cnt = 1;
        last_i = 1;
        for i = 1:maximum
            if(readout(1, i) == 1)
                [effect_auc, ~] = compute_accumulative_effect(i, last_i, reservoir, weights, tm, tep);
                A_k(cnt) = effect_auc;
                cnt = cnt+1;
                last_i = i;
            end
        end
        A_k
    end
end