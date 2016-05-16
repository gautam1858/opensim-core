set -e

cd $TRAVIS_BUILD_DIR
CURRBRANCH=$(git branch | grep '*' | sed 's/^* //')
if [ "$CURRBRANCH" != "master" ]; then 
  echo '---- Not caching build directory. Current branch is not master.'
  return
fi

MASTERTIP=$(git log -n1 --format="%H")
cd ${OPENSIM_BUILD_DIR}/..
echo '---- Compressing build directory into a tarball.'
tar -czf $TARBALL opensim-core-build
echo '---- Splitting tarball into smaller pieces for upload.'
split -b 200m $TARBALL $TARBALL
rm $TARBALL
URL="https://api.bintray.com/content/opensim/opensim-core/${PACKAGENAME}/${MASTERTIP}/${PACKAGENAME}/${MASTERTIP}"
PIECES=$(ls ${TARBALL}a*)
for piece in PIECES; do 
  echo "---- Uploading piece ${piece} to opensim/opensim-core/${PACKAGENAME}/${MASTERTIP}"
  curl -T $piece -uklshrinidhi:440061321dba00a68210b482261154ea58d03f00 ${URL}/${piece} 
done
URL="https://api.bintray.com/content/opensim/opensim-core/${PACKAGENAME}/${MASTERTIP}/publish"
echo '---- Publishing uploaded build directory.'
curl -X POST -uklshrinidhi:440061321dba00a68210b482261154ea58d03f00 $URL
echo '---- Cleaning up.'
rm ${TARBALL}*
cd opensim-core-build
