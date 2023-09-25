LIB_BASE_NAME :: "miniaudio";
SOURCE_FILE   :: "source/miniaudio.c";

#run {
  Compiler.set_build_options_dc(.{ do_output = false });

  lib_folder := ifx OS == .WINDOWS {
    join("windows/", LIB_BASE_NAME);
  } else ifx OS == .MACOS {
    join("macos/", LIB_BASE_NAME);
  } else ifx OS == .LINUX {
    join("linux/", LIB_BASE_NAME);
  } 

  if !build_cpp_dynamic_lib(lib_folder, SOURCE_FILE, debug=false) {
    Compiler.compiler_set_workspace_status(.FAILED);
    return;
  }

  if !build_cpp_static_lib(lib_folder, SOURCE_FILE, debug=false) {
    Compiler.compiler_set_workspace_status(.FAILED);
    return;
  }

  if !generate_bindings() {
    Compiler.compiler_report("Generate bindings failed!");
    return;
  }
}

generate_bindings :: () -> bool {
  output_filename : string;

  opts : Generate_Bindings_Options;
  {
    using opts;

    array_add(*libnames, LIB_BASE_NAME);

    array_add(*source_files, SOURCE_FILE);
    array_add(*extra_clang_arguments, "-x", "c", "-DWIN32_LEAN_AND_MEAN");

    #if OS == .MACOS {
      output_filename = "macos.jai";
      array_add(*libpaths, "macos");
      array_add(*extra_clang_arguments, "-isysroot", get_macos_sdk_path());
    } else {
      return false;
    }

    generate_library_declarations = false;
    auto_detect_enum_prefixes     = true;
    alias_original_enum_names     = false;

    footer = tprint(FOOTER_UNIX_TEMPLATE, LIB_BASE_NAME);
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


#import "Basic";
#import "String";
#import "Bindings_Generator";
#import "BuildCpp";

Compiler :: #import "Compiler";
