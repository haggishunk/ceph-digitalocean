import os
import sys
import json

def constrTfstatePath():
    cwd = os.getcwd()
    tfname = 'terraform.tfstate'
    tfstate_path = os.path.join(cwd, tfname)
    return tfstate_path

def constrConfigPath():
    path_config_rel = r'.ssh/config'
    path_user_home = os.path.expanduser('~')
    path_config_abs = os.path.join(path_user_home, path_config_rel)
    return path_config_abs

def iterNodes(tfstate_file):
    with open(tfstate_file, 'r') as file:
        tfstate = json.loads(file.read())
        for node in tfstate['modules'][0]['resources'].values():
            node_name = node['primary']['attributes']['name']
            node_host = node['primary']['attributes']['ipv4_address']
            node_dict = {'name': node_name, 'host': node_host}
            yield node_dict

def genEntryText(node):
    text = "\nHost {0}\n    HostName {1}\n    User {2}\n".format(node['name'], node['host'], user)
    return text

def appendConfig(user):
    with open(constrConfigPath(), 'a') as conf_file:
        for node in iterNodes(constrTfstatePath()):
            entry = genEntryText(node)
            print('Adding host entry: <{0}>'.format(entry))
            conf_file.write(entry)
        conf_file.flush()
    return

if __name__ == '__main__':
    try:
        user = sys.argv[1]
    except:
        user = 'user'
    appendConfig(user)
