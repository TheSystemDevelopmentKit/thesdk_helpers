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

parser.add_argument('--no-ssl',   dest='ssl', type=bool, nargs='?', const=False,  
        default=True, help='Set to false to disable SSL verification.')

#file = '../Grading/Grading_ELEC-E9540-2023.csv'
#fid = open(file,'r')
#studentdb = pd.read_csv(fid,dtype=object,sep=',',header=None)
#firstnames = studentdb.values[1:,0]   
#lastnames = studentdb.values[1:,1]   
#list_of_names = list(map(lambda f,l: '%s %s'%(f,l), firstnames,lastnames))
list_of_names=[]
list_of_names.append('Marko Kosunen')
#Start costructing exercise
args=parser.parse_args()

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

#Not needed for existing project
#project_template='git@bubba.ecdl.hut.fi:elec-e9540-exec/exercise_template.git',
for assignee in users:
    ex.add_exercise( due_date='2023-04-02',
            project='Exercise_project',
            file='./Issue-0.md',
            project_description='Project for your exercises',
            substitution_list=[ ('<UNAME>', assignee.username)]
                    )
    ex.add_exercise( due_date='2023-04-02',
            project='Exercise_project',
            file='./Issue-3.md',
            project_description='Project for your exercises',
            substitution_list=[ ('<UNAME>', assignee.username)]
                    )
    ex.add_exercise( due_date='2023-04-02',
            project='Exercise_project',
            file='./Issue-1.md',
            project_description='Project for your exercises',
            substitution_list=[ ('<UNAME>', assignee.username)]
                    )
    ex.add_exercise( due_date='2023-04-02',
            project='Exercise_project',
            file='./Issue-2.md',
            project_description='Project for your exercises',
            substitution_list=[ ('<UNAME>', assignee.username)]
                    )
    ex.add_exercise( due_date='2023-04-02',
            project='Exercise_project',
            file='./Issue-3.md',
            project_description='Project for your exercises',
            substitution_list=[ ('<UNAME>', assignee.username)]
                    )
    ex.add_exercise( due_date='2023-04-02',
            project='Exercise_project',
            file='./Issue-4.md',
            project_description='Project for your exercises',
            substitution_list=[ ('<UNAME>', assignee.username)]
                    )
ex.create_exercises()


