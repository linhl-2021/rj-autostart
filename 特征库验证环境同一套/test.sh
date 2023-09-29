#!/bin/bash
bash update1.sh $1 $2 $3 $4
python main.py $1 $2 $3 $4
bash update2.sh $1 $2 $3 $4
