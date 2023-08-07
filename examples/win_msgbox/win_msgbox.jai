#load "../../module.jai";

main :: () {
    lua := luaL_newstate();
    defer lua_close(lua);
    
    luaL_openlibs(lua);
    luaL_dostring(lua, lua_code);
}

lua_code :: #string END
local ffi = require("ffi")
local user32 = ffi.load("user32")

ffi.cdef([[
    typedef void* HANDLE;
    typedef HANDLE HWND;
    typedef const char* LPCSTR;
    typedef unsigned UINT;
    
    int MessageBoxA(HWND, LPCSTR, LPCSTR, UINT);
]])

user32.MessageBoxA(nil, "Hello from Jai!", "Jai LuaJIT", 0x0)
END