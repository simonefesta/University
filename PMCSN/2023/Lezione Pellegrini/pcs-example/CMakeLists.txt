cmake_minimum_required(VERSION 3.10)
project(PCS)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_VISIBILITY_PRESET hidden)

add_library(core STATIC core/calqueue.c core/scheduler.c)

add_executable(pcs-sequential model/pcs.c model/serial.c model/rngs.c)
target_link_libraries(pcs-sequential core m)

add_executable(pcs-parallel model/pcs.c model/parallel.c model/rngs.c)
target_link_libraries(pcs-parallel ${CMAKE_SOURCE_DIR}/libs/librscore.a m)
