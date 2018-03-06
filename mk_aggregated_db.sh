#!/bin/bash

MEMBERS_DB=$HOME/Documents/www/cp-dataviz/cpdb_randomized.sqlite3
AGGREGATED_DB=$HOME/Documents/www/cp-dataviz/cpdb_randomized_aggregated.sqlite3

cp $MEMBERS_DB $AGGREGATED_DB

#Obtain absolute path by entering the directory of this script
cd "$(dirname "$0")"
SCRIPT_DIR=`pwd`

sqlite3 $AGGREGATED_DB < $SCRIPT_DIR/mk_aggregated_tables.sql 
