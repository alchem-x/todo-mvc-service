if [[ $1 == 'build' ]];then
  echo "build cjson"
  cd cJSON
  rm -rf build
  mkdir build
  cd build
  cmake ..
  make
  cd -
  cp -f build/libcjson.a .
  cd ..

  echo "build shttpd"
  cd shttpd/src
  rm -rf *.o *.a
  make unix
#  cp -f libshttpd.a ../
  cd ../../
fi

if [[ $1 == 'run' ]];then
  rm -rf build
  mkdir build
  cd build
  cmake ..
  make VERBOSE=1
  cd -
  cp -f build/app .
  echo "start run app"
  ./app
fi