set -e

cd $TRAVIS_BUILD_DIR
if [ "$(git branch | grep '*' | sed 's/^* //')" == "master" ]; then 
  echo "---- Not downloading cache. Current branch is master."
  return
fi

echo '---- Checking for availability of cached build directory on Bintray.'
if  [[ "$CC" == *gcc* ]]; then export COMPILER=gcc; fi
if  [[ "$CC" == *clang* ]]; then export COMPILER=clang; fi
PACKAGENAME="${MACHTYPE}_${COMPILER}_${BTYPE}"
git fetch -q origin master:master
echo "after fetch"
BRANCHTIP=$(git log -n1 --format='%H')
BRANCHBASE=$(git merge-base master ${BRANCHTIP})
cd ..
find opensim-core -iname '*' | while read f; do touch -m -t"201505180900" $f; done
cd opensim-core
echo "after find"
git diff --name-only $BRANCHBASE $BRANCHTIP | while read f; do touch $f; done
cd ~
TARBALL='opensim-core-build.tar.gz'
echo "after tarball"
LETTERS='a b c d e f g h i j k l m n o p q r s t u v w x y z'
URL="https://dl.bintray.com/opensim/opensim-core/${PACKAGENAME}/${BRANCHBASE}"
echo "---- Looking for opensim/opensim-core/${PACKAGENAME}/${BRANCHBASE}"
for i in $LETTERS; do 
  piece=${TARBALL}a$i 
  curl -L $URL/$piece -o $piece
  if [ $(wc -c < $piece) -lt 100 ]; then 
    rm $piece 
    break 
  else 
    echo "---- Downloaded piece $piece"
  fi 
done
if [ ! -f ${TARBALL}aa ]; then 
  echo '---- Cache not found.'
  mkdir opensim-core-build
  return
fi
echo 'Joining the pieces downloaded.'
cat ${TARBALL}* > ${TARBALL}
echo 'Decompressing tarball.'
tar -xzf ${TARBALL}
rm -f ${TARBALL}*
