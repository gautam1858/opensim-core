set -e
# Arguments
PROJECT=$1
SOURCE_DIR=$2
BUILD_DIR=$3


CURR_DIR=$(pwd)
cd $SOURCE_DIR
# Make sure the branch is master.
CURRBRANCH=$(git branch | grep '*' | sed 's/^* //')
if [ "$CURRBRANCH" != "master" ]; then 
  echo '---- Not caching build directory. Current branch is not master.'
  cd $CURR_DIR
  return
fi

MASTERTIP=$(git log -n1 --format="%H")
cd ${BUILD_DIR}/..
echo '---- Compressing build directory into a tarball.'
BUILD_DIRNAME=$(basename $BUILD_DIR)
TARBALL=${BUILD_DIRNAME}.tar.gz
tar -czf $TARBALL $BUILD_DIRNAME
echo '---- Splitting tarball into smaller pieces for upload.'
split -b 200m $TARBALL $TARBALL
rm $TARBALL
if  [[ "$CC" == *gcc* ]]; then export COMPILER=gcc; fi
if  [[ "$CC" == *clang* ]]; then export COMPILER=clang; fi
PACKAGENAME="${MACHTYPE}_${COMPILER}_${BTYPE}"
URL="https://api.bintray.com/content/opensim/${PROJECT}/${PACKAGENAME}/${MASTERTIP}/${PACKAGENAME}/${MASTERTIP}"
PIECES=$(ls ${TARBALL}a*)
for piece in PIECES; do 
  echo "---- Uploading piece ${piece} to opensim/${PROJECT}/${PACKAGENAME}/${MASTERTIP}"
  curl -T $piece -uklshrinidhi:440061321dba00a68210b482261154ea58d03f00 ${URL}/${piece} 
done
URL="https://api.bintray.com/content/opensim/${PROJECT}/${PACKAGENAME}/${MASTERTIP}/publish"
echo '---- Publishing uploaded build directory.'
curl -X POST -uklshrinidhi:440061321dba00a68210b482261154ea58d03f00 $URL
echo '---- Cleaning up.'
rm ${TARBALL}*
cd $CURR_DIR
