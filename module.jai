#scope_export
size_t :: s64;
ptrdiff_t :: s64;

// lua.h macros
lua_pop :: (L: *lua_State, n: s32) #expand { lua_settop(L, -(n)-1); }
lua_newtable :: (L: *lua_State) #expand { lua_createtable(L, 0, 0); }
lua_register :: (L: *lua_State, n: *u8, f: lua_CFunction) #expand {
    lua_pushcfunction(L, f);
    lua_setglobal(L, n);
}

lua_pushcfunction :: (L: *lua_State, f: lua_CFunction) #expand { lua_pushcclosure(L, f, 0); }

lua_isfunction :: (L: *lua_State, n: s32) -> bool #expand { return lua_type(L, n) == LUA_TFUNCTION; }
lua_istable :: (L: *lua_State, n: s32) -> bool #expand { return lua_type(L, n) == LUA_TTABLE; }
lua_islightuserdata :: (L: *lua_State, n: s32) -> bool #expand { return lua_type(L, n) == LUA_TLIGHTUSERDATA; }
lua_isnil :: (L: *lua_State, n: s32) -> bool #expand { return lua_type(L, n) == LUA_TNIL; }
lua_isboolean :: (L: *lua_State, n: s32) -> bool #expand { return lua_type(L, n) == LUA_TBOOLEAN; }
lua_isthread :: (L: *lua_State, n: s32) -> bool #expand { return lua_type(L, n) == LUA_TTHREAD; }
lua_isnone :: (L: *lua_State, n: s32) -> bool #expand { return lua_type(L, n) == LUA_TNONE; }
lua_isnoneornil :: (L: *lua_State, n: s32) -> bool #expand { return lua_type(L, n) <= 0; }

lua_pushliteral :: (L: *lua_State, s: *u8) -> *u8 #expand { lua_pushlstring(L, s, strlen(s)); }

lua_setglobal :: (L: *lua_State, s: *u8) #expand { lua_setfield(L, LUA_GLOBALSINDEX, s); }
lua_getglobal :: (L: *lua_State, s: *u8) #expand { lua_getfield(L, LUA_GLOBALSINDEX, s); }

lua_tostring :: inline (L: *lua_State, i: s32) -> *u8 #expand { return lua_tolstring(L, i, null); }

// lauxlib.h macros
luaL_argcheck :: (L: *lua_State, cond: bool, numarg: s32, extramsg: *u8) #expand {
    if !cond then luaL_argerror(L, numarg, extramsg);
}

luaL_checkstring :: (L: *lua_State, n: s32) -> *u8 #expand { return luaL_checklstring(L, n, null); }
luaL_optstring :: (L: *lua_State, n: s32, d: *u8) -> *u8 #expand { return luaL_optlstring(L, n, d, null); }

luaL_checkint :: (L: *lua_State, n: s32) -> lua_Integer #expand { return luaL_checkinteger(L, n); }
luaL_optint :: (L: *lua_State, n: s32, d: s32) -> lua_Integer #expand { return luaL_optinteger(L, n, d); }

luaL_checklong :: (L: *lua_State, n: s32) -> lua_Integer #expand { return luaL_checkinteger(L, n); }
luaL_optlong :: (L: *lua_State, n: s32, d: s32) -> lua_Integer #expand { return luaL_optinteger(L, n, d); }

luaL_typename :: (L: *lua_State, i: s32) -> *u8 #expand { return lua_typename(L, lua_type(L, i)); }

luaL_dofile :: (L: *lua_State, file: *u8) #expand {
    luaL_loadfile(L, file);
    lua_pcall(L, 0, LUA_MULTRET, 0);
}

luaL_dostring :: (L: *lua_State, s: *u8) #expand {
    luaL_loadstring(L, s);
    lua_pcall(L, 0, LUA_MULTRET, 0);
}

luaL_getmetatable :: (L: *lua_State, n: s32) -> s32 #expand { return lua_getfield(L, LUA_REGISTRYINDEX, n); }
luaL_opt :: (L: *lua_State, func:(L: *lua_State, arg: s32), arg: s32, dflt: s32) #expand {
    ifx lua_isnoneornil(L, n) then dflt else func(L, arg);
}

#load "generated.jai";