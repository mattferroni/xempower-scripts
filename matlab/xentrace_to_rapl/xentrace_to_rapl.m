clc
clear


% Import data -------------------------------------------------------------
disp('Importing...');
rapl_struct = importdata('rapl.csv');
rapl_raw = rapl_struct.data;
disp('- DONE');


% Preprocessing -----------------------------------------------------------
disp('Preprocessing...');
% 1. zero-tsc values
zero_tsc_bitmask = rapl_raw(:,1)==0;            % bitmask: valid TSC values
dropped_pass_1 = rapl_raw(zero_tsc_bitmask,:);  % lines dropped
rapl_raw(zero_tsc_bitmask,:)=[];                % matrix filtered

% 2. Convert counters to the right unit
energy_unit = 1/(2^16);
rapl_raw(:,[5 6 7 8])=energy_unit*rapl_raw(:,[5 6 7 8]);

% 3. Time incremental wrt the first value
rapl_raw(:,1)=rapl_raw(:,1)-rapl_raw(1,1);

% 3. Split measures per unique cores
unique_core_ids = unique(rapl_raw(:,2))';     % why I get core unique_core_ids =  0 8 9 10 32767 ???
i = 1;
for core_id = unique_core_ids
    core_bitmask = rapl_raw(:,2)== core_id;  % bitmask: core_id data
    counter_core(i).id = core_id;
    counter_core(i).pkg = rapl_raw(core_bitmask,[1 5]);  
    counter_core(i).pkg(:,2)=counter_core(i).pkg(:,2)-counter_core(i).pkg(1,2);       % Incremental wrt the first value
    counter_core(i).pp0 = rapl_raw(core_bitmask,[1 6]);
    counter_core(i).pp0(:,2)=counter_core(i).pp0(:,2)-counter_core(i).pp0(1,2);       % Incremental wrt the first value
    counter_core(i).pp1 = rapl_raw(core_bitmask,[1 7]);
    counter_core(i).pp1(:,2)=counter_core(i).pp1(:,2)-counter_core(i).pp1(1,2);       % Incremental wrt the first value
    counter_core(i).dram = rapl_raw(core_bitmask,[1 8]);
    counter_core(i).dram(:,2)=counter_core(i).dram(:,2)-counter_core(i).dram(1,2);    % Incremental wrt the first value
    i = i+1;
end
disp('- DONE');    


% Plot RAPL logs on different cores
figure;
i = 1;
for core_id = unique_core_ids
    subplot(2,2,i);
    hold on;
    plot(counter_core(i).pkg(:,1), counter_core(i).pkg(:,2), '.');
    plot(counter_core(i).pp0(:,1),counter_core(i).pp0(:,2), '.');
    plot(counter_core(i).pp1(:,1),counter_core(i).pp1(:,2), '.');
    plot(counter_core(i).dram(:,1),counter_core(i).dram(:,2), '.');
    title(['xarc1-core ' int2str(counter_core(i).id)]);
    legend('pkg','pp0','pp1','dram');
    xlabel('Time Stamp Counter (TSC) ');
    ylabel('RAPL Counter');
    hold off;
    i = i+1;
end

pause

% 4. Computing delta J per unique cores
unique_core_ids = unique(rapl_raw(:,2))';     % why I get core unique_core_ids =  0 8 9 10 32767 ???
i = 1;
for core_id = unique_core_ids
    core_bitmask = rapl_raw(:,2)== core_id;  % bitmask: core_id data
    delta_core(i).id = core_id;
    
    delta_core(i).pkg = rapl_raw(core_bitmask,[1 5]);
    shift = [delta_core(i).pkg(1,2) delta_core(i).pkg(:,2)']';
    shift = shift(1:end-1);
    delta_core(i).pkg(:,2)=delta_core(i).pkg(:,2)-shift;
        
    delta_core(i).pp0 = rapl_raw(core_bitmask,[1 6]);
    shift = [delta_core(i).pp0(1,2) delta_core(i).pp0(:,2)']';
    shift = shift(1:end-1);
    delta_core(i).pp0(:,2)=delta_core(i).pp0(:,2)-shift;
    
    delta_core(i).pp1 = rapl_raw(core_bitmask,[1 7]);
    shift = [delta_core(i).pp1(1,2) delta_core(i).pp1(:,2)']';
    shift = shift(1:end-1);
    delta_core(i).pp1(:,2)=delta_core(i).pp1(:,2)-shift;
    
    delta_core(i).dram = rapl_raw(core_bitmask,[1 8]);
    shift = [delta_core(i).dram(1,2) delta_core(i).dram(:,2)']';
    shift = shift(1:end-1);
    delta_core(i).dram(:,2)=delta_core(i).dram(:,2)-shift;
    
    i = i+1;
end 

% Plot RAPL logs on different cores
figure;
i = 1;
for core_id = unique_core_ids
    subplot(2,2,i);
    hold on;
    plot(delta_core(i).pkg(:,1), delta_core(i).pkg(:,2), '.');
    plot(delta_core(i).pp0(:,1),delta_core(i).pp0(:,2), '.');
    plot(delta_core(i).pp1(:,1),delta_core(i).pp1(:,2), '.');
    plot(delta_core(i).dram(:,1),delta_core(i).dram(:,2), '.');
    title(['xarc1-core ' int2str(delta_core(i).id)]);
    legend('pkg','pp0','pp1','dram');
    xlabel('Time Stamp Counter (TSC) ');
    ylabel('RAPL Counter');
    hold off;
    i = i+1;
end
