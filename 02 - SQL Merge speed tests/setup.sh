#!/bin/bash

# variables defining paths to binaries and files

MYSQL_BIN=/usr/bin/mysql

if [ ! -x $MYSQL_BIN ]; then
  echo "ERROR: MySQL is not installed (or not in the usual place). Install it and run this again."
  exit 1
fi

echo "Fetching employees sample database"
git clone https://github.com/datacharmer/test_db.git
echo "Done."

read -p "Please enter the username for the MySQL database now: " db_un
$MYSQL_BIN -u $DB_UN -p < ./test_db/employees.sql
