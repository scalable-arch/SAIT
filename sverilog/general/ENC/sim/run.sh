#!/bin/bash

source ../common.sh

function print_help() {
  echo "Usage: run [command]"
  echo "  command options :"
  echo "    compile   : Compile the RTL codes using the VCS."
  echo "    tb        : Run the compiled testbench."
  echo "    verdi     : Run the Verdi, interactive debugger."
  echo ""
  echo "    clean     : Clean the output directory."

  exit 1
}

export ROOT_DIR="$SAIT_CRC_HOME/../"
FILELIST_TB="$ROOT_DIR/sim/tb/filelist.f"
FILELIST_RTL="$ROOT_DIR/rtl/filelist.f"

if [[ $1 == "clean" ]]; then
  echo "Cleaning up the old directory"
  rm -rf $RUN_DIR
  exit 0
elif [[ $1 == "compile" ]]; then
  mkdir -p $RUN_DIR
  cd $RUN_DIR
  echo "Compiling"
  $COMPILE_CMD $COMPILE_OPTIONS -f $FILELIST_TB -f $FILELIST_RTL
elif [[ $1 == "tb" ]]; then
  if [ -e $RUN_DIR/simv ]; then
    cd $RUN_DIR
    ./simv
  else
    echo "Binary file does not exist"
    exit 1
  fi
elif [[ $1 == "verdi" ]]; then
  if [ -e $RUN_DIR/simv ]; then
    cd $RUN_DIR
    $VERDI_CMD $VERDI_OPTIONS -f $FILELIST_TB -f $FILELIST_RTL -i simv &
  else
    echo "Binary file does not exist"
    exit 1
  fi
else
  print_help
fi
