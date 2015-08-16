# -*- coding: utf-8 -*-
'''
Management of Redis server
==========================

.. versionadded:: 2014.7.0

:depends:   - redis Python module
:configuration: See :py:mod:`salt.modules.redis` for setup instructions.

.. code-block:: yaml

    key_in_redis:
      redis.string:
        - value: string data

The redis server information specified in the minion config file can be
overridden in states using the following arguments: ``host``, ``post``, ``db``,
``password``.

.. code-block:: yaml

    key_in_redis:
      redis.string:
        - value: string data
        - host: localhost
        - port: 6379
        - db: 0
        - password: somuchkittycat
'''
import copy
import logging
log = logging.getLogger(__name__)

__virtualname__ = 'redis'


def __virtual__():
    '''
    Only load if the redis module is in __salt__
    '''
    if 'redis.set_key' in __salt__:
        return __virtualname__
    return False


def string(name, value, expire=None, expireat=None, **connection_args):
    '''
    Ensure that the key exists in redis with the value specified

    name
        Redis key to manage

    value
        Data to persist in key

    expire
        Sets time to live for key in seconds

    expireat
        Sets expiration time for key via UNIX timestamp, overrides `expire`
    '''
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Key already set to defined value'}

    old_key = __salt__['redis.get_key'](name, **connection_args)

    if old_key != value:
        __salt__['redis.set_key'](name, value, **connection_args)
        ret['changes'][name] = 'Value updated'
        ret['comment'] = 'Key updated to new value'

    if expireat:
        __salt__['redis.expireat'](name, expireat, **connection_args)
        ret['changes']['expireat'] = 'Key expires at {0}'.format(expireat)
    elif expire:
        __salt__['redis.expire'](name, expire, **connection_args)
        ret['changes']['expire'] = 'TTL set to {0} seconds'.format(expire)

    return ret


def absent(name, keys=None, **connection_args):
    '''
    Ensure key absent from redis

    name
        Key to ensure absent from redis

    keys
        list of keys to ensure absent, name will be ignored if this is used
    '''
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Key(s) specified already absent'}

    if keys:
        if not isinstance(keys, list):
            ret['result'] = False
            ret['comment'] = '`keys` not formed as a list type'
            return ret
        delete_list = [key for key in keys
                       if __salt__['redis.exists'](key, **connection_args)]
        if not len(delete_list):
            return ret
        __salt__['redis.delete'](*delete_list, **connection_args)
        ret['changes']['deleted'] = delete_list
        ret['comment'] = 'Keys deleted'
        return ret

    if __salt__['redis.exists'](name, **connection_args):
        __salt__['redis.delete'](name, **connection_args)
        ret['comment'] = 'Key deleted'
        ret['changes']['deleted'] = [name]
    return ret


def slaveof(name, sentinel_host=None, sentinel_port=None, sentinel_password=None, **connection_args):
    '''
    Set this redis instance as a slave.
    
    name
        Master to make this a slave of

    sentinel_host
        Ip of the sentinel to check for the master

    sentinel_port
        Port of the sentinel to check for the master

    '''
    ret = {'name': name,
           'changes': {},
           'result': False,
           'comment': 'Failed to setup slave'}

    kwargs = copy.copy(connection_args)
    sentinel_master = __salt__['redis.sentinel_get_master_ip'](name, sentinel_host, sentinel_port, sentinel_password)
    if sentinel_master['master_host'] in __salt__['network.ip_addrs']():
        ret['result'] = True
        ret['comment'] = 'Minion is the master: '.format(name)
        return ret

    first_master = __salt__['redis.get_master_ip'](**connection_args)
    if first_master == sentinel_master:
        ret['result'] = True
        ret['comment'] = 'Minion already slave of master: {0}'.format(name)
        return ret


    if __opts__['test'] == True:
        ret['comment'] = 'Minion will be made a slave of {0}: {1}'.format(name, sentinel_master['host'])
        ret['result'] = None
        return ret

    kwargs.update(**sentinel_master)
    __salt__['redis.slaveof'](**kwargs)

    current_master = __salt__['redis.get_master_ip'](**connection_args)
    if current_master != sentinel_master:
        return ret

    ret['result'] = True
    ret['changes'] = {
        'old': first_master,
        'new': current_master,
    }
    ret['comment'] = 'Minion successfully connected to master: {0}'.format(name)

    return ret


def reset_sentinel(name, slave=None, sentinel=None, sentinel_host=None, sentinel_port=None, sentinel_password=None):
    '''
    Set this redis instance as a slave.
    
    name
        Master to reset

    slave
        slave to remove from master

    sentinel
        sentinel to remove from master

    sentinel_host
        Ip of the sentinel

    sentinel_port
        Port of the sentinel

    sentinel_password
        Password of the sentinel
    '''
    ret = {'name': name,
           'changes': {},
           'result': False,
           'comment': 'Failed to reset master: {0}'.format(name)}

    if slave is None and sentinel is None:
        ret['comment'] = 'Slave or Sentinel must be set for tracking of what is reset'
        return ret

    kwargs = {
        'master': name,
        'host': sentinel_host,
        'port': sentinel_port,
        'password': sentinel_password,
    }

    if slave is not None:
        slaves = __salt__['redis.get_slaves'](**kwargs)
    else:
        slaves = []

    if sentinel is not None:
        sentinels = __salt__['redis.get_sentinels'](**kwargs)
    else:
        sentinels = []

    remove_slave = slave in [x['name'] for x in slaves]
    remove_sentinel = sentinel in [x['name'] for x in slaves]

    if remove_slave is False and remove_sentinel is False:
        ret['comment'] = 'Slave or Sentinel is not included: {0}'.format(name)
        ret['result'] = True
        return ret

    elif __opts__['test'] is True:
        ret['result'] = None
        ret['changes'] = {
            'remove_slave': remove_slave,
            'remove_sentinel': remove_sentinel,
        }

    if remove_slave is True:
        log.debug('removeing_slave')
        new_slaves = __salt__['redis.reset_sentinel'](**kwargs)
        changes = filter(lambda x: not any(y['name'] == x['name'] for y in new_slaves), slaves)
        log.debug(slaves)
        log.debug(new_slaves)
        if not changes:
            ret['result'] = False
            ret['comment'] = 'Failed to remove slave'
            return ret
        ret['changes']['slaves_removed'] = changes
        ret['comment'] = 'Successfully reset {0}'.format(name)
        ret['result'] = True

    if remove_sentinel is True:
        log.debug('removeing_sentinel')
        if ret['result'] is False:
             __salt__['redis.reset_sentinel'](**kwargs)
        new_sentinels = __salt__['redis.get_sentinels'](name)
        changes = filter(lambda x: not any(y['name'] == x['name'] for y in new_sentinels), sentinels)
        if not changes:
            ret['result'] = False
            ret['comment'] = 'Failed to remove sentinel'
            return ret
        ret['changes']['sentinels_removed'] = changes
        ret['comment'] = 'Successfully reset {0}'.format(name)
        ret['result'] = True

    return ret
