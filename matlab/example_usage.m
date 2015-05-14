addpath('matlab_sdk');
warning off;
tic;

measurements_training = get_raw_data_from_collection('wifi_beacon_rssi_twist_small_macbook', 'training'); 

for i = 1:20
    
    measurement = get_raw_measurement('wifi_beacon_rssi_twist_small_macbook', 'no_interference_1', num2str(i)); 
    time1 = toc;
    
    % Implement the algorithm here

    time2 = toc;
    latency = time2-time1;
   
    string1 = ['Estimated location   ', num2str(i), ': (x,y)=(', num2str(x(1),3), ',', num2str(x(2),3), ')'];
    disp(string1) 
    [x1,y1,z1,room] = give_coordinates(measurement);
    string2 = ['Gound-truth location ', num2str(i), ': (x,y)=(', num2str(x1,3), ',', num2str(y1,3), ')'];
    disp(string2)
    string3 = ['Latency: ', num2str(latency*1000,3)];
    disp(string3)
    disp(' ')
 
    room1 = cellstr(room);
    room2 = cellstr('n/a');
    results = struct('point_id', measurement.data_id, 'true_room_label', room1, 'est_room_label', room2, 'true_coordinate_x', num2cell(x1), 'true_coordinate_y', num2cell(y1), 'true_coordinate_z', num2cell(z1), 'est_coordinate_x', num2cell(x(1)), 'est_coordinate_y', num2cell(x(2)), 'est_coordinate_z', num2cell(x(3)), 'latency', num2cell(latency));
    
    final_results{i} = results;
end

metrics = calculate_metrics(final_results);

disp('CALCULATED METRICS:')
string1 = ['Average localization error: ', num2str(metrics.primary_metrics.accuracy_error_2D_average,3)];
disp(string1)
string1 = ['Median localization error:  ', num2str(metrics.primary_metrics.accuracy_error_2D_median,3)];
disp(string1)
string1 = ['Minimum localization error: ', num2str(metrics.primary_metrics.accuracy_error_2D_min,3)];
disp(string1)
string1 = ['Maximum localization error: ', num2str(metrics.primary_metrics.accuracy_error_2D_max,3)];
disp(string1)
disp(' ')

string1 = ['Average latency: ', num2str(metrics.primary_metrics.latency_average,3)];
disp(string1)
string1 = ['Median latency:  ', num2str(metrics.primary_metrics.latency_median,3)];
disp(string1)
string1 = ['Minimum latency: ', num2str(metrics.primary_metrics.latency_min,3)];
disp(string1)
string1 = ['Maximum latency: ', num2str(metrics.primary_metrics.latency_max,3)];
disp(string1)
disp(' ')

