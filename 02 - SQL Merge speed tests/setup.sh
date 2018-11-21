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

echo "Please elevate to sudo to guarantee permissions to install the database."
sudo $MYSQL_BIN < ./test_db/employees.sql
echo "Database installed."
