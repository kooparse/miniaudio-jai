#if OS == .MACOS {
  #load "macos.jai";

  #import "POSIX";
  #import "macos";

  #scope_module
  #load "macos/core_audio.jai";
} else {
  #assert(false);
}

#scope_module;

size_t  :: u64;
wchar_t :: u16;
