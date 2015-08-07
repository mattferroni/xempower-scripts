function [pmc_ts_in_interval, pmc_cumulated_ts_in_interval] = cumulate_and_resample(time, data, index, resample_delta, tests_length)
    pmc_integral = cumsum(data);
    pmc_ts = timeseries(pmc_integral,time);
    pmc_cumulated_ts_in_interval = resample(pmc_ts, 1:resample_delta:tests_length);
    pmc_resample = diff([pmc_cumulated_ts_in_interval.data]);
    pmc_ts_in_interval = timeseries([pmc_resample' pmc_resample(end)]', pmc_cumulated_ts_in_interval.time, 'Name',['PMC' index]);
    pmc_ts_in_interval.data(isnan(pmc_ts_in_interval.data)) = 0 ;
end