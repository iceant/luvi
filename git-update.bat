cd deps/luv/deps/luajit
git checkout v2.1
git pull

cd ../libuv
git checkout v1.x
git pull

cd ../../../../
git remote add public https://github.com/luvit/luvi
git remote update
git submodule foreach git remote update