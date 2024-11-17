setlocal

if not exist out\ (
	mkdir out
)

if not exist deps\ (
	mkdir deps
)

if not exist deps\ponyc.zip (
	pushd deps
	curl -Lo ponyc.zip https://dl.cloudsmith.io/public/ponylang/releases/raw/versions/latest/ponyc-x86-64-pc-windows-msvc.zip
	popd deps
)

if not exist deps\bin\ponyc.exe (
	pushd deps
	tar -x -f ponyc.zip
	popd deps
)

set PATH=.\deps\bin;%PATH%
ponyc --path build-win --output build-win --bin-name assignment2 --cpu skylake src

