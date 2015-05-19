function [ metrics ] = calculate_metrics( results )
% CALCULATE_METRICS calcluates the performance metrics for the evaluation
% of RF-based indoor localization algorithms.
% Check the documentation: https://github.com/flemic/ECE-EVARILOS

% author = "Filip Lemic"
% copyright = "Copyright 2015, EVARILOS Project"

% version = "1.0.0"
% maintainer = "Filip Lemic"
% email = "lemic@tkn.tu-berlin.de"
% status = "Development"

    message = pb_read_evarilos__ece_type1();
    message = pblib_set(message,'timestamp_utc',1);
    message = pblib_set(message,'experiment_label','dummy');

    message = pblib_set(message,'scenario',pb_read_evarilos__ece_type1__Scenario_description());
    message.scenario = pblib_set(message.scenario, 'testbed_label', 'dummy');
    message.scenario = pblib_set(message.scenario, 'testbed_description', 'dummy');
    message.scenario = pblib_set(message.scenario, 'experiment_description', 'dummy');
    message.scenario = pblib_set(message.scenario, 'sut_description', 'dummy');
    message.scenario = pblib_set(message.scenario, 'receiver_description', 'dummy');
    message.scenario = pblib_set(message.scenario, 'sender_description', 'dummy');
    message.scenario = pblib_set(message.scenario, 'interference_description', 'dummy');

    for i = 1:length(results)
        if i == 1
            message = pblib_set(message, 'locations', pb_read_evarilos__ece_type1__Evaluation_point());
        else
            message.locations(i) = pb_read_evarilos__ece_type1__Evaluation_point();
        end
        
        message.locations(i) = pblib_set(message.locations(i), 'point_id', i);
        message.locations(i) = pblib_set(message.locations(i), 'true_room_label', results{i}.true_room_label);
        message.locations(i) = pblib_set(message.locations(i), 'est_room_label', results{i}.est_room_label);
        message.locations(i) = pblib_set(message.locations(i), 'true_coordinate_x', results{i}.true_coordinate_x);    
        message.locations(i) = pblib_set(message.locations(i), 'true_coordinate_y', results{i}.true_coordinate_y);
        message.locations(i) = pblib_set(message.locations(i), 'est_coordinate_x', results{i}.est_coordinate_x);    
        message.locations(i) = pblib_set(message.locations(i), 'est_coordinate_y', results{i}.est_coordinate_y);
        message.locations(i) = pblib_set(message.locations(i), 'latency', results{i}.latency);
    end

    buffer = pblib_generic_serialize_to_string(message);

    header = http_createHeader('Content-Type','application/x-protobuf');
    URL = 'http://ebp.evarilos.eu:5002/evarilos/ece/v1.0/calculate_and_store_metrics';
     
    resp = urlread2(URL,'POST',buffer,header);
    metrics = JSON.parse(resp);
    




