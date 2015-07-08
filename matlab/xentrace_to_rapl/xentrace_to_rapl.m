clc
clear


% Import data -------------------------------------------------------------
disp('- Import data');
rapl_struct = importdata('rapl.csv');
rapl_raw = rapl_struct.data;
pmc_struct = importdata('pmc.csv');
pmc_raw = pmc_struct.data;


% Preprocessing -----------------------------------------------------------
disp('- Preprocessing');
% 1. zero-tsc values
zero_tsc_rapl_bitmask = rapl_raw(:,1)==0;            % bitmask: valid TSC values
dropped_rapl_1 = rapl_raw(zero_tsc_rapl_bitmask,:);  % lines dropped
rapl_raw(zero_tsc_rapl_bitmask,:)=[];                % matrix filtered
zero_tsc_pmc_bitmask = pmc_raw(:,1)==0;            % bitmask: valid TSC values
dropped_pmc_1 = pmc_raw(zero_tsc_pmc_bitmask,:);   % lines dropped
pmc_raw(zero_tsc_pmc_bitmask,:)=[];                % matrix filtered

% 2. Convert counters to the right unit
energy_unit = 1/(2^16);
rapl_raw(:,[5 6 7 8])=energy_unit*rapl_raw(:,[5 6 7 8]);

% 3. Time incremental wrt the first value
base_of_times = min(rapl_raw(1,1), pmc_raw(1,1));
rapl_raw(:,1)=rapl_raw(:,1)-base_of_times;
pmc_raw(:,1)=pmc_raw(:,1)-base_of_times;


% Per-core information ----------------------------------------------------
% Split measures per unique cores
disp('- Split measures per unique cores');
unique_core_ids = unique(rapl_raw(:,2))';    
i = 1;
for core_id = unique_core_ids
    core_bitmask = rapl_raw(:,2)== core_id;   % bitmask: core_id data
    counter_core(i).id = core_id;             % Counter wrt the first
    delta_core(i).id = core_id;               % Counter wrt the previous

    counter_core(i).pkg = rapl_raw(core_bitmask,[1 5]);  
    counter_core(i).pkg(:,2)=counter_core(i).pkg(:,2)-counter_core(i).pkg(1,2);       % Incremental wrt the first value
    delta_core(i).pkg = rapl_raw(core_bitmask,[1 5]);
    shift = [delta_core(i).pkg(1,2) delta_core(i).pkg(:,2)']';
    shift = shift(1:end-1);
    delta_core(i).pkg(:,2)=delta_core(i).pkg(:,2)-shift;
        
    counter_core(i).pp0 = rapl_raw(core_bitmask,[1 6]);
    counter_core(i).pp0(:,2)=counter_core(i).pp0(:,2)-counter_core(i).pp0(1,2);       % Incremental wrt the first value
    delta_core(i).pp0 = rapl_raw(core_bitmask,[1 6]);
    shift = [delta_core(i).pp0(1,2) delta_core(i).pp0(:,2)']';
    shift = shift(1:end-1);
    delta_core(i).pp0(:,2)=delta_core(i).pp0(:,2)-shift;
    
    counter_core(i).pp1 = rapl_raw(core_bitmask,[1 7]);
    counter_core(i).pp1(:,2)=counter_core(i).pp1(:,2)-counter_core(i).pp1(1,2);       % Incremental wrt the first value
    delta_core(i).pp1 = rapl_raw(core_bitmask,[1 7]);
    shift = [delta_core(i).pp1(1,2) delta_core(i).pp1(:,2)']';
    shift = shift(1:end-1);
    delta_core(i).pp1(:,2)=delta_core(i).pp1(:,2)-shift;
    
    counter_core(i).dram = rapl_raw(core_bitmask,[1 8]);
    counter_core(i).dram(:,2)=counter_core(i).dram(:,2)-counter_core(i).dram(1,2);    % Incremental wrt the first value
    delta_core(i).dram = rapl_raw(core_bitmask,[1 8]);
    shift = [delta_core(i).dram(1,2) delta_core(i).dram(:,2)']';
    shift = shift(1:end-1);
    delta_core(i).dram(:,2)=delta_core(i).dram(:,2)-shift;

    i = i+1;
end


% Plot RAPL logs on different cores
disp('- Plot RAPL logs on different cores');
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

% Plot RAPL deltas on different cores
disp('- Plot RAPL deltas on different cores');
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


% Per-domain information --------------------------------------------------
% Split measures per unique domain
disp('- Split measures per unique domain');
unique_domain_ids = unique(pmc_raw(:,3))';    
i = 1;
for domain_id = unique_domain_ids
    domain_bitmask = pmc_raw(:,3)== domain_id;   % bitmask: domain_id data
    counter_domain(i).id = domain_id;             % Counter wrt the first

    counter_domain(i).pmc1 = pmc_raw(domain_bitmask,[1 5]);  
    counter_domain(i).pmc2 = pmc_raw(domain_bitmask,[1 6]);
    counter_domain(i).pmc3 = pmc_raw(domain_bitmask,[1 7]);
    counter_domain(i).pmc4 = pmc_raw(domain_bitmask,[1 8]);

    i = i+1;
end

% Plot PMC logs on different domains
disp('- Plot PMC logs on different domains');
figure;
i = 1;
for domain_id = unique_domain_ids
    subplot(2,2,i);
    hold on;
    plot(counter_domain(i).pmc1(:,1), counter_domain(i).pmc1(:,2), '-');
    plot(counter_domain(i).pmc2(:,1),counter_domain(i).pmc2(:,2), '-');
    plot(counter_domain(i).pmc3(:,1),counter_domain(i).pmc3(:,2), '-');
    plot(counter_domain(i).pmc4(:,1),counter_domain(i).pmc4(:,2), '-');
    title(['xarc1-domain ' int2str(counter_domain(i).id)]);
    legend('pmc1','pmc2','pmc3','pmc4');
    xlabel('Time Stamp Counter (TSC) ');
    ylabel('PMC Counter');
    hold off;
    i = i+1;
end


% Plot PMC logs on different domains wrt RAPL
disp('- Plot PMC logs on different domains wrt RAPL');
rapl_pkg_all=rapl_raw(:,[1 5]); 
rapl_pkg_all(:,2)=rapl_pkg_all(:,2)-rapl_pkg_all(1,2);       % Incremental wrt the first value
rapl_pp0_all=rapl_raw(:,[1 5]); 
rapl_pp0_all(:,2)=rapl_pp0_all(:,2)-rapl_pp0_all(1,2);       % Incremental wrt the first value
rapl_pp1_all=rapl_raw(:,[1 5]); 
rapl_pp1_all(:,2)=rapl_pp1_all(:,2)-rapl_pp1_all(1,2);       % Incremental wrt the first value
rapl_dram_all=rapl_raw(:,[1 5]); 
rapl_dram_all(:,2)=rapl_dram_all(:,2)-rapl_dram_all(1,2);    % Incremental wrt the first value

figure;
domains_count = length(unique_domain_ids);
subplot(domains_count+1,1,1);

hold on;
plot(rapl_pkg_all(:,1), rapl_pkg_all(:,2), '.');
legend('pkg');
xlabel('Time Stamp Counter (TSC) ');
ylabel('Counters');
hold off;

i = 1;
for domain_id = unique_domain_ids
    subplot(domains_count+1,1,i+1);               % The first subplot is for RAPL
    
    hold on;
    plot(counter_domain(i).pmc1(:,1), counter_domain(i).pmc1(:,2), '-');
    % plot(counter_domain(i).pmc2(:,1),counter_domain(i).pmc2(:,2), '-');
    % plot(counter_domain(i).pmc3(:,1),counter_domain(i).pmc3(:,2), '-');
    % plot(counter_domain(i).pmc4(:,1),counter_domain(i).pmc4(:,2), '-');
    
    title(['xarc1-domain ' int2str(counter_domain(i).id)]);
    legend('pmc1');                % legend('pmc1','pmc2','pmc3','pmc4');
    xlabel('Time Stamp Counter (TSC) ');
    ylabel('PMC Counter');
    hold off;
    
    i = i+1;
end



