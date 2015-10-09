from __future__ import print_function
import random
import re
import time
import copy
import threading
import functools
from redis import StrictRedis

import salt.config
from salt.cloud import CloudClient
from salt.client import LocalClient
from salt.runner import RunnerClient
from salt.wheel import WheelClient
import salt.utils.event

import logging
log = logging.getLogger(__name__)

dontdelete = ('board1.taplists.beer', 'board2.taplists.beer', 'board3.taplists.beer')

def _conn():
    return CloudClient('/etc/salt/cloud')

def _local():
    return LocalClient('/etc/salt/master')

def _runner():
    return RunnerClient(__opts__)

def _wheel():
    return WheelClient(salt.config.master_config('/etc/salt/master'))

def create(name='board[0-9]+\.taplists\.beer'):
    with open('/creating', 'w') as createfile:
        print(time.time(), file=createfile)
    cloud = _conn()
    local = _local()
    this = re.compile(name)
    servers = filter(lambda x: this.match(x[0]), cloud.query()['my-nova']['nova'].items())
    while True:
        num = random.randint(4, 100) 
        if 'board{0}.taplists.beer'.format(num) in [x[0] for x in servers]:
            continue
        break
    print('board{0}.taplists.beer'.format(num))
    #runner.cmd('cloud.profile', arg=['centos-1-nova', ['board{0}.taplists.beer'.format(num)]])
    try:
        cloud.profile('centos-1-nova', ['board{0}.taplists.beer'.format(num)])
    except Exception:
        pass
    local.cmd('board{0}.taplists.beer'.format(num), 'state.highstate')

def create_all(servers):
    for name in servers:
        t = threading.Thread(target=create)
        t.setDaemon(True)
        t.start()

    main_thread = threading.currentThread()
    for t in threading.enumerate():
        if t is main_thread:
            continue
        t.join()


def _query():
    cloud = _conn()
    ret = None
    while not ret:
        ret = cloud.query().get('my-nova', {}).get('nova', {})
    return ret

def _remove_server(sip, servers):
    ret = []
    for server, info in servers:
        if sip in info['public_ips'] or sip in info['private_ips']:
            continue
        ret.append({server: info})
    return ret


def _check_lock():
    conn = StrictRedis()
    lock_status = conn.set('locked', True, ex=60, nx=True)
    while lock_status is None:
        time.sleep(5)
        lock_status = conn.set('locked', True, ex=60, nx=True)

def _delete_lock():
    conn = StrictRedis()
    conn.delete('locked')

def always_unlock(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        ret = False
        try:
            _check_lock()
            kw = {}
            if 'name' in kwargs:
                kw['name'] = kwargs['name']
            ret = func(**kw)
        except Exception as exc:
            print(exc)
        _delete_lock()
        return ret
    return wrapper


@always_unlock
def delete(name='board[0-9]+\.taplists\.beer'):
    with open('/creating', 'r') as createfile:
        line = float(createfile.readlines()[0].strip())
        if line >= time.time() - 300:
            return False
    cloud = _conn()
    local = _local()
    runner = _runner()
    this = re.compile(name)
    if any(this.match(key) and value['state'] == 'BUILD' for key, value in _query().items()):
        return False
    servers = filter(lambda x: this.match(x[0]) and x[1]['state'] == 'ACTIVE' and x[0] not in dontdelete, _query().items())
    if servers:
        for k, v in local.cmd('board*', 'redis.get_master_ip', ['localhost']).iteritems():
            try:
                _remove_server(v['master_host'], servers)
            except TypeError:
                cloud.destroy([k])
                return True

        server = random.choice(servers)[0]
        try:
            local.cmd(server, 'state.sls', ['services.stop'])[server][0]
        except Exception:
            wheel = _wheel()
            try:
                wheel.cmd('key.delete', [server])
            except Exception:
                cloud.destroy([server])
                return True
        runner.cmd('loadbalancer.remove', [server])
        ip = local.cmd(server, 'network.ip_addrs', ['eth2'])[server][0]
        cloud.destroy([server])
        while _query().get(server, False) is not False:
            time.sleep(1)
        runner.cmd('state.orchestrate', arg=['sentinels.reset'], kwarg={
            'pillar': {
                'slave': '{0}:6379'.format(ip),
                'sentinel': '{0}:26379'.format(ip),
            },
        })
