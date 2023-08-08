#run {
    set_build_options_dc(.{do_output=false});
    
    {
        w := compiler_create_workspace();
        options := get_build_options();
        options.output_executable_name = "my_library";
        options.output_type = .DYNAMIC_LIBRARY;
        set_build_options(options, w);

        add_build_file("main.jai", w);
    }
}

#import "Basic";
#import "Compiler";