#!/bin/bash
# file HP41edidebug.sh
# script for starting 2 windows: emacs and cc41 in parallel for HP41 programm development
# in a terminal, start with.. sh /home/pascal/programming/hp41/HP41edidebug.sh ELPER.hp41
# ELPER from https://github.com/f4iteightiz/ellipse_iso_perimeter/blob/main/ELPER.TXT
#
# version 
# 03 11 2026 upload github
# 
echo "HP 41 editor and debug terminal start"
echo "start emacs NEW"
# hp41-mode-new.el from https://github.com/f4iteightiz/HP41_corner/blob/main/hp41-mode.el
emacs -q --load '/home/pascal/programming/hp41/EMACS/hp41-mode-new.el' /home/pascal/programming/hp41/$1 --eval "(view-files-in-windows)" &
wait 5
echo "start cc41"
# cc41 from https://github.com/CraigBladow/cc41
# make sure you have the latest available version
# exec ./programming/hp41/CC41/cc41 -L /home/pascal/programming/hp41/$1
# exec /home/pascal/programming/hp41/CC41/cc41 -L /home/pascal/programming/hp41/$1
# -S will skip the announcement text
# rlwrap will keep the command history
# if you updated the $1 file, use the command dejavu in cc41: it will reload the file
rlwrap /home/pascal/programming/hp41/CC41/cc41 -S -L /home/pascal/programming/hp41/$1
echo "Ende"
