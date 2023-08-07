#load "../../module.jai";

#import "Basic";

my_func :: (L: *lua_State) -> s32 #c_call {
    ctx: Context;
    push_context ctx {
        print("Called jai function!\n");
        return 0;
    }
}

main :: () {
    lua: *lua_State = luaL_newstate();
    
    lua_pushcfunction(lua, my_func);
    lua_setglobal(lua, "my_jai_function");
    
    luaL_openlibs(lua);
    luaL_dostring(lua, lua_code);
    
    lua_getglobal(lua, "my_lua_function");
    lua_pushstring(lua, "an argument");
    lua_pcall(lua, 1, 0, 0);
    
    lua_close(lua);
}

lua_code :: #string END
function my_lua_function(name)
    print("Called lua function!")
    print(name)
end

my_jai_function()
END