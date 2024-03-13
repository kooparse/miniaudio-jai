#if OS == .MACOS {
  #load "macos.jai";

  #import "POSIX";
  #import "macos";

  #scope_module
  #load "macos/core_audio.jai";
} else {
  #assert(false);
}
