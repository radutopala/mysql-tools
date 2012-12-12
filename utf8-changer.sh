#!/bin/bash

MUSER=$1
MPASS=$2
MHOST=$3
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"

DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
NODUMP=("information_schema" "performance_schema" "mysql")

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

for db in $DBS
do

        if [ $(contains "${NODUMP[@]}" "$db") != "y" ]; then

                echo Database $db

                DUMP=/tmp/${db}_dump.sql
                DUMPF=/tmp/${db}_dump_fixed.sql

                $MYSQLDUMP -u$MUSER -p$MPASS -c -e --default-character-set=utf8 --single-transaction --skip-set-charset --add-drop-database -B $db > $DUMP
                sed 's/DEFAULT CHARACTER SET latin1/DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci/' < $DUMP | sed 's/DEFAULT CHARSET=latin1/DEFAULT CHARSET=utf8/' > $DUMPF
                $MYSQL -u$MUSER -p$MPASS < $DUMPF
        fi

done