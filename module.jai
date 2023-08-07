#scope_export
size_t :: s64;
ptrdiff_t :: s64;

luaL_dostring :: (L: *lua_State, s: *u8) {
    luaL_loadstring(L, s);
    lua_pcall(L, 0, LUA_MULTRET, 0);
}

luaL_dofile :: (L: *lua_State, file: *u8) {
    luaL_loadfile(L, file);
    lua_pcall(L, 0, LUA_MULTRET, 0);
}

#load "generated.jai";