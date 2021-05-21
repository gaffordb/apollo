#!/usr/bin/env python3

# ****************************************************************************
# Copyright 2019 The Apollo Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ****************************************************************************
# -*- coding: utf-8 -*-
"""Module for example of listener."""

from cyber.python.cyber_py3 import cyber
from cyber.proto.unit_test_pb2 import ChatterBenchmark
from modules.perception.proto.perception_obstacle_pb2 import PerceptionObstacles
from modules.drivers.gnss.proto.gnss_best_pose_pb2 import GnssBestPose
#from modules.localization.proto.pose_pb2 import ???
from modules.localization.proto.localization_pb2 import LocalizationEstimate
import os
import time
#from modules.drivers.gnss.gnss_pb2 import Imu (bad)
from google.protobuf.json_format import MessageToJson

fname = 'runlog-' + open('MODULE-VERSION.txt', "r").read().rstrip() + '-' + str(time.time())

f = open(fname, 'w')

def callback(data):
    """
    Reader message callback.
    """
    print("=" * 80)
    print("py:reader callback msg->:")
    #print(data)
    res = [f.name for f in data.DESCRIPTOR.fields]
    json_data = MessageToJson(data)
    print(json_data)
    #print(os.environ['PYTHONPATH'])
    print(res)
    print(data.pose.position)
    print("=" * 80)
    exit()

def log_data(data):
    f.write(MessageToJson(data))

def test_listener_class():
    """
    Reader message.
    """
    print("=" * 120)
    test_node = cyber.Node("listener")
    #test_node.create_reader("/apollo/perception/obstacles", PerceptionObstacles, callback)
    ##test_node.create_reader("/apollo/sensor/gnss/imu", Imu, callback)
    test_node.create_reader("/apollo/localization/pose", LocalizationEstimate, log_data)
    #test_node.create_reader("/apollo/sensor/gnss/best_pose", GnssBestPose, callback)

    #print(cyber.ChannelUtils.get_msgtype("/apollo/localization/pose"))
    #print(test_node.get_protodesc("/apollo/sensor/gnss/imu"))

    #print(cyber.ChannelUtils.get_msgtype("/apollo/perception/obstacles"))

    #print(cyber.ChannelUtils.get_msgtype("/apollo/perception/obstacles"))

    test_node.spin()

if __name__ == '__main__':
    cyber.init()
    test_listener_class()
    cyber.shutdown()
    f.close()
