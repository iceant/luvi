set(LUA_SQLITE3_DIR ${CMAKE_CURRENT_SOURCE_DIR}/deps/lsqlite3)

add_library(lua_sqlite3 
    ${LUA_SQLITE3_DIR}/sqlite3.c
    ${LUA_SQLITE3_DIR}/lsqlite3.c
)
add_definitions(-DWITH_SQLITE)
set(EXTRA_LIBS ${EXTRA_LIBS} lua_sqlite3)