%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A matlab script to simulate a simple snn and see
%  the dN / dW = ?
%  j1 (fires with f = 0.2  with w = 1.2) --> k
%  j2 (fires with f = 0.4  with w = 0.6) --> k
%  j3 (fires with f = 0.6  with w = 0.4) --> k
%  j4 (fires with f = 0.8  with w = 0.3) --> k
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tm = 32;
vth = 50;

end_time = 400; % Set the end simulation time
input_neuron = 10;
freq = 0.1*rand(input_neuron, 1);
weights = 2*rand(input_neuron, 1) - 1;
spikes = rand(length(freq), end_time);

for i = 1:length(freq)
    spikes(i, :) = spikes(i,:) < freq(i);
end

delta_interval = 0.01;
figure
for i = 1:input_neuron
    n_spikes = zeros(1/delta_interval+1, 1);
    cnt = 1;
    for delta = 0:delta_interval:1
        weights_test = weights;
        weights_test(i) = weights_test(i) + delta;
        [vmem_leak, xk_leak, h, o_spikes, hist, A_k, a_k] = SimulateSNN(spikes, weights_test, end_time, 1, vth, tm);
        if(delta == 0)
            s = sprintf('The expected slope for %d neuron: %f', i, a_k(end_time, i)/weights(i));
            disp(s)
        end
        n_spikes(cnt) = o_spikes;
        cnt = cnt + 1;
        
%         if(i == 1)
%             figure
%             sum(abs(weights_test - weights))
%             for j = 1:input_neuron
%                 subplot(2, 5, j)
%                 plot(a_k(: , j)/weights(j));
%             end
%             
%         end
    end
    subplot(2,5,i);
    s = sprintf('Weights = %f', weights(i));
    
    plot(0:delta_interval:1, n_spikes - n_spikes(1));
    xlabel('\Delta w')
    ylabel('Spike Count')
    title(s);
end

