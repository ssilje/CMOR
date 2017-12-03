#!/bin/bash -l
#SBATCH --account=pr04
#SBATCH --nodes=1
#SBATCH --partition=xfer
#SBATCH --time=4:00:00
#SBATCH --output=logs/xfer_%j.out
#SBATCH --error=logs/xfer_%j.err
#SBATCH --job-name="xfer_sh"

args=""
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
      -g|--gcm)
      GCM=$2
      args="${args} -g $2"
      shift
      ;;
      -x|--exp)
      EXP=$2
      args="${args} -x $2"
      shift
      ;;
      -s|--start)
      startyear=$2
      shift
      ;;
      -e|--end)
      endyear=$2
      args="${args} -e $2"
      shift
      ;;
      -o|--out)
      OUTDIR=$2
      args="${args} -o $2"
      shift
      ;;
      -a|--arch)
      ARCHDIR=$2
      args="${args} -a $2"
      shift
      ;;
      -l|--log)
      xfer=$2
      args="${args} -x $2"
      shift
      ;;
      -S|--src)
      SRCDIR=$2
      args="${args} -S $2"
      shift
      ;;
      *)
      echo "unknown option!"
      ;;
  esac
  shift
done

if [[ -z $startyear || -z $endyear || -z $OUTDIR || -z $ARCHDIR || -z $xfer || -z $SRCDIR ]]
then
  echo "Please provide all necessary arguments! Exiting..."
  exit
fi

if [ ! -d ${OUTDIR} ]
then
  mkdir -p ${OUTDIR}
fi

#skip already extracted years
(( NEXT_YEAR=startyear + 1 ))
while [ -d ${OUTDIR}/*${NEXT_YEAR} ] && [ ${NEXT_YEAR} -le ${endyear} ]
do
  echo "Input files for year ${NEXT_YEAR} have already been extracted. Skipping..."
  (( NEXT_YEAR=NEXT_YEAR + 1 ))
done


if [ ${NEXT_YEAR} -le ${endyear} ]
then
  sbatch  --job-name=CMOR_sh --error=${xfer}.${NEXT_YEAR}.err --output=${xfer}.${NEXT_YEAR}.out ${SRCDIR}/xfer.sh -s ${NEXT_YEAR} ${args}
fi


if [ ! -d ${OUTDIR}/*${startyear} ]
then
  if [ -d ${ARCHDIR}/*${startyear} ] 
  then
    echo "Moving input directory for year ${startyear} to ${OUTDIR} "
    mv ${ARCHDIR}/*${startyear} ${OUTDIR}
  elif [ -f ${ARCHDIR}/*${startyear}.tar ]
  then
    echo "Extracting archive for year ${startyear} to ${OUTDIR}"
    tar -xf ${ARCHDIR}/*${startyear}.tar -C ${OUTDIR}
  else
    echo "Cannot find .tar file or extracted archive for year ${startyear} in archive directory ${ARCHDIR}! Skipping year..."
    exit 1
  fi
  #remove model input folder
  if [ -d ${OUTDIR}/${startyear}/input ]
  then
    rm -r ${OUTDIR}/${startyear}/input
  fi
else
  echo "Input files for year ${startyear} are already at ${OUTDIR}. Skipping..."
fi


