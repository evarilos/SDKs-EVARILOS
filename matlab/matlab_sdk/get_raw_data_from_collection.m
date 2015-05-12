function [ messages ] = get_raw_data_from_collection(db_id, coll_id)
%BENCHMARKING Summary of this function goes here
%   Detailed explanation goes here

    apiURL = 'http://ebp.evarilos.eu:5000/';

    req = urlread([apiURL 'evarilos/raw_data/v1.0/database/' db_id '/collection/' coll_id '/message']);
    data = strrep(req, '_id', 'id');
    data = strrep(data, 'dataid', 'data_id');
    data = JSON.parse(data);
    
    names = fieldnames(data);
    messages = containers.Map;
    
    for str = names'
        data_id = data.(char(str)).data_id;
        req = urlread([apiURL 'evarilos/raw_data/v1.0/database/' db_id '/collection/' coll_id '/message/' data_id]);
        message = strrep(req, '_id', 'id');
        message = strrep(message, 'dataid', 'data_id');
        message = strrep(message, 'erid', 'er_id');
        message = JSON.parse(message);
        messages(data_id) = message;
    end

end

