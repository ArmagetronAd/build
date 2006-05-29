%build
progtitle="PROGNAME"
progname=PACKAGE
export progtitle
export progname

#optimize
CXXFLAGS="%optflags $CXXFLAGS"
export CXXFLAGS

#build dedicated server
pushd bindist-dedicated
make
popd

#build client
pushd bindist
make
popd
