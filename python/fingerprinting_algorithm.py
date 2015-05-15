from scipy.stats.mstats import mquantiles
import numpy as np

def most_common(lst):
    """   """
    return max(set(lst), key=lst.count)

class LocalizationAlgorithm():
    """
    Implementation of an fingerprinting-based localization algorithm called 'Quantile Localization'.
    """

    def hausdorffDistance(self, A, B):
        """   """
        distance = 0
        d_min = abs(A[0] - B[0])
        for i in A:
            for j in B:
                d = abs(i - j)
                if d < d_min:
                    d_min = d
            if d > distance:
                distance = d
        return distance

    def getPositionEstimate(self, training_dataset, fingerprint):
        """   """
        runtime_data = {}
        for i in fingerprint.keys():
            runtime_data[i] = fingerprint[i]

        runtime_quantiles = {}
        for key in runtime_data.keys():
            runtime_quantiles[key] = np.array(mquantiles(runtime_data[key], [0, 0.33, 0.67, 1]))
        
        metric_ref = {}
        estimated_position_label = {}

        metric_ref[0] = 0
        metric_ref[1] = 0
        metric_ref[2] = 0
        
        estimated_position_label[0] = '0'
        estimated_position_label[1] = '0'
        estimated_position_label[2] = '0'
        
        for meas_key in training_dataset.keys():
            training_data = {}

            for i in range(0, len(training_dataset[meas_key]['raw_measurement'])):
                key = training_dataset[meas_key]['raw_measurement'][i]['sender_bssid']

                if key not in training_data.keys():
                    training_data[key] = np.array(training_dataset[meas_key]['raw_measurement'][i]['rssi'])
                else:
                    training_data[key] = np.append(training_data[key], training_dataset[meas_key]['raw_measurement'][i]['rssi'])
                    
            metric = 0
            training_quantiles = {}
            for key in runtime_quantiles.keys():
                if key in training_data.keys():
                    training_quantiles[key] = np.array(mquantiles(training_data[key], [0, 0.33, 0.67, 1]))
                else:
                    training_quantiles[key] = np.array(mquantiles(-100, [0, 0.33, 0.67, 1]))
                metric += abs(np.linalg.norm(runtime_quantiles[key] - training_quantiles[key]))
                #metric += self.hausdorffDistance(runtime_quantiles[key], training_quantiles[key])


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

        for i in estimated_position_label.keys():
            coord_x.append(float(training_dataset[str(estimated_position_label[i])]['raw_measurement'][1]['receiver_location']['coordinate_x']))
            coord_y.append(float(training_dataset[str(estimated_position_label[i])]['raw_measurement'][1]['receiver_location']['coordinate_y']))
            room.append(training_dataset[str(estimated_position_label[i])]['raw_measurement'][1]['receiver_location']['room_label'])
        
        estimated_position = {}
        estimated_position['est_coordinate_x'] = (1.0/3)*coord_x[0] + (1.0/3)*coord_x[1] + (1.0/3)*coord_x[2]
        estimated_position['est_coordinate_y'] = (1.0/3)*coord_y[0] + (1.0/3)*coord_y[1] + (1.0/3)*coord_y[2]
        estimated_position['est_room_label'] = most_common(room)
        return estimated_position


class LocalizationAlgorithm2():
    """
    Implementation of an fingerprinting-based localization algorithm called 'Euclidean Distance'.
    """

    def getPositionEstimate(self, training_dataset, fingerprint):

        runtime_data = {}
        for i in fingerprint.keys():
            runtime_data[i] = fingerprint[i]
        

        runtime_average = {}
        for key in runtime_data.keys():
            runtime_average[key] = np.mean(runtime_data[key])

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
            for i in range(0, len(training_dataset[meas_key]['raw_measurement'])):
                key = training_dataset[meas_key]['raw_measurement'][i]['sender_bssid']
                if key not in training_data.keys():
                    training_data[key] = np.array(training_dataset[meas_key]['raw_measurement'][i]['rssi'])
                else:
                    training_data[key] = np.append(training_data[key], training_dataset[meas_key]['raw_measurement'][i]['rssi'])
        
            training_average = {}
            for key in training_data.keys():
                training_average[key] = np.mean(training_data[key])

            for key in training_average.keys():
                if key in runtime_average.keys():
                    metric += np.absolute(runtime_average[key] - training_average[key])
                else:
                    metric += np.absolute(-100 - training_average[key])

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
        est_label = []
        room = []

        for i in estimated_position_label.keys():
            coord_x.append(float(training_dataset[str(estimated_position_label[i])]['raw_measurement'][1]['receiver_location']['coordinate_x']))
            coord_y.append(float(training_dataset[str(estimated_position_label[i])]['raw_measurement'][1]['receiver_location']['coordinate_y']))
            room.append(training_dataset[str(estimated_position_label[i])]['raw_measurement'][1]['receiver_location']['room_label'])
            est_label.append(estimated_position_label[i])

        estimated_position = {}
        estimated_position['est_position_label'] = most_common(est_label)
        estimated_position['est_coordinate_x'] = (1.0/3)*coord_x[0] + (1.0/3)*coord_x[1] + (1.0/3)*coord_x[2]
        estimated_position['est_coordinate_y'] = (1.0/3)*coord_y[0] + (1.0/3)*coord_y[1] + (1.0/3)*coord_y[2]
        estimated_position['est_room_label'] = most_common(room)
        return estimated_position