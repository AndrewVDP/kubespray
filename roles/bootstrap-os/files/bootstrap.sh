#!/bin/bash
set -e

BINDIR="/opt/bin"

mkdir -p $BINDIR

cd $BINDIR

# library fixup
mkdir -p pypy/lib
# rm $BINDIR/pypy/lib/libtinfo.so.5
if [ -f /lib64/libncurses.so.5.9 ]; then
  ln -snf /lib64/libncurses.so.5.9 $BINDIR/pypy/lib/libtinfo.so.5
elif [ -f /lib64/libncurses.so.6.1 ]; then
ln -snf /lib64/libncurses.so.6.1 $BINDIR/pypy/lib/libtinfo.so.5
fi
# ln -snf $(ls /lib64/* | grep "libncurses.so.[0-9]\+.\?[0-9]\?" | tail -1) $BINDIR/pypy/lib/libtinfo.so.5

if [[ -e $BINDIR/.bootstrapped ]]; then
  exit 0
fi

PYPY_VERSION=6.0.0

wget -O - https://bitbucket.org/squeaky/portable-pypy/downloads/pypy-${PYPY_VERSION}-linux_x86_64-portable.tar.bz2 |tar -xjf -
mv -n pypy-${PYPY_VERSION}-linux_x86_64-portable pypy

cat > $BINDIR/python <<EOF
#!/bin/bash
LD_LIBRARY_PATH=$BINDIR/pypy/lib:$LD_LIBRARY_PATH exec $BINDIR/pypy/bin/pypy "\$@"
EOF

chmod +x $BINDIR/python
$BINDIR/python --version

touch $BINDIR/.bootstrapped
