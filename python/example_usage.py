#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""example_usage.py: using the services to evaluate an example fingerprinting algorithm."""

__author__ = "Filip Lemic"
__copyright__ = "Copyright 2015, EVARILOS Project"

__version__ = "1.0.0"
__maintainer__ = "Filip Lemic"
__email__ = "lemic@tkn.tu-berlin.de"
__status__ = "Development"

from python_sdk import simple_benchmarking as sb
from python_sdk.generateURL import RequestWithMethod
from python_sdk import raw_data_pb2
import json
import pprint
import time
import urllib2
from fingerprinting_algorithm import *

apiURL = 'http://ebp.evarilos.eu:5000/'

db_id_training = "wifi_beacon_rssi_twist_small_macbook" 
coll_id_training = "training" 

# Which data IDs from the runtime set are to be evaluated
data_ids_runtime = range(1,21)

req = RequestWithMethod(apiURL + 'evarilos/raw_data/v1.0/database/' + db_id_training  + '/collection/' + coll_id_training + '/message', 'GET', headers={"Content-Type": "application/json"})
resp = urllib2.urlopen(req)
messages_training = json.loads(resp.read())
raw_data_collection_training = {}

for id in messages_training.keys():
    data_id = str(messages_training[id]['data_id'])
    req = urllib2.Request(apiURL + 'evarilos/raw_data/v1.0/database/' + db_id_training  + '/collection/' + coll_id_training + '/message/' + data_id, headers={"Content-Type": "application/json"})
    response = urllib2.urlopen(req)
    message = json.loads(response.read())
    raw_data_collection_training[data_id] = message
    
algorithm = LocalizationAlgorithm()
results = {}

for i in data_ids_runtime:

	time1 = time.time()
	
	# Usage of the SDK function 
	measurements = sb.get_raw_measurement('wifi_beacon_rssi_twist_small_macbook','runtime',str(i))
	shaped_measurements = sb.reshape_to_dictionary(measurements)
	results[i] = algorithm.getPositionEstimate(raw_data_collection_training, shaped_measurements)
	
	time2 = time.time()
	results[i]['latency'] = time2 - time1

	print 'Estimated location ' + str(i) + ': (x,y) = (' + str(round(results[i]['est_coordinate_x'],2)) + ',' + str(round(results[i]['est_coordinate_y'],2)) + ')'

	# Usage of the SDK function 
	true_coordinates = sb.give_coordinates(measurements)

	results[i]['true_coordinate_x'] = true_coordinates['true_coordinate_x']
	results[i]['true_coordinate_y'] = true_coordinates['true_coordinate_y']
	results[i]['true_room'] = true_coordinates['true_room']

	print 'Ground truth ' + str(i) + ':       (x,y,z) = (' + str(true_coordinates['true_coordinate_x']) + ',' + str(true_coordinates['true_coordinate_y']) + ')' 
	print 'Estimated room label: ' + results[i]['est_room_label']
	print 'True room label:      ' + results[i]['true_room']
	print 'Latency: ' + str(round(results[i]['latency'],3))
	print ''

print ''
print "CALCULATED METRICS:"
print ''

# Usage of the SDK function 
metrics = sb.calculate_metrics(results)

print 'Average localization error: ' + str(round(metrics['accuracy_error_2D_average'],2))
print 'Median localization error:  ' + str(round(metrics['accuracy_error_2D_median'],2))
print 'Minimum localization error: ' + str(round(metrics['accuracy_error_2D_min'],2))
print 'Maximum localization error: ' + str(round(metrics['accuracy_error_2D_max'],2))
print ''
print 'Room level accuracy:        ' + str(round(metrics['room_accuracy_error_average'],2))
print ''
print 'Average latency: ' + str(round(metrics['latency_average'],2))
print 'Median latency:  ' + str(round(metrics['latency_median'],2))
print 'Minimum latency: ' + str(round(metrics['latency_min'],2))
print 'Maximum latency: ' + str(round(metrics['latency_max'],2))
print ''
