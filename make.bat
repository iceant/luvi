@ECHO off

set LUVI_PUBLISH_USER=luvit
set LUVI_PUBLISH_REPO=luvi

set GENERATOR=Visual Studio 16 2019
reg query HKEY_CLASSES_ROOT\VisualStudio.DTE.14.0 >nul 2>nul
IF %errorlevel%==0 set GENERATOR=Visual Studio 14
set GENERATOR64=%GENERATOR%

for /f %%i in ('git describe') do set LUVI_TAG=%%i
IF NOT "x%1" == "x" GOTO :%1

GOTO :build

:regular
ECHO "Building regular64"
cmake -DWithOpenSSL=ON -DWithSharedOpenSSL=OFF -DWithPCRE=ON -DWithLPEG=ON -DWithSharedPCRE=OFF -DWithSQLite3=ON -H. -Bbuild-regular-x64  -G"%GENERATOR64%" -A x64 -T host=x64
GOTO :end

:regular-asm
ECHO "Building regular64 asm"
cmake -DWithOpenSSLASM=ON -DWithOpenSSL=ON -DWithSharedOpenSSL=OFF -DWithPCRE=ON -DWithLPEG=ON -DWithSharedPCRE=OFF -DWithSQLite3=ON -H. -Bbuild-regular-asm-x64  -G"%GENERATOR64%"  -A x64 -T host=x64
GOTO :end

:regular32
ECHO "Building regular32"
cmake -DWithOpenSSL=ON -DWithSharedOpenSSL=OFF -DWithPCRE=ON -DWithLPEG=ON -DWithSharedPCRE=OFF -H. -Bbuild  -G"%GENERATOR%"
GOTO :end

:regular32-asm
ECHO "Building regular32 asm"
cmake -DWithOpenSSLASM=ON -DWithOpenSSL=ON -DWithSharedOpenSSL=OFF -DWithPCRE=ON -DWithLPEG=ON -DWithSharedPCRE=OFF -H. -Bbuild  -G"%GENERATOR%"
GOTO :end

:tiny
ECHO "Building tiny64"
cmake -H. -Bbuild-tiny-x64 -G"%GENERATOR64%" -A x64 -T host=x64
GOTO :end

:tiny32
ECHO "Building tiny32"
cmake -H. -Bbuild-tiny-x86 -G"%GENERATOR%"
GOTO :end

:build
IF NOT EXIST build CALL Make.bat regular
cmake --build build --config Release -- /maxcpucount
COPY build\Release\luvi.exe .
GOTO :end

:test
IF NOT EXIST luvi.exe CALL Make.bat
luvi.exe samples\test.app -- 1 2 3 4
luvi.exe samples\test.app -o test.exe
test.exe 1 2 3 4
DEL /Q test.exe
GOTO :end

:winsvc
IF NOT EXIST luvi.exe CALL Make.bat
DEL /Q winsvc.exe
luvi.exe samples\winsvc.app -o winsvc.exe
GOTO :end

:repl
IF NOT EXIST luvi.exe CALL Make.bat
DEL /Q repl.exe
luvi.exe samples/repl.app -o repl.exe
GOTO :end


:clean
IF EXIST build RMDIR /S /Q build
IF EXIST luvi.exe DEL /F /Q luvi.exe
GOTO :end

:reset
git submodule update --init --recursive
git clean -f -d
git checkout .
GOTO :end

:artifacts-tiny
IF NOT EXIST artifacts MKDIR artifacts
COPY build\Release\luvi.exe artifacts\luvi-tiny-Windows-amd64.exe
COPY build\Release\luvi.lib artifacts\luvi-tiny-Windows-amd64.lib
COPY build\Release\luvi_renamed.lib artifacts\luvi_renamed-tiny-Windows-amd64.lib
GOTO :end

:artifacts-tiny32
IF NOT EXIST artifacts MKDIR artifacts
COPY build\Release\luvi.exe artifacts\luvi-tiny-Windows-ia32.exe
COPY build\Release\luvi.lib artifacts\luvi-tiny-Windows-ia32.lib
COPY build\Release\luvi_renamed.lib artifacts\luvi_renamed-tiny-Windows-ia32.lib
GOTO :end

:artifacts-regular
:artifacts-regular-asm
IF NOT EXIST artifacts MKDIR artifacts
COPY build\Release\luvi.exe artifacts\luvi-regular-Windows-amd64.exe
COPY build\Release\luvi.lib artifacts\luvi-regular-Windows-amd64.lib
COPY build\Release\luvi_renamed.lib artifacts\luvi_renamed-regular-Windows-amd64.lib
GOTO :end

:artifacts-regular32
:artifacts-regular32-asm
IF NOT EXIST artifacts MKDIR artifacts
COPY build\Release\luvi.exe artifacts\luvi-regular-Windows-ia32.exe
COPY build\Release\luvi.lib artifacts\luvi-regular-Windows-ia32.lib
COPY build\Release\luvi_renamed.lib artifacts\luvi_renamed-regular-Windows-ia32.lib
GOTO :end

:publish-tiny
CALL make.bat reset
CALL make.bat tiny
CALL make.bat test
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file luvi.exe --name luvi-tiny-Windows-amd64.exe
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file build\Release\luvi.lib --name luvi-tiny-Windows-amd64.lib
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file build\Release\luvi_renamed.lib --name luvi_renamed-tiny-Windows-amd64.lib
GOTO :end

:publish-tiny32
CALL make.bat reset
CALL make.bat tiny32
CALL make.bat test
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file luvi.exe --name luvi-tiny-Windows-ia32.exe
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file build\Release\luvi.lib --name luvi-tiny-Windows-ia32.lib
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file build\Release\luvi_renamed.lib --name luvi_renamed-tiny-Windows-ia32.lib
GOTO :end

:publish-regular
CALL make.bat reset
CALL make.bat regular-asm
CALL make.bat test
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file luvi.exe --name luvi-regular-Windows-amd64.exe
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file build\Release\luvi.lib --name luvi-regular-Windows-amd64.lib
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file build\Release\luvi_renamed.lib --name luvi_renamed-regular-Windows-amd64.lib
GOTO :end

:publish-regular32
CALL make.bat reset
CALL make.bat regular32-asm
CALL make.bat test
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file luvi.exe --name luvi-regular-Windows-ia32.exe
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file build\Release\luvi.lib --name luvi-regular-Windows-ia32.lib
github-release upload --user %LUVI_PUBLISH_USER% --repo %LUVI_PUBLISH_REPO% --tag %LUVI_TAG% --file build\Release\luvi_renamed.lib --name luvi_renamed-regular-Windows-ia32.lib
GOTO :end

:publish
CALL make.bat clean
CALL make.bat publish-tiny
CALL make.bat clean
CALL make.bat publish-tiny32
CALL make.bat clean
CALL make.bat publish-regular
CALL make.bat clean
CALL make.bat publish-regular32

:end
