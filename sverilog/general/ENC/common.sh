#!/bin/bash

RUN_DIR=output

COMPILE_CMD='vcs'
COMPILE_OPTIONS='-full64 -debug_access+all -kdb -LDFLAGS -Wl,--no-as-needed'

SIM_OPTIONS=''

VERDI_CMD='Verdi'
VERDI_OPTIONS=''

DC_CMD='dc_shell-xg-t'
DC_OPTIONS=''

SAIT_CRC_HOME=$(pwd)