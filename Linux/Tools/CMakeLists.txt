cmake_minimum_required(VERSION 3.0)
project(Srio2PcieTest)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O1 -ggdb -Wall -Wextra")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O1 -ggdb -Wall -Wextra")

include_directories(include)

add_executable(readHwFhogRegs src/CXdmaManager.cpp src/readHwFhogRegs.cpp)
add_executable(readSrio2PcieRegs src/CXdmaManager.cpp src/readSrio2PcieRegs.cpp)
