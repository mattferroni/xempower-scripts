function plot_energy_and_power( energy_time, energy_data, power_time, power_data )
    hold on;
    grid on;
    [hAx,hLine1,hLine2] = plotyy( energy_time, energy_data, power_time, power_data );
    title('RAPL measurements');
    legend('Package Energy (RAPL)','Package Power (RAPL)');
    xlabel('Time (s)');
    ylabel(hAx(1),'Energy (J)');    % left y-axis
    ylabel(hAx(2),'Power (W)');     % right y-axis
    grid on;
    grid minor;
    hold off;
end




