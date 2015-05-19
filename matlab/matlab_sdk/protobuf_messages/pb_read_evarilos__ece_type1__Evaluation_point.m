function [evaluation_point] = pb_read_evarilos__ece_type1__Evaluation_point(buffer, buffer_start, buffer_end)
%pb_read_evarilos__ece_type1__Evaluation_point Reads the protobuf message Evaluation_point.
%   function [evaluation_point] = pb_read_evarilos__ece_type1__Evaluation_point(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     point_id       : required int32, defaults to int32(0).
%     localized_node_id: optional int32, defaults to int32(0).
%     true_coordinate_x: required double, defaults to double(0).
%     true_coordinate_y: required double, defaults to double(0).
%     true_coordinate_z: optional double, defaults to double(0).
%     true_room_label: optional string, defaults to ''.
%     est_coordinate_x: required double, defaults to double(0).
%     est_coordinate_y: required double, defaults to double(0).
%     est_coordinate_z: optional double, defaults to double(0).
%     est_room_label : optional string, defaults to ''.
%     latency        : optional double, defaults to double(0).
%     power_consumption: optional double, defaults to double(0).
%
%   See also pb_read_evarilos__ece_type1.
  
  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end
  
  descriptor = pb_descriptor_evarilos__ece_type1__Evaluation_point();
  evaluation_point = pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  evaluation_point.descriptor_function = @pb_descriptor_evarilos__ece_type1__Evaluation_point;
