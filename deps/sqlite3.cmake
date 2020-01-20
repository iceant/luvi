set(LUA_SQLITE3_DIR ${CMAKE_CURRENT_SOURCE_DIR}/deps/lsqlite3)
set(LUA_SQLITE3_LIB lua_sqlite3)

include_directories(deps/lsqlite3)

add_library(lua_sqlite3 
    ${LUA_SQLITE3_DIR}/sqlite3.c
    ${LUA_SQLITE3_DIR}/lsqlite3.c
)

set_target_properties(lua_sqlite3 PROPERTIES COMPILE_FLAGS -DLUA_LIB)
add_definitions(-DWITH_SQLITE)
set(EXTRA_LIBS ${EXTRA_LIBS} lua_sqlite3)