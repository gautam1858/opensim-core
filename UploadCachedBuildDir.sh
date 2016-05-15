set -e

BUILD_DIR=$(pwd)
echo $BUILD_DIR
cd $TRAVIS_BUILD_DIR
git fetch origin master:master
git checkout 64dca7cd40275491f09f206d849d80cd6ef381a3
MASTERTIP=$(git log -n1 --format="%H")
echo $VERSION
cd $BUILD_DIR
make -j$NPROC
rm -rf Bindings
cd ..
tar -czf $TARBALL opensim-core-build
split -b 200m $TARBALL $TARBALL
URL="https://api.bintray.com/content/opensim/opensim-core/${PACKAGENAME}/${MASTERTIP}/${PACKAGENAME}/${MASTERTIP}"
ls ${TARBALL}a* | while read f; do curl -T $f -uklshrinidhi:440061321dba00a68210b482261154ea58d03f00 ${URL}/${f}; done
URL="https://api.bintray.com/content/opensim/opensim-core/${PACKAGENAME}/${VERSION}/publish"
curl -X POST -uklshrinidhi:440061321dba00a68210b482261154ea58d03f00 $URL
