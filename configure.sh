#!/bin/bash

if [[ $OSTYPE == darwin* ]] ; then
	declare cmakeGenerator="Xcode"
	declare qt5Dir="/Applications/Qt/Current/clang_64/lib/cmake/Qt5"
elif [[ $OSTYPE == msys* ]] ; then
	declare cmakeGenerator="Visual Studio 16 2019"
	declare qt5Dir="C:/Qt/Current/msvc2019_64/lib/cmake/Qt5"
else
	exit 2
fi

cmake -B"./_build"\
			-DCMAKE_INSTALL_PREFIX="./_build/install"\
			-G"$cmakeGenerator"\
			-DQt5_DIR="$qt5Dir"\
			$cmakeExtraAguments $params
