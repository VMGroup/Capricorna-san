#include <Windows.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

static int zzz(lua_State *L)
{
    long sec = lua_tointeger(L, -1);
    Sleep(sec * 1000);
    return 0;
}

int luaopen_zzz(lua_State *L)
{
    lua_register(L, "zzz", zzz);
    return 0;
}
