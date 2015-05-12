function [ metrics ] = calculate_metrics( results )
%CALCULATE_METRICS calcluates the performance metrics fo the evaluation fo
%RF-based indoor localization algorithms.

j = savejson(results);

header = http_createHeader('Content-Type','application/json');
URL = 'http://ebp.evarilos.eu:5012/evarilos/ece/v1.0/calculate_and_store_metrics_2';

resp = urlread2(URL,'POST',j,header);
metrics = JSON.parse(resp);

end

