
if [[ $1 == 'build' ]];then
  cd shttpd/src
  make unix
  cd -
  mkdir build && cd build && cmake ..
  cd -
  cp -f build/app app
fi

if [[ $1 == 'run' ]];then
  ./app
fi

if [[ $1 == 'clear' ]];then
  rm -f app
  rm -rf build
  rm -rf shttpd/src/*.o shttpd libshttpd.a
fi
