#!/bin/bash

gui_enable=0

function run_test {
    make
    if [ $gui_enable == 1 ]; then
        vsim -novopt -L unisims_ver  work.test -do "do wave.do";
    else
        vsim -L unisims_ver -c work.test -do "run -a";
    fi
}

run_test
