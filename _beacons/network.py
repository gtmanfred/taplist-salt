# -*- coding: utf-8 -*-
'''
Beacon to monitor statistics from ethernet adapters

.. versionadded:: 2015.5.0
'''

# Import Python libs
from __future__ import absolute_import
import logging
import time
import psutil

log = logging.getLogger(__name__)

__virtualname__ = 'network'

__attrs = ['bytes_sent', 'bytes_recv', 'packets_sent',
           'packets_recv', 'errin', 'errout',
           'dropin', 'dropout']


def _to_list(obj):
    '''
    Convert snetinfo object to list
    '''
    ret = {}

    for attr in __attrs:
        # Better way to do this?
        ret[attr] = getattr(obj, attr)
    return ret


def __virtual__():
    return __virtualname__


def validate(config):
    '''
    Validate the beacon configuration
    '''

    VALID_ITEMS = [
        'type', 'bytes_sent', 'bytes_recv', 'packets_sent',
        'packets_recv', 'errin', 'errout', 'dropin',
        'dropout'
    ]

    # Configuration for load beacon should be a list of dicts
    if not isinstance(config, dict):
        log.info('Configuration for load beacon must be a dictionary.')
        return False
    else:
        for item in config:
            if not isinstance(config[item], dict):
                log.info('Configuration for load beacon must '
                         'be a dictionary of dictionaries.')
                return False
            else:
                if not any(j in VALID_ITEMS for j in config[item]):
                    log.info('Invalid configuration item in '
                             'Beacon configuration.')
                    return False
    return True


def beacon(config):
    '''
    Emit the network statistics of this host.

    Specify thresholds for each network stat
    and only emit a beacon if any of them are
    exceeded.

    Emit beacon when any values are equal to
    configured values.

    .. code-block:: yaml

        beacons:
          network_info:
            eth0:
                - type: equal
                - bytes_sent: 100000
                - bytes_recv: 100000
                - packets_sent: 100000
                - packets_recv: 100000
                - errin: 100
                - errout: 100
                - dropin: 100
                - dropout: 100

    Emit beacon when any values are greater
    than to configured values.

    .. code-block:: yaml

        beacons:
          network_info:
            eth0:
                - type: greater
                - bytes_sent: 100000
                - bytes_recv: 100000
                - packets_sent: 100000
                - packets_recv: 100000
                - errin: 100
                - errout: 100
                - dropin: 100
                - dropout: 100


    '''
    ret = []

    _stats = psutil.net_io_counters(pernic=True)
    time.sleep(1)

    for interface in config:
        if interface in _stats:
            _if_stats = _stats[interface]
            _diff = False
            _if_stats2 = psutil.net_io_counters(pernic=True)[interface]
            for attr in __attrs:
                if attr in config[interface]:
                    if getattr(_if_stats2, attr) - getattr(_if_stats, attr) > int(config[interface][attr]):
                        _diff = True
            if _diff:
                ret.append({'interface': interface,
                            'network_info': _to_list(_if_stats)})
    return ret
