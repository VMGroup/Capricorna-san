// http://www.troubleshooters.com/codecorn/lua/lua_lua_calls_c.htm#_Make_an_msleep_Function
// gcc -Wall -shared -fPIC -o zzz.so -llua zzz-posix.c
#include <unistd.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

static int zzz(lua_State *L)
{
    long sec = lua_tointeger(L, -1);
    sleep(sec);
    return 0;
}

int luaopen_zzz(lua_State *L)
{
    lua_register(L, "zzz", zzz);
    return 0;
}
