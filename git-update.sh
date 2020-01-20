cd deps/luv/deps/libuv/
git checkout v1.x
cd ../luajit/
git checkout v2.1
cd ../../../
git submodule update --remote --merge
git pull

