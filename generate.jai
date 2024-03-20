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

  extra : []string;

  #if OS == {
  case .MACOS;
    options := Compiler.get_build_options();
    args    := options.compile_time_command_line;
    cpu     := ifx array_find(args, "-arm64") then CPU_Tag.ARM64 else .X64;
    target  := get_macos_target_triple(cpu, 14, 0);
    extra = string.[ "-target", target ];

  case .WINDOWS;
    extra = string.["-DWIN32_LEAN_AND_MEAN", "-DMA_API=__declspec(dllexport)"];
  };

  if !build_cpp_dynamic_lib(lib_folder, SOURCE_FILE, debug=false, extra=extra) {
    Compiler.compiler_set_workspace_status(.FAILED);
    return;
  }

  if !build_cpp_static_lib(lib_folder, SOURCE_FILE, debug=false, extra=extra) {
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
#import "Bindings_Generator";
#import "BuildCpp";

#if OS == .MACOS
  #import "Toolchains/macOS";

Compiler :: #import "Compiler";
