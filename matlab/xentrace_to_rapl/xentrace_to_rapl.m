clc
clear

energy_unit = 1/(2^16);     % RAPL specification for Intel i7-2600
cpu_frequency = 3.4*10^9;   % 3.4GHz for Intel i7-2600
resample_delta=0.1;           % Granularity of the resampling (seconds)




% Import data -------------------------------------------------------------
disp('- Import data');
rapl_struct = importdata('rapl.csv');
rapl_raw = rapl_struct.data;
pmc_struct = importdata('pmc.csv');
pmc_raw = pmc_struct.data;
wattsup_struct = importdata('wattsup-watts');

% Preprocessing -----------------------------------------------------------
disp('- Preprocessing');
% 1. zero-tsc values
zero_tsc_rapl_bitmask = rapl_raw(:,1)==0;            % bitmask: valid TSC values
rapl_raw(zero_tsc_rapl_bitmask,:)=[];                % matrix filtered
zero_tsc_pmc_bitmask = pmc_raw(:,1)==0;            % bitmask: valid TSC values
pmc_raw(zero_tsc_pmc_bitmask,:)=[];                % matrix filtered

% 2. Convert counters to the right unit
rapl_raw(:,[5 6 7 8])=energy_unit*rapl_raw(:,[5 6 7 8]);
rapl_raw(:,1)=rapl_raw(:,1)/cpu_frequency;
pmc_raw(:,1)=pmc_raw(:,1)/cpu_frequency;

% 3. Time incremental wrt the first value
base_of_times = min(rapl_raw(1,1), pmc_raw(1,1));
rapl_raw(:,1)=rapl_raw(:,1)-base_of_times;
pmc_raw(:,1)=pmc_raw(:,1)-base_of_times;

% 4. Oversample wattsup measurements - TODO: remove this and use time series (see later)
wattsup_raw = pmc_raw(:,[1 2]);
tests_length = length(wattsup_struct);
i=1;
while i <= tests_length
    bitmask = wattsup_raw(:,1)<i & wattsup_raw(:,1)>=i-1;
    wattsup_raw(bitmask, 2) = wattsup_struct(i);
    i=i+1;
end
wattsup_ts_old=timeseries(wattsup_raw(:,2), wattsup_raw(:,1), 'Name', 'wattsup');


% 5. Merge RAPL information gathered on all cores
rapl_pkg_all=rapl_raw(:,[1 5]); 
rapl_pkg_all(:,2)=rapl_pkg_all(:,2)-rapl_pkg_all(1,2);       % Incremental wrt the first value
rapl_pkg_ts=timeseries(rapl_pkg_all(:,2), rapl_pkg_all(:,1), 'Name', 'rapl_pkg');

rapl_pp0_all=rapl_raw(:,[1 5]); 
rapl_pp0_all(:,2)=rapl_pp0_all(:,2)-rapl_pp0_all(1,2);       % Incremental wrt the first value
rapl_pp0_ts=timeseries(rapl_pp0_all(:,2), rapl_pp0_all(:,1), 'Name', 'rapl_pp0');

rapl_pp1_all=rapl_raw(:,[1 5]); 
rapl_pp1_all(:,2)=rapl_pp1_all(:,2)-rapl_pp1_all(1,2);       % Incremental wrt the first value
rapl_pp1_ts=timeseries(rapl_pp1_all(:,2), rapl_pp1_all(:,1), 'Name', 'rapl_pp1');

rapl_dram_all=rapl_raw(:,[1 5]); 
rapl_dram_all(:,2)=rapl_dram_all(:,2)-rapl_dram_all(1,2);    % Incremental wrt the first value
rapl_dram_ts=timeseries(rapl_dram_all(:,2), rapl_dram_all(:,1), 'Name', 'rapl_dram');

% 6. Resample all the timeseries
tests_length = min(length(wattsup_struct),length(unique(floor(rapl_raw(:,1)))));
rapl_pkg_ts_resample=resample(rapl_pkg_ts, 1:resample_delta:tests_length);
wattsup_ts = timeseries(wattsup_struct,1:tests_length,'Name','wattsup');
wattsup_ts = setinterpmethod(wattsup_ts,'zoh');
wattsup_ts_resample=resample(wattsup_ts, 1:resample_delta:tests_length);        % TODO - add here: setinterpmethod(ts,'zoh')

% 7. Estimate power on the RAPL_PKG counter
dt=diff(rapl_pkg_ts_resample.time);
dE=diff(rapl_pkg_ts_resample.data);
power=dE./dt;
power_pkg_ts_resample=timeseries([power' power(end)]', rapl_pkg_ts_resample.time, 'Name','power_pkg');


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
    plot(delta_core(i).pkg(:,1), delta_core(i).pkg(:,2), '.');
    plot(delta_core(i).pp0(:,1),delta_core(i).pp0(:,2), '.');
    plot(delta_core(i).pp1(:,1),delta_core(i).pp1(:,2), '.');
    plot(delta_core(i).dram(:,1),delta_core(i).dram(:,2), '.');
    title(['xarc1-core ' int2str(delta_core(i).id)]);
    legend('pkg','pp0','pp1','dram');
    xlabel('Time (s)');
    ylabel('RAPL Counter');
    hold off;
    i = i+1;
end
%}




% Per-domain information --------------------------------------------------
% Split measures per unique domain
disp('- Split measures per unique domain');
unique_domain_ids = unique(pmc_raw(:,3))';    
i = 1;
for domain_id = unique_domain_ids
    domain_bitmask = pmc_raw(:,3)== domain_id;   % bitmask: domain_id data
    counter_domain(i).id = domain_id;            % Counter wrt the first

    counter_domain(i).pmc1 = pmc_raw(domain_bitmask,[1 5]);
    % PMC cumulated
    pmc_integral = cumsum(counter_domain(i).pmc1(:,2));
    pmc_ts = timeseries(pmc_integral,counter_domain(i).pmc1(:,1));
    pmc_ts_resample=resample(pmc_ts, 1:resample_delta:tests_length);
    pmc_resample = diff([pmc_ts_resample.data]);
    counter_domain(i).pmc1_ts=timeseries([pmc_resample' pmc_resample(end)]', pmc_ts_resample.time, 'Name','PMC1');
    
    % TODO - Add other pmcs here!
    counter_domain(i).pmc2 = pmc_raw(domain_bitmask,[1 6]);
    counter_domain(i).pmc3 = pmc_raw(domain_bitmask,[1 7]);
    counter_domain(i).pmc4 = pmc_raw(domain_bitmask,[1 8]);

    i = i+1;
end

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


% Plot Package Energy and Power (RAPL), with PMC1 for every domain
disp('- Plot Package Energy and Power (RAPL), with PMC1 for every domain');
figure;

subplot(2,1,1);
hold on;
grid on;
[hAx,hLine1,hLine2] = plotyy(rapl_pkg_ts_resample.time, rapl_pkg_ts_resample.data, power_pkg_ts_resample.time, power_pkg_ts_resample.data);
title('RAPL measurements');
legend('Package Energy (RAPL)','Package Power (RAPL)');
xlabel('Time (s)');
ylabel(hAx(1),'Energy (J)');    % left y-axis
ylabel(hAx(2),'Power (W)');     % right y-axis
grid on;
grid minor;
hold off;

subplot(2,1,2);               % The first subplot is for RAPL
hold on;
i = 1;
for domain_id = unique_domain_ids
 
    plot(counter_domain(i).pmc1_ts.time, counter_domain(i).pmc1_ts.data, '-');
    legendInfo{i} = ['dom-' int2str(counter_domain(i).id)];
    i = i+1;
end
title('PMC1 on different domains');
legend(legendInfo);
xlabel('Time (s)');
ylabel('PMC Counter');
grid on;
grid minor;
hold off;



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

title('PMC1 on different domains');
legend(legendInfo);
xlabel('Time (s)');
ylabel('PMC Counter');
hold off;

% --- RANDOM TESTS ---
% figure;
% plotyy(rapl_pkg_all(:,1),rapl_pkg_all(:,2),[counter_domain(1).pmc1(:,1)',counter_domain(2).pmc1(:,1)',counter_domain(3).pmc1(:,1)',counter_domain(4).pmc1(:,1)'],[counter_domain(1).pmc1(:,2)',counter_domain(2).pmc1(:,2)',counter_domain(3).pmc1(:,2)',counter_domain(4).pmc1(:,2)']);

%}

