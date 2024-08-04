cmake_minimum_required(VERSION 3.21)

project(adaptivecpp-example)

set(CMAKE_CXX_STANDARD 17)

find_package(AdaptiveCpp REQUIRED)

set(ACPP_DEBUG_LEVEL 3 CACHE STRING "AdaptiveCpp debug level" FORCE)

add_executable(acpp-example main.cpp)

target_compile_definitions(acpp-example 
    PRIVATE -DACPP_DEBUG_LEVEL=${ACPP_DEBUG_LEVEL}
)

add_sycl_to_target(TARGET acpp-example)
