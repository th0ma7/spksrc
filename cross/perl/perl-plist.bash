#!/bin/bash

#ARCH=$(echo $1 | sed -e 's/arch/work/g')
ARCH=$1
INSTALL_DIR=$(echo $1 | sed -e 's/arch/work/g')-*/install/var/packages/target
PLIST=$PWD/PLIST

if [ ! "$ARCH" ]; then
   echo "Requires architecture parameter such as: arch-apollolake"
   exit 1
fi

# Backup previous PLIST
[ -f $PLIST ] && cp -p $PLIST $PLIST.`date +%Y%m%d-%H%M`

echo "ARCH: $ARCH"
echo "INSTALL_DIR: $INSTALL_DIR"
echo "PLIST: $PLIST"

# Generate PLIST
GenerateList() {
   find $1 -type f | while read FILE
   do
      [ "`file $FILE | grep ELF`" ] \
         && echo "$1:$FILE" \
         || echo "rsc:$FILE"
   done
}

# Loop through various directories to generate PLIST
> $PLIST
cd $INSTALL_DIR
#for DIR in bin lib share
for DIR in bin lib include
do
   echo "Generate PLIST for $DIR ..."
   GenerateList $DIR   >> $PLIST
done

echo "Generate PLIST for share ..."
ls -1d share/* | while read DIR
do
   echo "shr:$DIR"     >> $PLIST
done

# Sort end-result file
echo "Sort PLIST"
sort -t: -k 2 $PLIST -o $PLIST

exit 0
