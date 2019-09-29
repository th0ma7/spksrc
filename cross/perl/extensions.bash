#!/bin/bash

BASE_URL="http://www.cpan.org/authors/id/"
PKG_DIR=${PKG_DIR}
WORK_DIR=${PKG_DIR}/../
CPAN_DIR=${PKG_DIR}/cpan

EXTRAS_MODULES="Bundle::CPAN JSON LWP LWP::Protocol::https"
EXTRAS_MODULES+=" Dist::CheckConflicts Module::Build PerlIO::gzip Sub::Install Sub::Name Term::ProgressBar Unicode::String"
EXTRAS_MODULES+=" Module::Build Log::Dispatch Log::Log4perl"
EXTRAS_MODULES+=" Test::LeakTrace Test::Perl::Critic Test::Pod Test::Pod::Coverage"
EXTRAS_MODULES+=" File::Find::Rule File::Slurp"
EXTRAS_MODULES+=" Tie::Hash::NamedCapture XML::TreePP XML::Twig XML::Writer"

# Populate cpan module blacklist
BLACKLIST_MODULES="Alien-Libxml2 Module::Build JSON Test::LeakTrace XML::LibXML"
BLACKLIST=`mktemp -p ${WORK_DIR}`
for ITEM in $BLACKLIST_MODULES; do echo $ITEM >> $BLACKLIST; done

EXTRAS=`mktemp -p ${WORK_DIR}`
EXTRAS_URL=`mktemp -p ${WORK_DIR}`
EXTRAS_TAR=`mktemp -p ${WORK_DIR}`

# DEBUG
#echo "PKG_DIR: "$PKG_DIR
#echo "CPAN_DIR: "$CPAN_DIR
#echo "WORK_DIR: "$WORK_DIR


CreateDepList() {
   maxlvl=5
   deplvl=$1
   package=$2

   # Check $package variable
   [ ! "$package" ] && return

   # Check for blacklist
   [ `grep "^${package}$" $BLACKLIST` ] && return

   # Check if package is already listed
   [ `grep "^${package}$" $EXTRAS` ] && return

   # Add package to the list
   echo $package >> $EXTRAS

   if [ $deplvl -le $maxlvl ]; then
      cpanm --showdeps $1 2>/dev/null | sed -e '1,/^Configuring.*OK$/ d' | cut -f1 -d"~" | grep -v "perl" | while read deps
      do
         # DEBUG
         echo "CreateDepList ((deplvl++)) $deps"
         CreateDepList $((deplvl++)) $deps
      done
   fi
}


GetPackageURL() {
   package=`cpanm --info $1`
   url="$BASE_URL${package:0:1}/${package:0:2}/$package"

   if [[ ! $url == *"/perl-"* ]]; then
      printf '%-35s| %s\n' $1 $url
      echo $url >> $EXTRAS_URL
   fi
}

# Create dependency list
for PACKAGE in $EXTRAS_MODULES; do CreateDepList 0 $PACKAGE; done
# Sort the list
sort -u -o $EXTRAS $EXTRAS

# Get URL for all packages
cat $EXTRAS | while read LINE; do GetPackageURL $LINE; done
sort -u -o $EXTRAS_URL $EXTRAS_URL

# Download all files
cat $EXTRAS_URL | while read URL; do wget -q -nc $URL -P $WORK_DIR; done

# Extract all files
#cat $EXTRAS_URL | while read URL; do tar -xvf ${WORK_DIR}/$(basename $URL) -C $CPAN_DIR; done
cat $EXTRAS_URL | while read URL; do
   TAR_FILE=${WORK_DIR}/$(basename $URL)
   DEST_DIR=${CPAN_DIR}/$(basename $URL|sed -e 's/-[0-9].*\.[0-9].*$//g')
   echo "tar -xvf ${TAR_FILE} -C $DEST_DIR --strip 1" >> $EXTRAS_TAR

   # Only extract if directory does not exist
   if [ ! -d $DEST_DIR ]; then
      mkdir $DEST_DIR
      tar -xvf ${TAR_FILE} -C ${DEST_DIR} --strip 1
   fi
done

# FIX to auto-complete XML-Twig
sed -i '/^my $opt=/s/=.*/="-y";/' ${CPAN_DIR}/XML-Twig/Makefile.PL 2>/dev/null

# Create extras.lst for processing
echo "Creating extras.lst for later processing..."
tr '\n' ' ' < $EXTRAS > $PKG_DIR/extras.lst

# Remove temporary files
#rm -f $EXTRAS $EXTRAS_URL $EXTRAS_TAR
