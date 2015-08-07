clc
clear

energy_unit = 1/(2^16);             % RAPL specification for Intel i7-2600
cpu_frequency = 3.4*10^9;           % 3.4GHz for Intel i7-2600
resample_delta = 1;                 % Granularity of the resampling (seconds)
pmc_to_plot = [1 4];                % PMCs to plot on the graphs
idle_domain = 32767;                % id of the idle domain
contribution_matrix_filter = 2;    % filter PMCs noise while plotting contributions

% Import data -------------------------------------------------------------
disp('- Import data');
rapl_struct = importdata('rapl.csv');
rapl_raw = rapl_struct.data;
pmc_struct = importdata('pmc.csv');
pmc_raw = pmc_struct.data;
wattsup_raw = importdata('wattsup-watts');


% Preprocessing -----------------------------------------------------------
disp('- Preprocessing');
% zero-tsc values
zero_tsc_rapl_bitmask = rapl_raw(:,1)==0;          % bitmask: valid TSC values
rapl_raw(zero_tsc_rapl_bitmask,:)=[];              % matrix filtered
zero_tsc_pmc_bitmask = pmc_raw(:,1)==0;            % bitmask: valid TSC values
pmc_raw(zero_tsc_pmc_bitmask,:)=[];                % matrix filtered

% remove idle domain
unique_domain_ids = unique(pmc_raw(:,3))';
unique_domain_ids(unique_domain_ids == idle_domain) = [];

% Convert counters to the right unit
rapl_raw(:,[5 6 7 8])=energy_unit*rapl_raw(:,[5 6 7 8]);
rapl_raw(:,1)=rapl_raw(:,1)/cpu_frequency;
pmc_raw(:,1)=pmc_raw(:,1)/cpu_frequency;

% Time incremental wrt the first value
base_of_times = min(rapl_raw(1,1), pmc_raw(1,1));
rapl_raw(:,1)=rapl_raw(:,1)-base_of_times;
pmc_raw(:,1)=pmc_raw(:,1)-base_of_times;


% Grouping and conditioning -----------------------------------------------------------
disp('- Grouping and conditioning');
% Merge RAPL information gathered on all cores
rapl_pkg_all=rapl_raw(:,[1 5]); 
rapl_pkg_all(:,2)=rapl_pkg_all(:,2)-rapl_pkg_all(1,2);       % Incremental wrt the first value
rapl_pkg_ts=timeseries(rapl_pkg_all(:,2), rapl_pkg_all(:,1), 'Name', 'rapl_pkg');
rapl_pp0_all=rapl_raw(:,[1 6]); 
rapl_pp0_all(:,2)=rapl_pp0_all(:,2)-rapl_pp0_all(1,2);       % Incremental wrt the first value
rapl_pp0_ts=timeseries(rapl_pp0_all(:,2), rapl_pp0_all(:,1), 'Name', 'rapl_pp0');
rapl_pp1_all=rapl_raw(:,[1 7]); 
rapl_pp1_all(:,2)=rapl_pp1_all(:,2)-rapl_pp1_all(1,2);       % Incremental wrt the first value
rapl_pp1_ts=timeseries(rapl_pp1_all(:,2), rapl_pp1_all(:,1), 'Name', 'rapl_pp1');
rapl_dram_all=rapl_raw(:,[1 8]); 
rapl_dram_all(:,2)=rapl_dram_all(:,2)-rapl_dram_all(1,2);    % Incremental wrt the first value
rapl_dram_ts=timeseries(rapl_dram_all(:,2), rapl_dram_all(:,1), 'Name', 'rapl_dram');

% Resample all the timeseries
tests_length = min(length(wattsup_raw),length(unique(floor(rapl_raw(:,1)))));
rapl_pkg_ts_resample=resample(rapl_pkg_ts, 1:resample_delta:tests_length);
rapl_pp0_ts_resample=resample(rapl_pp0_ts, 1:resample_delta:tests_length);
rapl_pp1_ts_resample=resample(rapl_pp1_ts, 1:resample_delta:tests_length);
rapl_dram_ts_resample=resample(rapl_dram_ts, 1:resample_delta:tests_length);

% Uniform Wattsup measurements
wattsup_ts = timeseries(wattsup_raw,1:tests_length,'Name','wattsup');
wattsup_ts = setinterpmethod(wattsup_ts,'zoh');
wattsup_ts_resample=resample(wattsup_ts, 1:resample_delta:tests_length);

% Estimate power on the RAPL_PKG counter and resample
dt=diff(rapl_pkg_ts_resample.time);     % differential time
dE=diff(rapl_pkg_ts_resample.data);     % differential data
power=dE./dt;
power_pkg_ts_resample=timeseries([power' power(end)]', rapl_pkg_ts_resample.time, 'Name','power_pkg');  % remember to add an element in the last position


% Per-core information filtering ------------------------------------------
% Split measures per unique cores
disp('- Split measures per unique cores');
unique_core_ids = unique(rapl_raw(:,2))';    
i = 1;
for core_id = unique_core_ids
    core_bitmask = rapl_raw(:,2)== core_id;   % bitmask: core_id data
    counter_core(i).id = core_id;             % Counter wrt the first

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


% Cumulate counters for all domain ----------------------------------------
disp('- Cumulate counters for all domain');
all_domain_bitmask = pmc_raw(:,3) ~= idle_domain; % bitmask: domain_id data

% TODO: use a loop on interesting PMCi here
global_pmc(1).raw = pmc_raw(all_domain_bitmask,[1 5]);
[global_pmc(1).pmc_ts, global_pmc(1).pmc_cumulated_ts] = cumulate_and_resample(global_pmc(1).raw(:,1), global_pmc(1).raw(:,2), 1, resample_delta, tests_length);

global_pmc(2).raw = pmc_raw(all_domain_bitmask,[1 6]);
[global_pmc(2).pmc_ts, global_pmc(2).pmc_cumulated_ts] = cumulate_and_resample(global_pmc(2).raw(:,1), global_pmc(2).raw(:,2), 1, resample_delta, tests_length);

global_pmc(3).raw = pmc_raw(all_domain_bitmask,[1 7]);
[global_pmc(3).pmc_ts, global_pmc(3).pmc_cumulated_ts] = cumulate_and_resample(global_pmc(3).raw(:,1), global_pmc(3).raw(:,2), 1, resample_delta, tests_length);

global_pmc(4).raw = pmc_raw(all_domain_bitmask,[1 8]);
[global_pmc(4).pmc_ts, global_pmc(4).pmc_cumulated_ts] = cumulate_and_resample(global_pmc(4).raw(:,1), global_pmc(4).raw(:,2), 1, resample_delta, tests_length);


% Per-domain information filtering ----------------------------------------
% Split measures per unique domain
disp('- Split measures per unique domain');
base=rapl_pkg_ts;
i = 1;
for domain_id = unique_domain_ids
    domain_bitmask = pmc_raw(:,3)== domain_id;   % bitmask: domain_id data
    counter_domain(i).id = domain_id;            % Counter wrt the first

    % TODO: use a loop on interesting PMCi here
    counter_domain(i).pmc(1).raw = pmc_raw(domain_bitmask,[1 5]);
    [counter_domain(i).pmc(1).pmc_ts, counter_domain(i).pmc(1).pmc_cumulated_ts] = cumulate_and_resample(counter_domain(i).pmc(1).raw(:,1), counter_domain(i).pmc(1).raw(:,2), 1, resample_delta, tests_length);
    counter_domain(i).pmc(1).pmc_percent_ts = counter_domain(i).pmc(1).pmc_ts./global_pmc(1).pmc_ts;
    
    counter_domain(i).pmc(2).raw = pmc_raw(domain_bitmask,[1 6]);
    [counter_domain(i).pmc(2).pmc_ts, counter_domain(i).pmc(2).pmc_cumulated_ts] = cumulate_and_resample(counter_domain(i).pmc(2).raw(:,1), counter_domain(i).pmc(2).raw(:,2), 1, resample_delta, tests_length);
    counter_domain(i).pmc(2).pmc_percent_ts = counter_domain(i).pmc(2).pmc_ts./global_pmc(2).pmc_ts;
    
    counter_domain(i).pmc(3).raw = pmc_raw(domain_bitmask,[1 7]);
    [counter_domain(i).pmc(3).pmc_ts, counter_domain(i).pmc(3).pmc_cumulated_ts] = cumulate_and_resample(counter_domain(i).pmc(3).raw(:,1), counter_domain(i).pmc(3).raw(:,2), 1, resample_delta, tests_length);
    counter_domain(i).pmc(3).pmc_percent_ts = counter_domain(i).pmc(3).pmc_ts./global_pmc(3).pmc_ts;
    
    counter_domain(i).pmc(4).raw = pmc_raw(domain_bitmask,[1 8]);
    [counter_domain(i).pmc(4).pmc_ts, counter_domain(i).pmc(4).pmc_cumulated_ts] = cumulate_and_resample(counter_domain(i).pmc(4).raw(:,1), counter_domain(i).pmc(4).raw(:,2), 1, resample_delta, tests_length);
    counter_domain(i).pmc(4).pmc_percent_ts = counter_domain(i).pmc(4).pmc_ts./global_pmc(4).pmc_ts;
    
    % TODO: here I'm considering only the first PMC to split the contribution
    counter_domain(i).power_pkg_ts = counter_domain(i).pmc(1).pmc_percent_ts.*power_pkg_ts_resample;
    
    i = i+1;
end

% Plot Package Energy and Power, measured with RAPL and with the Watts Up Power meter
disp('- Plot Package Energy and Power, measured with RAPL and with the Watts Up Power meter');
figure;
hold on;
[hAx,hLine1,hLine2] = plotyy(rapl_pkg_ts_resample.time, rapl_pkg_ts_resample.data, [power_pkg_ts_resample.time, wattsup_ts_resample.time], [power_pkg_ts_resample.data, wattsup_ts_resample.data]);
xlabel('Time (s)');
ylabel(hAx(1),'Energy (J)');    % left y-axis
ylabel(hAx(2),'Power (W)');     % right y-axis
legend('Package Energy (RAPL)','Package Power (RAPL)','Workstation Power (external)');
grid on;
grid minor;
hold off;

% Plot Package Energy and Power (RAPL), with PMCi for every domain
disp('- Plot Package Energy and Power (RAPL), with PMCi for every domain');
figure;
total_plots = 1+length(unique_domain_ids);

subplot(total_plots,1,1);
plot_energy_and_power(rapl_pkg_ts_resample.time, rapl_pkg_ts_resample.data, power_pkg_ts_resample.time, power_pkg_ts_resample.data);

i = 1;
for domain_id = unique_domain_ids
    subplot(total_plots,1,i+1);
    hold on;
    j=1;
    for current_pmc = pmc_to_plot
        plot(counter_domain(i).pmc(current_pmc).pmc_ts.time, counter_domain(i).pmc(current_pmc).pmc_ts.data, '-');
        legend_index=j;
        legendInfo{legend_index} = ['dom-' int2str(counter_domain(i).id) '-pmc' int2str(current_pmc)];
        j=j+1;
    end
    title(['PMCs of dom-' int2str(counter_domain(i).id)]);
    legend(legendInfo);
    xlabel('Time (s)');
    ylabel('PMC value');
    grid on;
    grid minor;
    hold off;
    i = i+1;
end


% Distribution of Package Energy consumption per domain, for every PMCi
disp('- Plot distribution of Package Energy consumption per domain, for every PMCi');
figure;
total_plots = 1+length(pmc_to_plot);

subplot(total_plots,1,1);
plot_energy_and_power(rapl_pkg_ts_resample.time, rapl_pkg_ts_resample.data, power_pkg_ts_resample.time, power_pkg_ts_resample.data);

i = 1;
for current_pmc = pmc_to_plot
    subplot(total_plots,1,i+1);
    hold on;

    j=1;
    contributions_matrix = [];
    for domain_id = unique_domain_ids
        contributions_matrix = [contributions_matrix, counter_domain(j).pmc(current_pmc).pmc_percent_ts.data];
        legend_index=j;
        legendInfo{legend_index} = ['dom-' int2str(counter_domain(j).id)];
        j=j+1;
    end
    
    contributions_matrix(sum(contributions_matrix,2)>contribution_matrix_filter,:) = [];
    area(contributions_matrix);
    title(['Reference: PMC' int2str(current_pmc)]);
    legend(legendInfo);
    xlabel('Time (s)');
    ylabel('Contribution to the total consumption (%)');
    grid on;
    grid minor;
    hold off;
    
    i = i+1;
end



% Distribution of Package Energy consumption per domain, for every PMCi
disp('- Plot distribution of Package Energy consumption per domain, for every PMCi');
figure;

subplot(2,1,1);
plot_energy_and_power(rapl_pkg_ts_resample.time, rapl_pkg_ts_resample.data, power_pkg_ts_resample.time, power_pkg_ts_resample.data);

subplot(2,1,2);
hold on;

j=1;
contributions_matrix = [];
for domain_id = unique_domain_ids
    contributions_matrix = [contributions_matrix, counter_domain(j).power_pkg_ts.data];
    legend_index=j;
    legendInfo{legend_index} = ['dom-' int2str(counter_domain(j).id)];
    j=j+1;
end
    
contributions_matrix(sum(contributions_matrix,2)>contribution_matrix_filter*max(power_pkg_ts_resample.data),:) = [];
area(contributions_matrix);
plot(power_pkg_ts_resample.time, power_pkg_ts_resample.data);
title('Reference: PMC');
legend(legendInfo);
xlabel('Time (s)');
ylabel('Contribution to the total consumption (%)');
grid on;
grid minor;
hold off;




%{   
% Plot PMC logs on different domains wrt RAPL
disp('- Plot PMC logs on different domains wrt RAPL');

figure;
subplot(2,1,1);

hold on;
[hAx,hLine1,hLine2] = plotyy(rapl_pkg_ts.time, rapl_pkg_ts.data, wattsup_ts.time, wattsup_ts.data);
xlabel('Time (s)');
ylabel(hAx(1),'RAPL counters');    % left y-axis
ylabel(hAx(2),'Watts Up (W)');     % right y-axis
hold off;

subplot(2,1,2);               % The first subplot is for RAPL
hold on;
i = 1;
for domain_id = unique_domain_ids
 
    plot(counter_domain(i).pmc1(:,1), counter_domain(i).pmc1(:,2), '-');
    % plot(counter_domain(i).pmc2(:,1),counter_domain(i).pmc2(:,2), '-');
    % plot(counter_domain(i).pmc3(:,1),counter_domain(i).pmc3(:,2), '-');
    % plot(counter_domain(i).pmc4(:,1),counter_domain(i).pmc4(:,2), '-');
    legendInfo{i} = ['dom-' int2str(counter_domain(i).id)];
    i = i+1;
end

legend(legendInfo);
xlabel('Time (s)');
ylabel('PMC Counter');
hold off;
%}

%{
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
    xlabel('Time (s)');
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
    legend('pkg','pp0','pp1','dram');
    xlabel('Time (s)');
    ylabel('RAPL Counter');
    hold off;
    i = i+1;
end
%}

%{
% Plot PMC logs on different domains
disp('- Plot PMC logs on different domains');
figure;
domains_count = length(unique_domain_ids);
i = 1;
for domain_id = unique_domain_ids
    subplot(domains_count,1,i);
    hold on;
    plot(counter_domain(i).pmc1(:,1), counter_domain(i).pmc1(:,2), '-');
    plot(counter_domain(i).pmc2(:,1),counter_domain(i).pmc2(:,2), '-');
    plot(counter_domain(i).pmc3(:,1),counter_domain(i).pmc3(:,2), '-');
    plot(counter_domain(i).pmc4(:,1),counter_domain(i).pmc4(:,2), '-');
    title(['xarc1-domain ' int2str(counter_domain(i).id)]);
    legend('pmc1','pmc2','pmc3','pmc4');
    xlabel('Time (s)');
    ylabel('PMC Counter');
    hold off;
    i = i+1;
end
%}
