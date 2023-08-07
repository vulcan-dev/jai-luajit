#scope_export
size_t :: s64;
ptrdiff_t :: s64;

lua_pop :: (L: *lua_State, n: s32) {
    lua_settop(L, -(n)-1);
}

lua_newtable :: (L: *lua_State) {
    lua_createtable(L, 0, 0);
}

lua_register :: (L: *lua_State, n: *u8, f: lua_CFunction) {
    lua_pushcfunction(L, f);
    lua_setglobal(L, n);
}

lua_pushcfunction :: (L: *lua_State, f: lua_CFunction) {
    lua_pushcclosure(L, f, 0);
}

lua_isfunction :: (L: *lua_State, n: s32) -> bool {
    return lua_type(L, n) == LUA_TFUNCTION;
}

lua_istable :: (L: *lua_State, n: s32) -> bool {
    return lua_type(L, n) == LUA_TTABLE;
}

lua_islightuserdata :: (L: *lua_State, n: s32) -> bool {
    return lua_type(L, n) == LUA_TLIGHTUSERDATA;
}

lua_isnil :: (L: *lua_State, n: s32) -> bool {
    return lua_type(L, n) == LUA_TNIL;
}

lua_isboolean :: (L: *lua_State, n: s32) -> bool {
    return lua_type(L, n) == LUA_TBOOLEAN;
}

lua_isthread :: (L: *lua_State, n: s32) -> bool {
    return lua_type(L, n) == LUA_TTHREAD;
}

lua_isnone :: (L: *lua_State, n: s32) -> bool {
    return lua_type(L, n) == LUA_TNONE;
}

lua_isnoneornil :: (L: *lua_State, n: s32) -> bool {
    return lua_type(L, n) <= 0;
}

lua_setglobal :: (L: *lua_State, s: *u8) {
    lua_setfield(L, LUA_GLOBALSINDEX, s);
}

lua_getglobal :: (L: *lua_State, s: *u8) {
    lua_getfield(L, LUA_GLOBALSINDEX, s);
}

luaL_dostring :: (L: *lua_State, s: *u8) {
    luaL_loadstring(L, s);
    lua_pcall(L, 0, LUA_MULTRET, 0);
}

luaL_dofile :: (L: *lua_State, file: *u8) {
    luaL_loadfile(L, file);
    lua_pcall(L, 0, LUA_MULTRET, 0);
}

#load "generated.jai";