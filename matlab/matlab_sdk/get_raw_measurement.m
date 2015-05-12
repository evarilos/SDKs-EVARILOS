function [ message ] = get_raw_measurement(db_id, coll_id, data_id)
%GET_RAW_MEASUREMENT Summary of this function goes here
%   Detailed explanation goes here

    apiURL = 'http://ebp.evarilos.eu:5000/';
    
    req = urlread([apiURL 'evarilos/raw_data/v1.0/database/' db_id '/collection/' coll_id '/message/' data_id]);
    message = strrep(req, '_id', 'id');
    message = strrep(message, 'dataid', 'data_id');
    message = strrep(message, 'erid', 'er_id');
    message = JSON.parse(message);

end

