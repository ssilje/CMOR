#!/bin/bash -l
#SBATCH --account=pr04
#SBATCH --nodes=1
#SBATCH --partition=xfer
#SBATCH --time=4:00:00
#SBATCH --output=/scratch/snx1600/mgoebel/CMOR/logs/shell/delete_%j.out
#SBATCH --error=/scratch/snx1600/mgoebel/CMOR/logs/shell/delete_%j.err
#SBATCH --job-name="delete"


while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
      -g|--gcm)
      GCM=$2
      shift
      ;;
      -x|--exp)
      EXP=$2
      shift
      ;;
      -s|--start)
      startyear=$2
      shift
      ;;
      -e|--end)
      endyear=$2
      shift
      ;;
      -I|--input)
      INPDIR=$2
      shift
      ;;
      *)
      echo "unknown option!"
      ;;
  esac
  shift
done

while [ ${startyear} -le ${endyear} ]
do
  echo "Deleting ${INPDIR}/${startyear}" #/input
  rm -r  ${INPDIR}/${startyear} #/input
  (( startyear=startyear+1 ))
done

