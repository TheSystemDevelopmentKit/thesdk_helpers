#!/usr/bin/python3

import os
import sys
if not (os.path.abspath('./') in sys.path):
    sys.path.append(os.path.abspath('./'))

import pandas as pd
import argparse
import pdb
from exercise_manager import exercise_manager

# Implement argument parser
parser = argparse.ArgumentParser(description='Parse selectors')
parser.add_argument('--url', dest='url', type=str, nargs='?', const = True, 
        default=None,help='URL of the gitlab server')

parser.add_argument('--token',   dest='token', type=str, nargs='?', const=True, 
        default=None, help='Access token for gitlab server access.')

parser.add_argument('--group',   dest='group', type=str, nargs='?', const=True, 
        default=None, help='Master group for the exercise.')

parser.add_argument('--project',   dest='project', type=str, nargs='?', const=True, 
        default=None, help='Project on which the Issues are generated')

parser.add_argument('--no-ssl',   dest='ssl', type=bool, nargs='?', const=False,  
        default=True, help='Set to false to disable SSL verification.')

parser.add_argument('--users',   dest='list_of_unames', type=str, nargs='?', const=False,  
        default=None, help='List of usernames separated by space')

parser.add_argument('--due',   dest='due_date', type=str, nargs='?', const=False,  
        default=None, help='Due date in format YYYY-MM-DD')


args=parser.parse_args()
list_of_names=args.list_of_unames.split(' ')
ex=exercise_manager( url = args.url , token = args.token, group = args.group, ssl=args.ssl)
users,undefined=ex.find_users(find=list_of_names)


print('Found users')
if users:
    for user in users:
        print(user.name)
else:
    print('None, exiting.')
    sys.exit()

print('Undefined users')
if undefined:
    for user in undefined:
        print(user)
else:
    print('None')

#ex.exercise_subgroups=ex.get_user_parameters(
#        users=users,
#        field='name')
ex.assignee_ids=ex.get_user_parameters(
        users=users,
        field='id')

ex.assignees_to_subgroups()
issues=[
    './Issue-0.md', 
    './Issue-1.md',
    './Issue-2.md',
    './Issue-3.md',
    './Issue-4.md'
    ]
#Not needed for existing project
#project_template='git@bubba.ecdl.hut.fi:elec-e9540-exec/exercise_template.git',
for assignee in users:
    for issue in issues:
        ex.add_exercise( due_date=args.due_date,
                project=args.project,
                file=issue,
                project_description='Project for your exercises',
                substitution_list=[ ('<UNAME>', assignee.username)]
                        )
ex.create_exercises()


