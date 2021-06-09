from eai.shuriken.client.client import ShurikenClient
from eai.shuriken.common.exceptions import ShurikenRuntimeError

def train(switch_at, other_param=1):
    print(switch_at, other_param)

def main():
    try:
        client = ShurikenClient()
        parameters = client.get_parameters()
    except ShurikenRuntimeError:
        client = None
        parameters = {'switch_at': 'missing'}
    train(**parameters)
