% Import basic RAPL infos
pkg = importdata('pkg');
pp0 = importdata('pp0');

% Import and resaple wattsup
wattsup = importdata('wattsup');
wattsup_ms = interp(wattsup,10,1);
wattsup_ms = wattsup_ms(1:1167)

% Import PP1 or DRAM here
pp1 = importdata('pp1');

% Plot some graphs
figure
hold
plot(pp0(:,1),pp0(:,2))
plot(pp1(:,1),pp1(:,2))
plot(pkg(:,1),pkg(:,2))
plot(wattsup(:,1))
%plot(pp0(:,1), wattsup_ms(:,1))
xlabel('Time (s)')
ylabel('W')
legend('pp0','pp1','pkg','wattsup','wattsup_ms')


% Mean and variance
pkg_idle = pkg(:,2);
pkg_idle = [pkg_idle(1:100)' pkg_idle(570:670)' pkg_idle(1075:1167)']';
pkg_make = pkg(:,2);
pkg_make = pkg_make(101:569);
pkg_makej = pkg(:,2);
pkg_makej = pkg_makej(671:1074);
pkg_stats = [mean(pkg_idle) std(pkg_idle); mean(pkg_make) std(pkg_make); mean(pkg_makej) std(pkg_makej)]

pp0_idle = pp0(:,2);
pp0_idle = [pp0_idle(1:100)' pp0_idle(570:670)' pp0_idle(1075:1167)']';
pp0_make = pp0(:,2);
pp0_make = pp0_make(101:569);
pp0_makej = pp0(:,2);
pp0_makej = pp0_makej(671:1074);
pp0_stats = [mean(pp0_idle) std(pp0_idle); mean(pp0_make) std(pp0_make); mean(pp0_makej) std(pp0_makej)]

pp1_idle = pp1(:,2);
pp1_idle = [pp1_idle(1:100)' pp1_idle(570:670)' pp1_idle(1075:1167)']';
pp1_make = pp1(:,2);
pp1_make = pp1_make(101:569);
pp1_makej = pp1(:,2);
pp1_makej = pp1_makej(671:1074);
pp1_stats = [mean(pp1_idle) std(pp1_idle); mean(pp1_make) std(pp1_make); mean(pp1_makej) std(pp1_makej)]

wattsup_idle = [wattsup(1:9)' wattsup(57:66)' wattsup(108:120)']';
wattsup_make = wattsup(10:56);
wattsup_makej = wattsup(67:107);
wattsup_stats = [mean(wattsup_idle) std(wattsup_idle); mean(wattsup_make) std(wattsup_make); mean(wattsup_makej) std(wattsup_makej)]