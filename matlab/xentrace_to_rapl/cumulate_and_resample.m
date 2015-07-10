function pmc_ts_cumulated = cumulate_and_resample(time, data, index, resample_delta, tests_length)
    pmc_integral = cumsum(data);
    pmc_ts = timeseries(pmc_integral,time);
    pmc_ts_resample=resample(pmc_ts, 1:resample_delta:tests_length);
    pmc_resample = diff([pmc_ts_resample.data]);
    pmc_ts_cumulated = timeseries([pmc_resample' pmc_resample(end)]', pmc_ts_resample.time, 'Name',['PMC' index]);
    pmc_ts_cumulated.data(isnan(pmc_ts_cumulated.data)) = 0 ;
end