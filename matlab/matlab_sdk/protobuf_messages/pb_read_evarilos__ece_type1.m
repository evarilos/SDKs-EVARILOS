function [ece_type1] = pb_read_evarilos__ece_type1(buffer, buffer_start, buffer_end)
%pb_read_evarilos__ece_type1 Reads the protobuf message ece_type1.
%   function [ece_type1] = pb_read_evarilos__ece_type1(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     timestamp_utc  : required int64, defaults to int64(0).
%     experiment_label: required string, defaults to ''.
%     locations      : repeated <a href="matlab:help pb_read_evarilos__ece_type1__Evaluation_point">evarilos.ece_type1.Evaluation_point</a>, defaults to struct([]).
%     scenario       : required <a href="matlab:help pb_read_evarilos__ece_type1__Scenario_description">evarilos.ece_type1.Scenario_description</a>, defaults to struct([]).
%     power_consumption_per_experiment: optional double, defaults to double(0).
%     store_metrics  : optional uint32, defaults to uint32(0).
%     metrics_storage_URI: optional string, defaults to ''.
%     metrics_storage_database: optional string, defaults to ''.
%     metrics_storage_collection: optional string, defaults to ''.
%
%   See also pb_read_evarilos__ece_type1__Evaluation_point, pb_read_evarilos__ece_type1__Scenario_description.
  
  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end
  
  descriptor = pb_descriptor_evarilos__ece_type1();
  ece_type1 = pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  ece_type1.descriptor_function = @pb_descriptor_evarilos__ece_type1;
