#!/bin/bash 
#RESCALE_NAME="Auto Build from Singularity Definition File" 
#RESCALE_ANALYSIS=user_included_singularity_container
#RESCALE_ANALYSIS_VERSION=3.8.0
#RESCALE_CORE_TYPE=Emerald 
#RESCALE_CORES=1
#RESCALE_WALLTIME=1 
#RESCALE_EXISTING_FILES=jRjiDm
#RESCALE_LOW_PRIORITY=true
singularity build --fakeroot actran_build_$(date +'%Y%m%d').sif hexagon_software-4.def
