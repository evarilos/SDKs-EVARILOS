addpath('matlab_sdk');
warning off;
tic;
path_loss_exp = 2.45;

for i = 1:20
    
    measurement = get_raw_measurement('ieee802154_rssi_twist_small_stm32w', 'no_interference_1', num2str(i)); 
    time1 = toc;
    
    est_dist = 0;
    A = zeros(length(measurement.raw_measurement) - 1, 3);
    B = zeros(length(measurement.raw_measurement) - 1, 1);
    est_dist_end = (10 ^ (measurement.raw_measurement{1,end}.rssi / 10)) ^ (- 1/path_loss_exp) / 1000;
    
    for num_ap = 1:(length(measurement.raw_measurement)-1)
        sender_x = measurement.raw_measurement{1,num_ap}.sender_location.coordinate_x;
        sender_y = measurement.raw_measurement{1,num_ap}.sender_location.coordinate_y;
        sender_z = measurement.raw_measurement{1,num_ap}.sender_location.coordinate_z;
        rssi = measurement.raw_measurement{1,num_ap}.rssi;
        
        est_dist = (10 ^ (rssi / 10)) ^ (- 1/path_loss_exp) / 1000;
        
        A(num_ap, :) = 2 .* [measurement.raw_measurement{1,end}.sender_location.coordinate_x - sender_x, measurement.raw_measurement{1,end}.sender_location.coordinate_y - sender_y,  measurement.raw_measurement{1,end}.sender_location.coordinate_z - sender_z];
        B(num_ap, :) = (est_dist ^ 2 - est_dist_end ^ 2) - (sender_x ^ 2 - measurement.raw_measurement{1,end}.sender_location.coordinate_x ^ 2) - (sender_y ^ 2 - measurement.raw_measurement{1,end}.sender_location.coordinate_y ^ 2) - (sender_z ^ 2 - measurement.raw_measurement{1,end}.sender_location.coordinate_z ^ 2);        
    end
    
    % Sparsification (QR-factorization)
    
    if issparse(A)
        R = qr(A); 
    else
        R = triu(qr(A));
    end
    
    x = R \ (R' \ (A' * B));
    r = B - A * x;
    err = R \ (R' \ (A' * r));
    x = x + err;
    
    % Storing the estimated position
    if isnan(x(1))
        x(1) = 10;
        x(2) = 10;
    end
    x(3) = 9.53;
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

