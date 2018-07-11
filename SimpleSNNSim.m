%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A matlab script to simulate a simple snn:
%  j1 (fires with f = 0.2  with w = 1.2) --> k
%  j2 (fires with f = 0.4  with w = 0.6) --> k
%  j3 (fires with f = 0.6  with w = 0.4) --> k
%  j4 (fires with f = 0.8  with w = 0.3) --> k
%  Set the threshold of k to be ?
%  Plot the vmem of the neuron k
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pts = 500;
hs = zeros(pts, 1);
os = zeros(pts, 1);

tm = 64;
vth = 20;
hists = zeros(3*tm, 1);

end_time = 1000; % Set the end simulation time
input_neuron = 10;

a_ks = zeros(pts, input_neuron);
total_input_spikes = zeros(pts, input_neuron);

for it = 1:pts
    

freq = rand(input_neuron, 1)*0.4;
weights = 2*rand(input_neuron, 1) - 1;
%weights = rand(input_neuron, 1);
%freq = [0.8, 0.5, 0.8, 0.8, 0.4];% 0.4, 0.8, 0.8];
%weights = [1.0, -1, 0.5, 0.4, -0.3];%, 0.6, 0.4, 0.3, 1.2, 0.6, 0.4, 0.3];
spikes = rand(length(freq), end_time);

for i = 1:length(freq)
    spikes(i, :) = spikes(i,:) < freq(i);
end


% Begin the simulation:
[vmem_leak, xk_leak, h, o_spikes, hist, A_k, a_k] = SimulateSNN(spikes, weights, end_time, 1, vth, tm);
hs(it) = h;
os(it) = o_spikes;

a_ks(it, :) = a_k(end, :)./weights';
total_input_spikes(it, :) = sum(spikes, 2)';

hists = hists + hist;


end
% Compute the derivate of the accumulative effect w.r.t the spike counts
figure
for it = 1:pts
    scatter(total_input_spikes(it, :), a_ks(it, :));
    hold on;
end
xlabel('o^{k-1}_i');
ylabel('e^k_{i | j}');

figure
max_o = max(os);
interval = floor((max_o - 1)/10 + 1);
for fig = 1:10
    l = (fig-1)* interval;
    h = fig *interval;
    inds = find( os > l & os <= h);
    subplot(2,5, fig);
    [r, c] = size(total_input_spikes(inds, :));
    scatter(reshape(total_input_spikes(inds, :), [r*c, 1]), reshape(a_ks(inds, :), [r*c, 1]));
    xlabel('o^{k-1}_i');
    ylabel('e^k_{i | j}');
    str = sprintf('o^{k}_j > %d && o^{k}_j <= %d', l, h);
    title(str);
    axis([0, 450, 0, 300])
end

% figure
% scatter(hs, os)
% ylabel('# of output spikes')
% xlabel('\sum w_{ij}* spike_j')
% 
% % Compute the average slope:
% inds = find(os == 0);
% os(inds) = [];
% hs(inds) = [];
% figure
% scatter(1:length(os), os./(hs/vth))
% 
% % figure
% % plot(hists/sum(hists))
% 
% expected_spike_effect = sum(os./(hs/vth))/length(os);
% s = sprintf('The expected_spike_effect: %f', expected_spike_effect);
% disp(s);
% sd = std(os./(hs/vth)/length(os));
% s = sprintf('The variance: %f', sd);
% disp(s);



