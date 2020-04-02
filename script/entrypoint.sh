#!/bin/bash

if [ ! -z "$1" ]
then
    echo "====> Installing Extension...'$1'"
    php exakat.phar extension install $1
    echo "project_themes[] = '$1';" >> /usr/src/exakat/config/exakat.ini
fi

echo "====> Display Config"
php exakat.phar doctor
echo "====> Init Project..."
php exakat.phar init -p myScan -R /src
echo "====> Running scan on Target..." 
php exakat.phar project -p myScan -v

if [ ! -z "$1" ]
then
    echo "====> Generating Report..."
    php exakat.phar analyze -p myScan -T $1
    php exakat.phar dump -p myScan -T $1 -u
    php exakat.phar report -p myScan -T $1 -format Text -file Ext_${1}_report
    echo "====> Sending Extension Report to Mount Point..."
    cp -r projects/myScan/Ext_${1}_report.txt /report/
fi

echo "====> Sending Exakat Report to Mount Point..."
cp -r projects/myScan/report /report/
