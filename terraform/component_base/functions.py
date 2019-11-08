#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component

def apply(plateform):
  ## component base
  var_base={
    'account_id': plateform['account'],
    'region': plateform['region'],
    'public_dns': plateform['public-dns']
  }
  create_component(working_dir='../terraform/component_base', plateform_name=plateform['name'], var_component=var_base)