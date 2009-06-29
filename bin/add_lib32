#!/bin/bash
cd /var/db/pkg
for i in */*/IUSE; do grep lib32 $i>/dev/null || echo $(cat $i) lib32 > $i ; done
for i in */*; do ! [[ -e $i/IUSE ]] && echo lib32 > $i/IUSE ; done
touch */*
