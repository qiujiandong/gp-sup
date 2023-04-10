cmake_minimum_required(VERSION 3.0)
project(kcf_dsp)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O1 -ggdb -Wall -Wextra")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O1 -ggdb -Wall -Wextra")

find_package(OpenCV REQUIRED)

include_directories(include)
file(GLOB_RECURSE sourcefiles "src/*.cpp")
link_libraries(pthread)

add_executable(kcf_dsp ${sourcefiles})
target_link_libraries(kcf_dsp ${OpenCV_LIBS})
