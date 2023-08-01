#!/bin/bash
a=$1
if [[ "$a" =~ ^i-.* ]];
then
echo $2
fi