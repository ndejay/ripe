#!/usr/bin/env bash

#PBS -N {{ name }}
#PBS -A {{ project_name }}
#PBS -q {{ queue }}
#PBS -l nodes={{ node_count }}:ppn={{ ppn }}
#PBS -l walltime={{ walltime }}
#PBS -o {{ stdout }}
#PBS -e {{ stderr }}
#PBS -V

cd "{{ wd }}"

{{ command }}
