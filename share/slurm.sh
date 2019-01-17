#!/usr/bin/env bash

#SBATCH --job-name={{ name }}
#SBATCH --account={{ project_name }}
#SBATCH --nodes={{ node_count }}
#SBATCH --tasks-per-node={{ ppn }}
#SBATCH --time={{ walltime }}
#SBATCH --output={{ stdout }}
#SBATCH --error={{ stderr }}
#SBATCH --mem={{ mem }}

cd "{{ wd }}"

{{ command }}
