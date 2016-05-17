set -e
# Arguments
PROJECT=$1
SOURCE_DIR=$2
BUILD_DIR=$3

CURR_DIR=$(pwd)
# Turn relative paths into absolute paths.
if [ "${SOURCE_DIR:0:1}" != "/" ]; then
  SOURCE_DIR=${CURR_DIR}/${SOURCE_DIR}
fi
if [ "${BUILD_DIR:0:1}" != "/" ]; then
  BUILD_DIR=${CURR_DIR}/${BUILD_DIR}
fi

cd $BUILD_DIR
BRANCHTIP=$(grep -r 'COMMAND .*git.*checkout ' tmp/*gitclone.cmake | sed 's/.* checkout \([0-9a-z]\{40\}\)/\1/')
echo $BRANCHTIP
SOURCEURL=$(grep -r 'COMMAND .*git.*clone ' tmp/*gitclone.cmake | sed 's/.* clone "\(.*\?\)" .*/\1/')
echo $SOURCEURL
cd $(dirname $SOURCE_DIR)
pwd
git clone --quiet "$SOURCEURL" $(basename $SOURCE_DIR)
cd $SOURCE_DIR
pwd
git checkout $BRANCHTIP

echo '---- Checking for availability of cached build directory on Bintray.'
if [[ "$CC" == *gcc* ]]; then export COMPILER=gcc; fi
if [[ "$CC" == *clang* ]]; then export COMPILER=clang; fi
PACKAGENAME="${MACHTYPE}_${COMPILER}_${BTYPE}"
# Set timestamp of all files back.
find . -name '*' | while read f; do touch -m -t"199001010101" $f; done

BUILD_DIRNAME=$(basename $BUILD_DIR)
TARBALL=${BUILD_DIRNAME}.tar.gz
LETTERS='a b c d e f g h i j k l m n o p q r s t u v w x y z'
URL="https://dl.bintray.com/opensim/${PROJECT}/${PACKAGENAME}/${BRANCHTIP}"
echo "---- Looking for opensim/${PROJECT}/${PACKAGENAME}/${BRANCHTIP}"
if [ ! -d $BUILD_DIR ]; then mkdir $BUILD_DIR; fi
cd ${BUILD_DIR}/..
for i in $LETTERS; do 
  piece=${TARBALL}a$i 
  curl -s -L $URL/$piece -o $piece
  if [ $(wc -c < $piece) -lt 100 ]; then 
    rm $piece 
    break 
  else 
    echo "---- Downloaded piece $piece"
  fi 
done
if [ ! -f ${TARBALL}aa ]; then 
  echo '---- Cache not found.'
  return
fi
echo '---- Joining the pieces downloaded.'
cat ${TARBALL}* > ${TARBALL}
echo '---- Decompressing tarball.'
tar -xzf ${TARBALL}
echo '---- Cleaning up.'
rm -f ${TARBALL}*
cd $CURR_DIR
