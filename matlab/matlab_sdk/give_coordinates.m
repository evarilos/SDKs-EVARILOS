function [x,y,z,room] = give_coordinates(message)
% GIVE_COORDINATES provides ground truth coordinates of a measurement.

% author = "Filip Lemic"
% copyright = "Copyright 2015, EVARILOS Project"

% version = "1.0.0"
% maintainer = "Filip Lemic"
% email = "lemic@tkn.tu-berlin.de"
% status = "Development"

    x = message.raw_measurement{1,1}.receiver_location.coordinate_x;
    y = message.raw_measurement{1,1}.receiver_location.coordinate_y;
    try
        z = message.raw_measurement{1,1}.receiver_location.coordinate_z;
        room = message.raw_measurement{1,1}.receiver_location.room_label;
    catch
        z = 0;
        room = 'n/a';
    end
    
end