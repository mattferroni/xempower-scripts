clc
clear

% Import basic RAPL infos
pkg_dom0_xarc0 = importdata('pkg_dom0_xarc0');
pp0_dom0_xarc0 = importdata('pp0_dom0_xarc0');

% Import and resaple wattsup_dom0_xarc0
wattsup_dom0_xarc0 = importdata('wattsup_dom0_xarc0');
wattsup_dom0_xarc0_ms = interp(wattsup_dom0_xarc0,10);
wattsup_dom0_xarc0_ms = wattsup_dom0_xarc0_ms(1:1167);

% Import PP1 or DRAM here
dram_dom0_xarc0 = importdata('dram_dom0_xarc0');

% Plot some graphs
figure
hold on
plot(pp0_dom0_xarc0(:,1),pp0_dom0_xarc0(:,2))
plot(dram_dom0_xarc0(:,1),dram_dom0_xarc0(:,2))
plot(pkg_dom0_xarc0(:,1),pkg_dom0_xarc0(:,2))
plot(wattsup_dom0_xarc0(:,1))
%plot(pp0_dom0_xarc0(:,1), wattsup_dom0_xarc0_ms(:,1))
title('xarc0-dom0 full test')
xlabel('Time (s)')
ylabel('W')
legend('pp0 dom0','dram dom0','pkg dom0','wattsup dom0','wattsup dom0 ms')
hold off

pause

% Import basic RAPL infos
pkg_dom0 = importdata('pkg_dom0');
pp0_dom0 = importdata('pp0_dom0');

% Import and resaple wattsup_dom0
wattsup_dom0 = importdata('wattsup_dom0');
wattsup_dom0_ms = interp(wattsup_dom0,10);
wattsup_dom0_ms = wattsup_dom0_ms(1:1167);

% Import PP1 or DRAM here
pp1_dom0 = importdata('pp1_dom0');

% Plot some graphs
figure
hold on
plot(pp0_dom0(:,1),pp0_dom0(:,2))
plot(pp1_dom0(:,1),pp1_dom0(:,2))
plot(pkg_dom0(:,1),pkg_dom0(:,2))
plot(wattsup_dom0(:,1))
%plot(pp0_dom0(:,1), wattsup_dom0_ms(:,1))
title('xarc1-dom0 full test')
xlabel('Time (s)')
ylabel('W')
legend('pp0 dom0','pp1 dom0','pkg dom0','wattsup dom0','wattsup dom0 ms')
hold off


% Mean and variance
pkg_dom0_idle = pkg_dom0(:,2);
pkg_dom0_idle = [pkg_dom0_idle(1:100)' pkg_dom0_idle(570:670)' pkg_dom0_idle(1075:1167)']';
pkg_dom0_make = pkg_dom0(:,2);
pkg_dom0_make = pkg_dom0_make(101:569);
pkg_dom0_makej = pkg_dom0(:,2);
pkg_dom0_makej = pkg_dom0_makej(671:1074);
pkg_dom0_stats = [mean(pkg_dom0_idle) std(pkg_dom0_idle); mean(pkg_dom0_make) std(pkg_dom0_make); mean(pkg_dom0_makej) std(pkg_dom0_makej)];

pp0_dom0_idle = pp0_dom0(:,2);
pp0_dom0_idle = [pp0_dom0_idle(1:100)' pp0_dom0_idle(570:670)' pp0_dom0_idle(1075:1167)']';
pp0_dom0_make = pp0_dom0(:,2);
pp0_dom0_make = pp0_dom0_make(101:569);
pp0_dom0_makej = pp0_dom0(:,2);
pp0_dom0_makej = pp0_dom0_makej(671:1074);
pp0_dom0_stats = [mean(pp0_dom0_idle) std(pp0_dom0_idle); mean(pp0_dom0_make) std(pp0_dom0_make); mean(pp0_dom0_makej) std(pp0_dom0_makej)];

pp1_dom0_idle = pp1_dom0(:,2);
pp1_dom0_idle = [pp1_dom0_idle(1:100)' pp1_dom0_idle(570:670)' pp1_dom0_idle(1075:1167)']';
pp1_dom0_make = pp1_dom0(:,2);
pp1_dom0_make = pp1_dom0_make(101:569);
pp1_dom0_makej = pp1_dom0(:,2);
pp1_dom0_makej = pp1_dom0_makej(671:1074);
pp1_dom0_stats = [mean(pp1_dom0_idle) std(pp1_dom0_idle); mean(pp1_dom0_make) std(pp1_dom0_make); mean(pp1_dom0_makej) std(pp1_dom0_makej)];

wattsup_dom0_idle = [wattsup_dom0(1:9)' wattsup_dom0(57:66)' wattsup_dom0(108:120)']';
wattsup_dom0_make = wattsup_dom0(10:56);
wattsup_dom0_makej = wattsup_dom0(67:107);
wattsup_dom0_stats = [mean(wattsup_dom0_idle) std(wattsup_dom0_idle); mean(wattsup_dom0_make) std(wattsup_dom0_make); mean(wattsup_dom0_makej) std(wattsup_dom0_makej)];

pause

% Import basic RAPL infos
pkg_bare = importdata('pkg_bare');
pp0_bare = importdata('pp0_bare');

% Import and resaple wattsup_bare
wattsup_bare = importdata('wattsup_bare');
wattsup_bare_ms = interp(wattsup_bare,10);
wattsup_bare_ms = wattsup_bare_ms(1:1189);

% Import PP1 or DRAM here
pp1_bare = importdata('pp1_bare');


% Plot some graphs
figure
hold on
title('xarc1-bare full test')
plot(pp0_bare(:,1),pp0_bare(:,2))
plot(pp1_bare(:,1),pp1_bare(:,2))
plot(pkg_bare(:,1),pkg_bare(:,2))
plot(wattsup_bare(:,1))
%plot(pp0_bare(:,1), wattsup_bare_ms(:,1))
xlabel('Time (s)')
ylabel('W')
legend('pp0 bare','pp1 bare','pkg bare','wattsup bare','wattsup bare ms')
hold off


% Mean and variance
pkg_bare_idle = pkg_bare(:,2);
pkg_bare_idle = [pkg_bare_idle(1:100)' pkg_bare_idle(430:530)' pkg_bare_idle(640:1153)']';
pkg_bare_make = pkg_bare(:,2);
pkg_bare_make = pkg_bare_make(101:429);
pkg_bare_makej = pkg_bare(:,2);
pkg_bare_makej = pkg_bare_makej(531:640);
pkg_bare_stats = [mean(pkg_bare_idle) std(pkg_bare_idle); mean(pkg_bare_make) std(pkg_bare_make); mean(pkg_bare_makej) std(pkg_bare_makej)];

pp0_bare_idle = pp0_bare(:,2);
pp0_bare_idle = [pp0_bare_idle(1:100)' pp0_bare_idle(430:530)' pp0_bare_idle(640:1153)']';
pp0_bare_make = pp0_bare(:,2);
pp0_bare_make = pp0_bare_make(101:429);
pp0_bare_makej = pp0_bare(:,2);
pp0_bare_makej = pp0_bare_makej(531:640);
pp0_bare_stats = [mean(pp0_bare_idle) std(pp0_bare_idle); mean(pp0_bare_make) std(pp0_bare_make); mean(pp0_bare_makej) std(pp0_bare_makej)];

pp1_bare_idle = pp1_bare(:,2);
pp1_bare_idle = [pp1_bare_idle(1:100)' pp1_bare_idle(430:530)' pp1_bare_idle(640:1153)']';
pp1_bare_make = pp1_bare(:,2);
pp1_bare_make = pp1_bare_make(101:429);
pp1_bare_makej = pp1_bare(:,2);
pp1_bare_makej = pp1_bare_makej(531:640);
pp1_bare_stats = [mean(pp1_bare_idle) std(pp1_bare_idle); mean(pp1_bare_make) std(pp1_bare_make); mean(pp1_bare_makej) std(pp1_bare_makej)];

wattsup_bare_idle = [wattsup_bare(1:9)' wattsup_bare(44:53)' wattsup_bare(64:120)']';
wattsup_bare_make = wattsup_bare(10:43);
wattsup_bare_makej = wattsup_bare(54:63);
wattsup_bare_stats = [mean(wattsup_bare_idle) std(wattsup_bare_idle); mean(wattsup_bare_make) std(wattsup_bare_make); mean(wattsup_bare_makej) std(wattsup_bare_makej)];

pause

% Plotting differences
bare_offset = wattsup_bare_ms - pkg_bare(:,2);
dom0_offset = wattsup_dom0_ms - pkg_dom0(:,2);
figure
hold on
plot(pkg_bare(:,1),bare_offset)
plot(pkg_dom0(:,1),dom0_offset)
title('Wattsup-Package offset')
xlabel('Time (s)')
ylabel('W')
legend('bare offset','dom0 offset')
hold off

pause

% Mean comparison
compare_stats_idle = [pkg_dom0_stats(1,1) pkg_bare_stats(1,1); pp0_dom0_stats(1,1) pp0_bare_stats(1,1); pp1_dom0_stats(1,1) pp1_bare_stats(1,1); wattsup_dom0_stats(1,1) wattsup_bare_stats(1,1);]
figure
hold on
bar(compare_stats_idle);
title('Idle mean consumption comparison')
legend('bare mean consumption','dom0 mean consumption');
ylabel('W')
xlabel('pkg / pp0 / pp1 / wattsup');
hold off

pause

compare_stats_make = [pkg_dom0_stats(2,1) pkg_bare_stats(2,1); pp0_dom0_stats(2,1) pp0_bare_stats(2,1); pp1_dom0_stats(2,1) pp1_bare_stats(2,1); wattsup_dom0_stats(2,1) wattsup_bare_stats(2,1);]
figure
hold on
bar(compare_stats_make);
title('Make mean consumption comparison')
legend('bare mean consumption','dom0 mean consumption');
ylabel('W')
xlabel('pkg / pp0 / pp1 / wattsup');
hold off

pause

compare_stats_makej = [pkg_dom0_stats(3,1) pkg_bare_stats(3,1); pp0_dom0_stats(3,1) pp0_bare_stats(3,1); pp1_dom0_stats(3,1) pp1_bare_stats(3,1); wattsup_dom0_stats(3,1) wattsup_bare_stats(3,1);]
figure
hold on
bar(compare_stats_makej);
title('Make -j4 mean consumption comparison')
legend('bare mean consumption','dom0 mean consumption');
ylabel('W')
xlabel('pkg / pp0 / pp1 / wattsup');
hold off

pause