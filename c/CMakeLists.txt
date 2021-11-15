cmake_minimum_required(VERSION 3.5)
project(app C)

set(CMAKE_C_STANDARD 99)
add_executable(${PROJECT_NAME} store.c service.c app.c)
target_include_directories(
        ${PROJECT_NAME}
        PUBLIC
        shttpd/src
        cJSON
        ${PROJECT_SOURCE_DIR}
)
find_library(SHTTPD libshttpd.a shttpd/src)
find_library(CJSON libcjson.a cJSON/)
target_link_libraries(${PROJECT_NAME} ${SHTTPD} ${CJSON} dl pthread)
