% Example usage of the MATLAB SDK for evaluation of a multilateration-based 
% indoor localization algorithm.

% author = "Filip Lemic"
% copyright = "Copyright 2015, EVARILOS Project"

% version = "1.0.0"
% maintainer = "Filip Lemic"
% email = "lemic@tkn.tu-berlin.de"
% status = "Development"

clc
clear
addpath('matlab_sdk');
addpath('matlab_sdk/protobuf_messages');
addpath('matlab_sdk/protobuflib')
warning off;
tic;
path_loss_exp = 2.25;

for i = 1:20
    
    % SDK function call
    measurement = get_raw_measurement('wifi_beacon_rssi_twist_small_macbook', 'no_interference_1', num2str(i)); 
    time1 = toc;
    
    est_dist = 0;
    A_mat = zeros(1000000, 2);
    B_mat = zeros(1000000, 1);
    
    iteration = 0;
    for num_ap = 1:(length(measurement.raw_measurement)-1)
        try
            iteration = iteration + 1;
            est_dist_end = (10 ^ (measurement.raw_measurement{1,num_ap}.rssi / 10)) ^ (- 1/path_loss_exp) / 1000;
            sender_x_end = measurement.raw_measurement{1,num_ap}.sender_location.coordinate_x;
            sender_y_end = measurement.raw_measurement{1,num_ap}.sender_location.coordinate_y;
        catch
        end
    end
    for num_ap = 1:(length(measurement.raw_measurement)-1)
       try
           sender_x = measurement.raw_measurement{1,num_ap}.sender_location.coordinate_x;
           sender_y = measurement.raw_measurement{1,num_ap}.sender_location.coordinate_y;
           rssi = measurement.raw_measurement{1,num_ap}.rssi;
        
           est_dist = (10 ^ (rssi / 10)) ^ (- 1/path_loss_exp) / 1000;
        
           A_mat(num_ap, :) = 2 .* [sender_x_end - sender_x, sender_y_end - sender_y];
           B_mat(num_ap, :) = (est_dist ^ 2 - est_dist_end ^ 2) - (sender_x ^ 2 - sender_x_end ^ 2) - (sender_y ^ 2 - sender_y_end ^ 2);
        catch
        end
    end
    A_mat = A_mat(1:iteration-1,:);
    B_mat = B_mat(1:iteration-1,:);

    % Sparsification (QR-factorization)
    
    if issparse(A_mat)
        R = qr(A_mat); 
    else
        R = triu(qr(A_mat));
    end
    
    x = R \ (R' \ (A_mat' * B_mat));
    r = B_mat - A_mat * x;
    err = R \ (R' \ (A_mat' * r));
    x = x + err;

    time2 = toc;
    latency = time2-time1;

    string1 = ['Estimated location   ', num2str(i), ': (x,y)=(', num2str(x(1),3), ',', num2str(x(2),3), ')'];
    disp(string1)
    
    % SDK function call
    [x1,y1,z1,room] = give_coordinates(measurement);
    string2 = ['Gound-truth location ', num2str(i), ': (x,y)=(', num2str(x1,3), ',', num2str(y1,3), ')'];
    disp(string2)
    string3 = ['Latency: ', num2str(latency,3)];
    disp(string3)
    disp(' ')

    room1 = cellstr(room);
    room2 = cellstr('n/a');
    results = struct('point_id', num2str(i), 'true_room_label', room1, 'est_room_label', room2, 'true_coordinate_x', num2cell(x1), 'true_coordinate_y', num2cell(y1), 'est_coordinate_x', num2cell(x(1)), 'est_coordinate_y', num2cell(x(2)), 'latency', num2cell(latency));
    
    final_results{i} = results;
end

% SDK function call
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

