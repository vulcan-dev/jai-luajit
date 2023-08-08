#load "../../module.jai";
#import "Basic";
Win32 :: #import "Windows";
#import "Windows_Utf8";

lapi_messagebox :: (L: *lua_State) -> s32 #c_call {
    ctx: Context; push_context ctx {
        caption: *u8 = luaL_checkstring(L, -2);
        if !caption then return 0;
        
        message: *u8 = luaL_checkstring(L, -1);
        if !message then return 0;
        
        Win32.MessageBoxW(null, utf8_to_wide(to_string(caption)), utf8_to_wide(to_string(message)), Win32.MB_OK);
        return 0;
    }
}

#program_export
luaopen_my_library :: (L: *lua_State) -> s32 #c_call {
    ctx: Context;
    push_context ctx {
        lua_pushcfunction(L, lapi_messagebox);
        lua_setglobal(L, "message_box");
        print("luaopen_my_library called!\n");
    }
    
    return 0;
}