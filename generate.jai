LIB_BASE_NAME :: "miniaudio";
SOURCE_FILE   :: "source/miniaudio.c";

#run {
    Compiler.set_build_options_dc(.{ do_output = false });

    lib_folder := ifx OS == .WINDOWS {
        make_directory_if_it_does_not_exist ("windows/");
        join("windows/", LIB_BASE_NAME);
    } else ifx OS == .MACOS {
        make_directory_if_it_does_not_exist ("macos/");
        join("macos/", LIB_BASE_NAME);
    } else ifx OS == .LINUX {
        make_directory_if_it_does_not_exist ("linux/");
        join("linux/", LIB_BASE_NAME);
    }

    #if OS == {
        case .MACOS;
            options := Compiler.get_build_options();
            minimum_version   : type_of(options.minimum_os_version) = .{ 11, 0 };
            macos_version_arg := tprint("-mmacos-version-min=%.%", minimum_version.major, minimum_version.minor);

            lib_base_x64    := sprint("%/%_%", "macos", LIB_BASE_NAME, "x64");
            x64_target      := get_macos_target_triple(.X64, minimum_version.major, minimum_version.minor);
            x64_extra       := string.[ "-target", x64_target, macos_version_arg ];

            if !build_cpp_dynamic_lib(lib_base_x64, SOURCE_FILE, debug=false, extra=x64_extra) {
                Compiler.compiler_set_workspace_status(.FAILED);
                return;
            }

            if !build_cpp_static_lib(lib_base_x64, SOURCE_FILE, debug=false, extra=x64_extra) {
                Compiler.compiler_set_workspace_status(.FAILED);
                return;
            }

            lib_base_arm64    := sprint("%/%_%", "macos", LIB_BASE_NAME, "arm64");
            arm64_target      := get_macos_target_triple(.ARM64, minimum_version.major, minimum_version.minor);
            arm64_extra       := string.[ "-target", arm64_target, macos_version_arg ];

            if !build_cpp_dynamic_lib(lib_base_arm64, SOURCE_FILE, debug=false, extra=arm64_extra) {
                Compiler.compiler_set_workspace_status(.FAILED);
                return;
            }

            if !build_cpp_static_lib(lib_base_arm64, SOURCE_FILE, debug=false, extra=arm64_extra) {
                Compiler.compiler_set_workspace_status(.FAILED);
                return;
            }


            //
            // Create universal lib now:
            //

            universal_static_base   := tprint("%/%.a", "macos", LIB_BASE_NAME);
            universal_dylib_path := tprint("%/%.dylib", "macos", LIB_BASE_NAME);

            run_or_exit("lipo", "-create", tprint("%.dylib", lib_base_x64), tprint("%.dylib", lib_base_arm64), "-output", universal_dylib_path);
            run_or_exit("lipo", "-create", tprint("%.a", lib_base_x64),     tprint("%.a", lib_base_arm64),     "-output", universal_static_base);

        case .WINDOWS;
            extra := string.["-DWIN32_LEAN_AND_MEAN", "-DMA_API=__declspec(dllexport)"];

            if !build_cpp_dynamic_lib(lib_folder, SOURCE_FILE, debug=false, extra=extra) {
                Compiler.compiler_set_workspace_status(.FAILED);
                return;
            }

            if !build_cpp_static_lib(lib_folder, SOURCE_FILE, debug=false, extra=extra) {
                Compiler.compiler_set_workspace_status(.FAILED);
                return;
            }
    };

    if !generate_bindings() {
        Compiler.compiler_report("Generate bindings failed!");
        return;
    }
}

run_or_exit :: (command: .. string, working_directory := "") -> string {
    // Enable this to see the commands being executed.
    // Might be useful if, for example, you need to compile LLVM on a platform where we don’t have a Jai compiler yet and want to do it manually.
    log("Executing command \"%\" in directory \"%\"\n", join(..command, separator = " "), working_directory);

    result, output_string, error_string := run_command(..command, working_directory = working_directory, capture_and_return_output = true, print_captured_output = true);
    defer {
        free(error_string);
    }
    if result.exit_code != 0 {
        log_error("Could not run command \"%\" in directory \"%\". Exit code: %\nError:\n%", get_quoted_command_string(command), working_directory, result.exit_code, error_string);
        // if !LIVE_OUTPUT {
        //     log_error("Output:\n%", output_string);
        // }
        exit(1);
    }
    return output_string;
}

generate_bindings :: () -> bool {
    output_filename : string;

    opts : Generate_Bindings_Options;
    {
        using opts;

        array_add(*libnames, LIB_BASE_NAME);

        array_add(*source_files, SOURCE_FILE);
        array_add(*extra_clang_arguments, "-x", "c");

        #if OS == {
            case .MACOS;
                output_filename = "macos.jai";
                array_add(*libpaths, "macos");
                array_add(*extra_clang_arguments, "-isysroot", get_macos_sdk_path());

            case .WINDOWS;
                output_filename = "windows.jai";
                array_add(*libpaths, "windows");
                array_add(*extra_clang_arguments, "-DWIN32_LEAN_AND_MEAN", "-DMA_API=__declspec(dllexport)");

            case;
                #assert false "Unsupported OS";
                return false;
        }

        generate_library_declarations = false;
        auto_detect_enum_prefixes     = true;
        alias_original_enum_names     = false;

        footer = tprint(
            ifx OS == .WINDOWS then FOOTER_WINDOWS_TEMPLATE else FOOTER_UNIX_TEMPLATE,
            LIB_BASE_NAME
        );
    }

    return generate_bindings(opts, output_filename);
}

FOOTER_UNIX_TEMPLATE :: #string END

#if OS == .MACOS {
    %1 :: #library "macos/%1";
} else {
    #assert false;
}

END

FOOTER_WINDOWS_TEMPLATE :: #string END

wchar_t :: u16;
DWORDLONG :: u64;
FILE :: *void;

#if OS == .WINDOWS {
    %1 :: #library "windows/%1";
} else {
    #assert false;
}

END

#import "Basic";
#import "File";
#import "String";
#import "Process";
#import "Bindings_Generator";
#import "BuildCpp";

#if OS == .MACOS
#import "Toolchains/macOS";

Compiler :: #import "Compiler";
