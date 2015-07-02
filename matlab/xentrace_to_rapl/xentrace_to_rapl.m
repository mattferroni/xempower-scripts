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

% 3. Split contributions per unique domains
unique_domain_ids = unique(rapl_raw(:,3))';     % why I get domain unique_domain_ids =  0 8 9 10 32767 ???
i = 1;
for domain_id = unique_domain_ids
    domain_bitmask = rapl_raw(:,3)== domain_id;  % bitmask: domain_id data
    domain(i).id = domain_id;
    domain(i).pkg = rapl_raw(domain_bitmask,[1 5]);     
    domain(i).pkg(:,2)=domain(i).pkg(:,2)-domain(i).pkg(1,2);       % Incremental wrt the first value
    domain(i).pp0 = rapl_raw(domain_bitmask,[1 6]);
    domain(i).pp0(:,2)=domain(i).pp0(:,2)-domain(i).pp0(1,2);       % Incremental wrt the first value
    domain(i).pp1 = rapl_raw(domain_bitmask,[1 7]);
    domain(i).pp1(:,2)=domain(i).pp1(:,2)-domain(i).pp1(1,2);       % Incremental wrt the first value
    domain(i).dram = rapl_raw(domain_bitmask,[1 8]);
    domain(i).dram(:,2)=domain(i).dram(:,2)-domain(i).dram(1,2);    % Incremental wrt the first value
    i = i+1;
end
disp('- DONE');    


% Plot graphs
i = 1;
for domain_id = unique_domain_ids
    figure
    hold on
    plot(domain(i).pkg(:,1),domain(i).pkg(:,2))
    plot(domain(i).pp0(:,1),domain(i).pp0(:,2))
    plot(domain(i).pp1(:,1),domain(i).pp1(:,2))
    plot(domain(i).dram(:,1),domain(i).dram(:,2))
    title(['xarc1-domain ' int2str(domain(i).id)])
    xlabel('Time (s)')
    ylabel('Counter')
    legend('pkg','pp0','pp1','dram')
    hold off
    
    i = i+1;
end

