#!/bin/bash

WORKDIR=~/git/work
REPOURL=https://github.com/llvm-mirror/llvm.git
REPO=llvm

function 1_1_clone {
  git clone ${REPOURL}
  cd ${REPO}
  git config --local user.name "foo"
  git config --local user.email "foo@bar.com"
}

function 1_2_log {
  git log --graph --decorate --oneline > /dev/null
  git log > /dev/null
  git log --oneline > /dev/null
  git log --graph > /dev/null
}

function 1_3_checkout_branches {
  git checkout release_20 > /dev/null
  git checkout release_50 > /dev/null
  git checkout release_1 > /dev/null
  git checkout release_35 > /dev/null
  git checkout master > /dev/null
}

function 1_4_rebase {
  git checkout master > /dev/null
  git checkout -b benchmark_rebase_branch > /dev/null
  echo "Hello world!" > benchmark_hello.txt
  git add benchmark_hello.txt > /dev/null
  git commit -m "Hello" > /dev/null
  git rebase --onto origin/release_1 HEAD^ > /dev/null
  git rebase --onto origin/release_20 HEAD^ > /dev/null
  git rebase --onto origin/release_50 HEAD^ > /dev/null
  git rebase --onto origin/release_35 HEAD^ > /dev/null
  git rebase --onto origin/release_31 HEAD^ > /dev/null
  git rebase --onto origin/master HEAD^ > /dev/null
  git checkout master > /dev/null
}

function 2_1_cmake_ninja {
  mkdir build && pushd build > /dev/null && cmake -G Ninja -DCMAKE_BUILD_TYPE=Release .. > /dev/null
  popd > /dev/null && rm -rf build
  mkdir build && pushd build > /dev/null && cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug .. > /dev/null
  popd > /dev/null && rm -rf build
}

function 2_2_cmake_make {
  mkdir build && pushd build > /dev/null && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release .. > /dev/null
  popd > /dev/null && rm -rf build
  mkdir build && pushd build > /dev/null && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug .. > /dev/null
  popd > /dev/null && rm -rf build
}


#------------------------------------------------------------------------------
# Program entry.
#------------------------------------------------------------------------------

# Start fresh.
rm -rf ${WORKDIR}
mkdir -p ${WORKDIR}
cd ${WORKDIR}

# Show some version information.
git --version
cmake --version
ninja --version
echo

#------------------------------------------------------------------------------
# GIT benchmarks.
#------------------------------------------------------------------------------

echo "1.1) Clone repository from GitHub."
time 1_1_clone
echo

# Prime file caches.
git status > /dev/null
git ls-files > /dev/null

echo "1.2) Log the repo."
time 1_2_log
echo

echo "1.3) Check out branches."
time 1_3_checkout_branches
echo

echo "1.4) Rebase"
time 1_4_rebase
echo


#------------------------------------------------------------------------------
# CMake benchmarks.
#------------------------------------------------------------------------------

echo "2.1) CMake (Ninja)"
time 2_1_cmake_ninja
echo

echo "2.2) CMake (Make)"
time 2_2_cmake_make
echo


#------------------------------------------------------------------------------
# Compilation benchmarks.
#------------------------------------------------------------------------------

echo "3.1) Compile Ninja Release"
mkdir build && pushd build > /dev/null && cmake -G Ninja -DCMAKE_BUILD_TYPE=Release .. > /dev/null
time ninja > /dev/null
popd > /dev/null && rm -rf build
echo

