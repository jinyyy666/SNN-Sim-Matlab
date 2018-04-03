%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modify the output spikes of the neuron's cls is desired
%
% Input : 
%       o_spikes : m x end_time, binary matrix of output spike trains
%       cls : the desired output neuron index
%       max_f_count : max fire count of the output layer
%       end_time : time duration of a speech
%       
%       
% Output:
%       o_spikes_updated : m x end_time, with cls_th row is modified
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function o_spikes_updated = modify_spikes(o_spikes, cls, max_f_count, end_time)
    [~, end_time_o] = size(o_spikes);
    assert(end_time == end_time_o, 'Wrong end time:%f!', end_time);
    assert(sum(o_spikes(cls, :)) == 0, 'The neuron: %d has non zero spikes!', cls);
    o_spikes_updated = o_spikes;
    interval = floor(end_time/max(max_f_count, 1));
    for i = interval : interval: end_time
        o_spikes_updated(cls, i) = 1;
    end
end