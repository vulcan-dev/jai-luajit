#assert OS == .WINDOWS "Only windows is supported";

#scope_file
LUAJIT_DIR :: "luajit/src";
DYNASM_DIR :: "luajit/dynasm";

BUILD_DEBUG :: false;
COMPILE :: true;

build_mini_lua :: () -> bool {
    #if OS == .WINDOWS {
        print("\n==== Building minilua ====\n");
        // if !build_cpp_static_lib(tprint("%/minilua", LUAJIT_DIR), tprint("%/host/minilua.c", LUAJIT_DIR), extra = .["/nologo", "/c", "/W3", "/D_CRT_SECURE_NO_DEPRECATE", "/D_CRT_STDIO_INLINE=__declspec(dllexport)__inline"], debug=BUILD_DEBUG) then return false;
        if !build_cpp_executable(tprint("%/minilua", LUAJIT_DIR), tprint("%/host/minilua.c", LUAJIT_DIR), extra = .["/D_CRT_SECURE_NO_DEPRECATE"], debug=BUILD_DEBUG) then return false;
        
        if run_command(...[tprint("%/minilua.exe", LUAJIT_DIR), "../dynasm/dynasm.lua", "-LN",
            "-D", "WIN", "-D", "JIT", "-D", "FFI", "-D", "P64",
            "-o", "host/buildvm_arch.h", "vm_x86.dasc"], working_directory=LUAJIT_DIR).exit_code != 0 { return false; }
    }
    
    return true;
}

build_vm :: () -> bool {
    #import "Process";

    files := string.[
        tprint("%/host/buildvm.c", LUAJIT_DIR),
        tprint("%/host/buildvm_asm.c", LUAJIT_DIR),
        tprint("%/host/buildvm_fold.c", LUAJIT_DIR),
        tprint("%/host/buildvm_lib.c", LUAJIT_DIR),
        tprint("%/host/buildvm_peobj.c", LUAJIT_DIR),
    ];

    buildvm_path: string = tprint("%/buildvm.exe", LUAJIT_DIR);
    working_dir: string = "windows";
    lj_vm_object: string = "lj_vm.obj";
    
    ljsrc_dir: string = tprint("/I%", LUAJIT_DIR);
    ljsrc_host_dir: string = tprint("/I%/host", LUAJIT_DIR);
    
    #if OS == .WINDOWS {
        print("\n==== Building buildvm ====\n");
        if !build_cpp_static_lib(tprint("%/buildvm", LUAJIT_DIR), ..files, extra = .["/nologo", "/c", "/W3", "/D_CRT_SECURE_NO_DEPRECATE", "/D_CRT_STDIO_INLINE=__declspec(dllexport)__inline", ljsrc_dir, ljsrc_host_dir], debug=BUILD_DEBUG) then return false;
        if !build_cpp_executable(tprint("%/buildvm", LUAJIT_DIR), ..files, extra = .["/D_CRT_SECURE_NO_DEPRECATE", ljsrc_dir, ljsrc_host_dir], debug=BUILD_DEBUG) then return false;
    }

    run_command(buildvm_path, "-m", "peobj", "-o",   "lj_vm.obj", working_directory=LUAJIT_DIR);
    run_command(buildvm_path, "-m", "bcdef",  "-o",  "lj_bcdef.h",    "lib_base.c", "lib_math.c", "lib_bit.c", "lib_string.c", "lib_table.c", "lib_io.c", "lib_os.c", "lib_package.c", "lib_debug.c", "lib_jit.c", "lib_ffi.c", working_directory=LUAJIT_DIR);
    run_command(buildvm_path, "-m", "ffdef",  "-o",  "lj_ffdef.h",    "lib_base.c", "lib_math.c", "lib_bit.c", "lib_string.c", "lib_table.c", "lib_io.c", "lib_os.c", "lib_package.c", "lib_debug.c", "lib_jit.c", "lib_ffi.c", working_directory=LUAJIT_DIR);
    run_command(buildvm_path, "-m", "libdef", "-o",  "lj_libdef.h",   "lib_base.c", "lib_math.c", "lib_bit.c", "lib_string.c", "lib_table.c", "lib_io.c", "lib_os.c", "lib_package.c", "lib_debug.c", "lib_jit.c", "lib_ffi.c", working_directory=LUAJIT_DIR);
    run_command(buildvm_path, "-m", "recdef", "-o",  "lj_recdef.h",   "lib_base.c", "lib_math.c", "lib_bit.c", "lib_string.c", "lib_table.c", "lib_io.c", "lib_os.c", "lib_package.c", "lib_debug.c", "lib_jit.c", "lib_ffi.c", working_directory=LUAJIT_DIR);
    run_command(buildvm_path, "-m", "vmdef",  "-o",  "jit/vmdef.lua", "lib_base.c", "lib_math.c", "lib_bit.c", "lib_string.c", "lib_table.c", "lib_io.c", "lib_os.c", "lib_package.c", "lib_debug.c", "lib_jit.c", "lib_ffi.c", working_directory=LUAJIT_DIR);
    run_command(buildvm_path, "-m", "folddef", "-o", "lj_folddef.h",  "lj_opt_fold.c", working_directory=LUAJIT_DIR);
    
    return true;
}

build_lib :: () -> bool {
    all_lj := find_files(LUAJIT_DIR, "lj_*.c");
    all_lib := find_files(LUAJIT_DIR, "lib_*.c");

    sources: [..]string;
    array_add(*sources, ..all_lj);
    array_add(*sources, ..all_lib);

    #if OS == .WINDOWS {
        extras: [..]string;
        array_add(*extras, "/nologo");
        array_add(*extras, "/O2");
        array_add(*extras, "/W3");
        array_add(*extras, "/D_CRT_SECURE_NO_DEPRECATE");
        array_add(*extras, "/D_CRT_STDIO_INLINE=__declspec(dllexport)__inline");
        array_add(*extras, "/MD");
        array_add(*extras, "/DLUAJIT_ENABLE_LUA52COMPAT");
        array_add(*extras, "/DLUA_BUILD_AS_DLL");
        array_add(*extras, tprint("/I%", LUAJIT_DIR));
        array_add(*extras, tprint("/I%/host", LUAJIT_DIR));

        print("\n==== Building luajit ====\n");
        if !build_cpp_static_lib("windows/lua51", ..sources, extra=extras, debug=BUILD_DEBUG) then return false;

        array_add(*extras, tprint("%/lj_vm.obj", LUAJIT_DIR));
        array_add(*extras, tprint("%/buildvm.lib", LUAJIT_DIR));
        if !build_cpp_dynamic_lib("windows/lua51", ..sources, extra=extras, debug=BUILD_DEBUG) then return false;
    }
    
    return true;
}

generate_bindings :: () -> bool {
    #import "BuildCpp";
    #if OS == .WINDOWS {
        make_directory_if_it_does_not_exist("windows");
    } else {
        make_directory_if_it_does_not_exist("linux-mac");
    }
    
    #if COMPILE {
        if !build_mini_lua() then return false;
        if !build_vm() then return false;
        if !build_lib() then return false;
    }
    
    output_filename: string = "generated.jai";
    opts: Generate_Bindings_Options;
    {
        using opts;
        
        #if OS == .WINDOWS {
            array_add(*libpaths, "windows");
        } else {
            array_add(*libpaths, "linux-mac");
        }
        
        sources: [..]string;
        array_add(*sources, tprint("%/lua.h", LUAJIT_DIR));
        array_add(*sources, tprint("%/lauxlib.h", LUAJIT_DIR));
        array_add(*sources, tprint("%/lualib.h", LUAJIT_DIR));
        
        array_add(*libnames, "lua51");
        array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);
        array_add(*include_paths, LUAJIT_DIR);
        array_add(*source_files, ..sources);
    }
    
    return generate_bindings(opts, output_filename);
}

#run {
    set_build_options_dc(.{do_output=false});
    if !generate_bindings() {
        compiler_set_workspace_status(.FAILED);
    }
}

find_files :: (path: string, pattern: string, recursive: bool = false) -> [..] string {
    User_Data :: struct {
        files: [..]string;
        pattern: string;
    }
    
    data := User_Data .{
        pattern = pattern
    };

    visitor :: (info: *File_Visit_Info, data: *User_Data) {
        if (wildcard_match(info.short_name, data.pattern))
            array_add(*data.files, copy_string(info.full_name));
    }

    visit_files(path, recursive, *data, visitor);
    return data.files;
}

#import "Basic";
#import "Bindings_Generator";
#import "File_Utilities";
#import "Compiler";
#import "File";
#import "String";