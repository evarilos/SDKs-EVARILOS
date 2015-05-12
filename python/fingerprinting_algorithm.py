from scipy.stats.mstats import mquantiles
from scipy.sparse import csr_matrix
import math as m
import numpy as np
from numpy import linalg
import random
import scipy

def most_common(lst):
    return max(set(lst), key=lst.count)

class LocalizationAlgorithm():
    """
    This is the implementation of the Euclidean indoor fingerprinting-based indoor localization algorithm
    """

    def getPositionEstimate(self, training_dataset, fingerprint):

        runtime_data = {}
        for i in fingerprint.keys():
            runtime_data[i] = fingerprint[i]
        

        runtime_average = {}
        for key in runtime_data.keys():
            runtime_average[key] = np.average(runtime_data[key])

        metric_ref = {}
        estimated_position_label = {}
        
        metric_ref[0] = 0
        metric_ref[1] = 0
        metric_ref[2] = 0

        estimated_position_label[0] = '0'
        estimated_position_label[1] = '0'
        estimated_position_label[2] = '0'

        for meas_key in training_dataset.keys():
            metric = 0
            training_data = {}
            for i in range(0, len(training_dataset[meas_key].rawRSSI)):
                key = training_dataset[meas_key].rawRSSI[i].sender_bssid
                if key not in training_data.keys():
                    training_data[key] = np.array(training_dataset[meas_key].rawRSSI[i].rssi)
                else:
                    training_data[key] = np.append(training_data[key], training_dataset[meas_key].rawRSSI[i].rssi)
        
            training_average = {}
            for key in training_data.keys():
                training_average[key] = np.average(training_data[key])

            for key in training_average.keys():
                if key in runtime_average.keys():
                    metric += np.absolute(runtime_average[key] - training_average[key])

            if metric_ref[0] == 0: 
                metric_ref[0] = metric
                estimated_position_label[0] = meas_key
            elif metric_ref[1] == 0:
                metric_ref[1] = metric
                estimated_position_label[1] = meas_key
            elif metric_ref[2] == 0:
                metric_ref[2] = metric
                estimated_position_label[2] = meas_key

            else:
                if metric < metric_ref[0]:
                    metric_ref[2] = metric_ref[1]
                    metric_ref[1] = metric_ref[0]
                    metric_ref[0] = metric
                    estimated_position_label[2] = estimated_position_label[1]
                    estimated_position_label[1] = estimated_position_label[0]
                    estimated_position_label[0] = meas_key
                elif metric < metric_ref[1]:
                    metric_ref[2] = metric_ref[1]
                    metric_ref[1] = metric
                    estimated_position_label[2] = estimated_position_label[1]
                    estimated_position_label[1] = meas_key
                elif metric < metric_ref[2]:
                    metric_ref[2] = metric
                    estimated_position_label[2] = meas_key

        coord_x = []
        coord_y = []
        room = []
        est_label = []
        
        for i in estimated_position_label.keys():
            coord_x.append(float(training_dataset[str(estimated_position_label[i])].location.coordinate_x))
            coord_y.append(float(training_dataset[str(estimated_position_label[i])].location.coordinate_y))
            room.append(training_dataset[estimated_position_label[i]].location.room_label)
            est_label.append(estimated_position_label[i])

        estimated_position = {}
        estimated_position['est_position_label'] = most_common(est_label)
        estimated_position['est_coordinate_x'] = (1.0/3)*coord_x[0] + (1.0/3)*coord_x[1] + (1.0/3)*coord_x[2]
        estimated_position['est_coordinate_y'] = (1.0/3)*coord_y[0] + (1.0/3)*coord_y[1] + (1.0/3)*coord_y[2]
        estimated_position['est_room_label'] = room[0]
        return estimated_position


