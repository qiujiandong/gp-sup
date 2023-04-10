file(GLOB SRC_LIST *.cpp)
add_library(emcv_highgui OBJECT ${SRC_LIST})

file(GLOB INC_LIST *.h*)
install(FILES ${INC_LIST} DESTINATION include/cv/highgui)