%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A matlab script to simulate a simple snn and 
% plot the expected effect of each spike given
% the expected pre-synaptic frequency.
% 
%  j1 (fires with f = 0.2  with w = 1.2) --> k
%  j2 (fires with f = 0.4  with w = 0.6) --> k
%  j3 (fires with f = 0.6  with w = 0.4) --> k
%  j4 (fires with f = 0.8  with w = 0.3) --> k
%  Set the threshold of k to be ?
%  Plot the vmem of the neuron k
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\
effects = zeros(10, 1);
%for f = 1:10
% each input frequency

pts = 50000;
hs = zeros(pts, 1);
os = zeros(pts, 1);
tm = 32;
vth = 30;
hists = zeros(3*tm, 1);
    
for it = 1:pts
    
end_time = 1000; % Set the end simulation time
input_neuron = 10;
freq = rand(input_neuron, 1);
weights = 2*rand(input_neuron, 1) - 1;
%weights = rand(input_neuron, 1);
%freq = [0.8, 0.5, 0.8, 0.8, 0.4];% 0.4, 0.8, 0.8];
%weights = [1.0, -1, 0.5, 0.4, -0.3];%, 0.6, 0.4, 0.3, 1.2, 0.6, 0.4, 0.3];
spikes = rand(length(freq), end_time);

for i = 1:length(freq)
    spikes(i, :) = spikes(i,:) < freq(i);
end


% Begin the simulation:
[vmem_leak, xk_leak, h, o_spikes, hist, A_k, a_k] = SimulateSNN(spikes, freq, weights, end_time, 1, vth, tm);
hs(it) = h;
os(it) = o_spikes;

hists = hists + hist;

end

if(1)
% to test the hypothesis that the spike_o \propto \sum_i w_i*spike_i
figure
scatter(hs, os)
ylabel('# of output spikes')
xlabel('\sum w_{ij}* spike_j')

figure
plot(hists/sum(hists))
end

if(1)
% Compute the average slope:
inds = find(os == 0);
os(inds) = [];
hs(inds) = [];
figure
scatter(1:length(os), os./(hs/vth))




expected_spike_effect = sum(os./(hs/vth))/length(os);
s = sprintf('The expected_spike_effect: %f', expected_spike_effect);
disp(s);
effects(f) = expected_spike_effect;
sd = std(os./(hs/vth)/length(os));
s = sprintf('The variance: %f', sd);
disp(s);
end

