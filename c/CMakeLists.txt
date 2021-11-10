cmake_minimum_required(VERSION 3.0)
project(app)

add_subdirectory(cJSON)

add_executable(${PROJECT_NAME} main.c)

target_include_directories(
        ${PROJECT_NAME}
        PUBLIC
        ${PROJECT_SOURCE_DIR}/shttpd/src
        ${PROJECT_SOURCE_DIR}/cJSON

)
find_library(shttpd libshttpd.a ${PROJECT_SOURCE_DIR}/shttpd/src)
target_link_libraries(${PROJECT_NAME} ${shttpd} dl pthread cjson)
