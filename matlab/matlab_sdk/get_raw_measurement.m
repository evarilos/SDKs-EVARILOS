function [ message ] = get_raw_measurement(db_id, coll_id, data_id)
% GET_RAW_MEASUREMENT Get a raw measurment for the evaluation fo RF-based
% indoor loclaization algorithms.
% Check the documentation: https://github.com/flemic/R2DM-EVARILOS

% author = "Filip Lemic"
% copyright = "Copyright 2015, EVARILOS Project"

% version = "1.0.0"
% maintainer = "Filip Lemic"
% email = "lemic@tkn.tu-berlin.de"
% status = "Development"

    apiURL = 'http://ebp.evarilos.eu:5000/';
    
    req = urlread([apiURL 'evarilos/raw_data/v1.0/database/' db_id '/collection/' coll_id '/message/' data_id]);
    message = strrep(req, '_id', 'id');
    message = strrep(message, 'dataid', 'data_id');
    message = strrep(message, 'erid', 'er_id');
    message = JSON.parse(message);

end

