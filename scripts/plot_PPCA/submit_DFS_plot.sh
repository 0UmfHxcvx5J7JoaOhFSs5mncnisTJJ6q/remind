#!/bin/bash

#SBATCH --qos=priority
#SBATCH --job-name=PPCA_DFS_bubble_plot_all
#SBATCH --account=rdev
#SBATCH --output=%x-%j.out
#SBATCH --workdir=/p/tmp/stephenb/REMIND_3p0_dev/remind/scripts/plot_PPCA/plots/

Rscript /p/tmp/stephenb/REMIND_3p0_dev/remind/scripts/plot_PPCA/plot_DFS_script_FinEx.R
