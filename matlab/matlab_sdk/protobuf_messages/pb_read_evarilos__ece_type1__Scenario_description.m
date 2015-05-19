function [scenario_description] = pb_read_evarilos__ece_type1__Scenario_description(buffer, buffer_start, buffer_end)
%pb_read_evarilos__ece_type1__Scenario_description Reads the protobuf message Scenario_description.
%   function [scenario_description] = pb_read_evarilos__ece_type1__Scenario_description(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     testbed_label  : required string, defaults to ''.
%     testbed_description: required string, defaults to ''.
%     experiment_description: required string, defaults to ''.
%     sut_description: required string, defaults to ''.
%     receiver_description: required string, defaults to ''.
%     sender_description: required string, defaults to ''.
%     interference_description: required string, defaults to ''.
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
  
  descriptor = pb_descriptor_evarilos__ece_type1__Scenario_description();
  scenario_description = pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  scenario_description.descriptor_function = @pb_descriptor_evarilos__ece_type1__Scenario_description;
