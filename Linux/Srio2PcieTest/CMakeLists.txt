cmake_minimum_required(VERSION 3.0)
project(Srio2PcieTest)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O1 -ggdb -Wall -Wextra")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O1 -ggdb -Wall -Wextra")

include_directories(include)
file(GLOB_RECURSE sourcefiles "src/*.cpp")
link_libraries(pthread)

add_executable(Srio2PcieTest ${sourcefiles})
