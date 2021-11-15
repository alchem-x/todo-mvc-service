cmake_minimum_required(VERSION 3.5)
project(app C)

set(CMAKE_C_STANDARD 99)
#add_library(store store.c)
#target_include_directories(
#        store
#        PUBLIC
#        shttpd/src
#        cJSON
#)
#add_library(service service.c store.c)
#target_include_directories(
#        service
#        PUBLIC
#        shttpd/src
#        cJSON
#)
add_executable(${PROJECT_NAME} store.c service.c app.c)
target_include_directories(
        ${PROJECT_NAME}
        PUBLIC
        shttpd/src
        cJSON
)
find_library(shttpd libshttpd.a shttpd/src)
find_library(cJSON libcjson.a cJSON/)
target_link_libraries(${PROJECT_NAME} ${SHTTPD} ${CJSON} dl pthread)
