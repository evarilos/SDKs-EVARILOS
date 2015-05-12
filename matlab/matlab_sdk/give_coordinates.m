function [x,y,z,room] = give_coordinates(message)

    x = message.raw_measurement{1,1}.receiver_location.coordinate_x;
    y = message.raw_measurement{1,1}.receiver_location.coordinate_y;
    z = message.raw_measurement{1,1}.receiver_location.coordinate_z;
    room = message.raw_measurement{1,1}.receiver_location.room_label;
    
end