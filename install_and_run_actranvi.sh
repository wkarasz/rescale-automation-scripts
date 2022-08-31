export LC_ALL=C
export ACTRAN_SRC=~/work/shared/linux-libc217-x86-64_Actran_2022.run
export ACTRAN_PATH=~/work/shared/actran
mkdir ~/work/shared/actran && sh $ACTRAN_SRC --nox11 confirm=no addqa=yes
xhost +
PATH=$PATH:$ACTRAN_PATH/Actran_2022/bin
actranvi --gpus=$RESCALE_GPUS_PER_NODE
