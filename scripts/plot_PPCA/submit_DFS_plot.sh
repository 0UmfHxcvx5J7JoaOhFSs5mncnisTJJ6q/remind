#!/bin/bash

#SBATCH --qos=short
#SBATCH --job-name=PPCA_DFS_bubble_plot_all
#SBATCH --account=stephenb@login02
#SBATCH --output=%x-%j.out
#SBATCH --workdir=/p/tmp/stephenb/FINAL_PPCA_paper_branch/plots/

/p/tmp/stephenb/FINAL_PPCA_paper_branch/plots/plot_DFS_script.R
