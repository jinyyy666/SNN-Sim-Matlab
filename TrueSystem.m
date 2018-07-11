% A simple code to simulate how the true \sum_i exp(-(t - ti)/tc) behaves
% Conclusion: the original FE-based simulation method should be fine as
% long as the system time step << time constant
s = zeros(500,1); % simulate for t = 500
tc = 64;
for i = 1:500
    sum = 0;
    tmp = i;
    cnt = 0;
    while(tmp > 0)  % use a while loop to add additional exponentials
        sum = sum + exp(-(i - cnt*12)/tc); % assume that every 12 step the neuron fires a spike
        cnt = cnt + 1;
        tmp = tmp - 12;
    end
    s(i) = sum;
end
figure
plot(s)
    
    