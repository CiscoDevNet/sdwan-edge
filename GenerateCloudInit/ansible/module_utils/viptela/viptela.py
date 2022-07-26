"""
Copyright (c) 2022 Cisco Systems, Inc. and its affiliates
All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

import json
import requests
import re
import sys
import time
from ansible.module_utils.basic import AnsibleModule, json, env_fallback
from collections import OrderedDict

try:
    from json.decoder import JSONDecodeError
except ImportError:
    JSONDecodeError = ValueError

def viptela_argument_spec():
    return dict(host=dict(type='str', required=True, fallback=(env_fallback, ['VMANAGE_HOST'])),
                port=dict(type='str', required=False, fallback=(env_fallback, ['VMANAGE_PORT'])),
                user=dict(type='str', required=True, fallback=(env_fallback, ['VMANAGE_USERNAME'])),
                password=dict(type='str', required=True, fallback=(env_fallback, ['VMANAGE_PASSWORD'])),
                validate_certs=dict(type='bool', required=False, default=False),
                timeout=dict(type='int', default=30)
                )


STANDARD_HTTP_TIMEOUT = 10
STANDARD_JSON_HEADER = {'Connection': 'keep-alive', 'Content-Type': 'application/json'}
POLICY_LIST_DICT = {
    'siteLists': 'site',
    'vpnLists': 'vpn',
}
VALID_STATUS_CODES = [200, 201, 202, 203, 204, 205, 206, 207, 208, 226]


class viptelaModule(object):

    def __init__(self, module, function=None):
        self.module = module
        self.params = module.params
        self.result = dict(changed=False)
        self.headers = dict()
        self.function = function
        self.cookies = None
        self.json = None

        self.method = None
        self.path = None
        self.response = None
        self.status = None
        self.url = None
        self.params['force_basic_auth'] = True
        self.user = self.params['user']
        self.password = self.params['password']
        self.host = self.params['host']
        self.timeout = self.params['timeout']
        self.modifiable_methods = ['POST', 'PUT', 'DELETE']

        self.session = requests.Session()
        self.session.verify = self.params['validate_certs']

        self.login()

    # Deleting (Calling destructor)
    # def __del__(self):
    #     self.logout()

    def _fallback(self, value, fallback):
        if value is None:
            return fallback
        return value

    def list_to_dict(self, list, key_name, remove_key=True):
        dict_value = OrderedDict()
        for item in list:
            if key_name in item:
                if remove_key:
                    key = item.pop(key_name)
                else:
                    key = item[key_name]

                dict_value[key] = item
            # else:
            #     self.fail_json(msg="key {0} not found in dictionary".format(key_name))

        return dict_value

    @staticmethod
    def compare_payloads(new_payload, old_payload, compare_values=None):
        if compare_values is None:
            compare_values = []
        payload_key_diff = []
        for key, value in new_payload.items():
            if key in compare_values:
                if key not in old_payload or new_payload[key] != old_payload[key]:
                    payload_key_diff.append(key)
        return payload_key_diff

    def login(self):
        # self.session.headers.update({'Connection': 'keep-alive', 'Content-Type': 'application/json'})

        try:
            response = self.session.post(
                url='https://{0}/j_security_check'.format(self.host),
                headers={'Content-Type': 'application/x-www-form-urlencoded'},
                data={'j_username': self.user, 'j_password': self.password},
                timeout=self.timeout
            )
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            self.module.fail_json(msg=e)

        if response.text.startswith('<html>'):
            self.fail_json(msg='Could not login to device, check user credentials.', **self.result)

        response = self.session.get(
            url='https://{0}/dataservice/client/token'.format(self.host),
            timeout=self.timeout
        )
        if response.status_code == 200:
            self.session.headers['X-XSRF-TOKEN'] = response.content
        elif response.status_code == 404:
            # Assume this is pre-19.2
            pass
        else:
            self.fail_json(msg='Failed getting X-XSRF-TOKEN: {0}'.format(response.status_code))

        return response

    def logout(self):
        self.request('/dataservice/settings/clientSessionTimeout')
        self.request('/logout')

    def request(self, url_path, method='GET', data=None, files=None, headers=None, payload=None, status_codes=None):
        """Generic HTTP method for viptela requests."""

        if status_codes is None:
            status_codes = VALID_STATUS_CODES
        self.method = method
        self.url = 'https://{0}{1}'.format(self.host, url_path)
        self.result['url'] = self.url
        self.result['headers'] = self.session.headers.__dict__
        if files is None:
            self.session.headers['Content-Type'] = 'application/json'

        if payload:
            self.result['payload'] = payload
            data = json.dumps(payload)
            self.result['data'] = data

        response = self.session.request(method, self.url, files=files, data=data)

        self.status_code = response.status_code
        self.status = requests.status_codes._codes[response.status_code][0]
        decoded_response = {}
        if self.status_code not in status_codes:
            try:
                decoded_response = response.json()
            except JSONDecodeError:
                pass

            if 'error' in decoded_response:
                error = 'Unknown'
                details = 'Unknown'
                if 'details' in decoded_response['error']:
                    details = decoded_response['error']['details']
                if 'message' in decoded_response['error']:
                    error = decoded_response['error']['message']
                self.fail_json(msg='{0}: {1}'.format(error, details))
            else:
                self.fail_json(msg=self.status)

        try:
            response.json = response.json()
        except JSONDecodeError:
            response.json = {}

        return response

    def get_vmanage_org(self):
        response = self.request('/dataservice/settings/configuration/organization')
        try:
            return response.json['data'][0]['org']
        except:
            return None

    def set_vmanage_org(self, org):
        payload = {'org': org}
        response = self.request('/dataservice/settings/configuration/organization', method='POST', payload=payload)

        return response.json['data']

    def get_vmanage_vbond(self):
        response = self.request('/dataservice/settings/configuration/device')
        try:
            return {'vbond': response.json['data'][0]['domainIp'], 'vbond_port': response.json['data'][0]['port']}
        except:
            return {'vbond': None, 'vbond_port': None}

    def set_vmanage_vbond(self, vbond, vbond_port='12346'):
        payload = {'domainIp': vbond, 'port': vbond_port}
        self.request('/dataservice/settings/configuration/device', method='POST', payload=payload)
        return

    def get_vmanage_ca_type(self):
        response = self.request('/dataservice/settings/configuration/certificate')
        try:
            return response.json['data'][0]['certificateSigning']
        except:
            return None

    def set_vmanage_ca_type(self, type):
        payload = {'certificateSigning': type, 'challengeAvailable': 'false'}
        self.request('/dataservice/settings/configuration/certificate', method='POST', payload=payload)
        return

    def get_vmanage_root_cert(self):
        response = self.request('/dataservice/certificate/rootcertificate')
        try:
            return response.json['rootcertificate']
        except:
            return None

    def set_vmanage_root_cert(self, cert):
        payload = {'enterpriseRootCA': cert}
        self.request('/dataservice/settings/configuration/certificate/enterpriserootca', method='PUT', payload=payload)
        return

    def get_unused_device(self, model):
        response = self.request('/dataservice/system/device/vedges?model={0}&state=tokengenerated'.format(model))

        if response.json:
            try:
                return response.json['data'][0]
            except:
                return response.json['data']
        else:
            return {}


    def get_device_by_state(self, state, type='vedges'):
        response = self.request('/dataservice/system/device/{0}?state={1}'.format(type, state))

        if response.json:
            try:
                return response.json['data'][0]
            except:
                return response.json['data']
        else:
            return {}

    def get_device_by_uuid(self, uuid, type='vedges'):
        response = self.request('/dataservice/system/device/{0}?uuid={1}'.format(type, uuid))

        if response.json:
            try:
                return response.json['data'][0]
            except:
                return response.json['data']
        else:
            return {}

    def get_device_by_device_ip(self, device_ip, type='vedges'):
        response = self.request('/dataservice/system/device/{0}?deviceIP={1}'.format(type, device_ip))

        if response.json:
            try:
                return response.json['data'][0]
            except:
                return response.json['data']
        else:
            return {}

    def get_device_by_name(self, name, type='vedges'):
        device_dict = self.get_device_dict(type)

        try:
            return device_dict[name]
        except:
            return {}

    def get_device_list(self, type, key_name='host-name', remove_key=True):
        response = self.request('/dataservice/system/device/{0}'.format(type))

        if response.json:
            return response.json['data']
        else:
            return []

    def get_device_dict(self, type, key_name='host-name', remove_key=False):

        device_list = self.get_device_list(type)

        return self.list_to_dict(device_list, key_name=key_name, remove_key=remove_key)

    def get_device_status_list(self):
        response = self.request('/dataservice/device')

        if response.json:
            return response.json['data']
        else:
            return []

    def get_device_status_dict(self, key_name='host-name', remove_key=False):

        device_list = self.get_device_list()

        return self.list_to_dict(device_list, key_name=key_name, remove_key=remove_key)

    def get_device_vedges(self, key_name='host-name', remove_key=True):
        response = self.request('/dataservice/system/device/vedges')

        if response.json:
            return self.list_to_dict(response.json['data'], key_name=key_name, remove_key=remove_key)
        else:
            return {}

    def decommision_device(self, uuid):
        response = self.request('/dataservice/system/device/decommission/{0}'.format(uuid), method='PUT')

        return response

    def generate_bootstrap(self, uuid, inclDefRootCert=True):
        response = self.request('/dataservice/system/device/bootstrap/device/{0}?configtype=cloudinit&inclDefRootCert={1}'.format(uuid, inclDefRootCert))

        try:
            bootstrap_config = response.json['bootstrapConfig']
        except:
            return None

        regex_otp = re.compile(r'otp : (?P<otp>[a-z0-9]+)[^a-z0-9]')
        match_otp = regex_otp.search(bootstrap_config)
        if match_otp:
            otp = match_otp.groups('otp')[0]
        else:
            otp = None

#        regex_vbond = re.compile(r'vbond : (?P<vbond>.*)')
#        match_vbond = regex_vbond.search(bootstrap_config)
#        if match_vbond:
#            vbond = match_vbond.groups('vbond')[0]
#        else:
#            vbond = None

#        regex_org = re.compile(r'org : (?P<org>.*)')
#        match_org = regex_org.search(bootstrap_config)
#        if match_org:
#            org = match_org.groups('org')[0]
#        else:
#            org = None

        return_dict = {
            'bootstrapConfig': bootstrap_config,
            'otp': otp,
            'uuid': uuid
        }
        return return_dict


    def waitfor_action_completion(self, action_id):
        status = 'in_progress'
        response = {}
        while status == "in_progress":
            response = self.request('/dataservice/device/action/status/{0}'.format(action_id))
            if response.json:
                status = response.json['summary']['status']
                if 'data' in response.json and response.json['data']:
                    action_status = response.json['data'][0]['statusId']
                    action_activity = response.json['data'][0]['activity']
                    if 'actionConfig' in response.json['data'][0]:
                        action_config = response.json['data'][0]['actionConfig']
                    else:
                        action_config = None
            else:
                self.fail_json(msg="Unable to get action status: No response")
            time.sleep(10)

        # self.result['action_response'] = response.json
        self.result['action_id'] = action_id
        self.result['action_status'] = action_status
        self.result['action_activity'] = action_activity
        self.result['action_config'] = action_config
        if self.result['action_status'] == 'failure':
            self.fail_json(msg="Action failed")
        return response

    def exit_json(self, **kwargs):
        # self.logout()
        """Custom written method to exit from module."""

        self.result.update(**kwargs)
        self.module.exit_json(**self.result)

    def fail_json(self, msg, **kwargs):
        # self.logout()
        """Custom written method to return info on failure."""

        self.result.update(**kwargs)
        self.module.fail_json(msg=msg, **self.result)
