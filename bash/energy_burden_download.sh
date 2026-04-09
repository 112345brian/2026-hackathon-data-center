#!/bin/bash

mkdir -p ../data/raw/energy_burden/zips
mkdir -p ../data/raw/energy_burden/counties

# Download all state LEAD data zips
for state in AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY; do
  curl -o "../data/raw/energy_burden/zips/${state}-2022-LEAD-data.zip" "https://data.openei.org/files/6219/${state}-2022-LEAD-data.zip"
done

# Extract only AMI and FPL county-level files from each zip
for f in ../data/raw/energy_burden/zips/*.zip; do
  unzip -j "$f" "*AMI*Counties*" "*FPL*Counties*" -d ../data/raw/energy_burden/counties
done