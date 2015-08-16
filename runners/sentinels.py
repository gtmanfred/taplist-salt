import salt.config
import salt.runner

def process(servers):
    opts = salt.config.master_config('/etc/salt/master')
    runner = salt.runner.RunnerClient(opts)
    for server in servers:
        pillar = {'slave': server['redis_name'], 'sentinel': server['sentinel_name']}
        runner.cmd('state.orchestrate', ['sentinels.reset'], kwarg={'pillar': pillar})
