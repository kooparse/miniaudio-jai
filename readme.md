## Jai bindings for miniaudio

miniaudio's version : v0.11.18</br>
Jai's version : beta 0.1.075b

```jai
#import "miniaudio-jai";
#import "Basic";

main :: () {
  result : ma_result;
  engine : ma_engine;

  result = ma_engine_init(null, *engine);
  assert(result == ma_result.SUCCESS);

  result = ma_engine_play_sound(*engine, "./examples/sample.mp3", null);
  assert(result == ma_result.SUCCESS);

  print("All good! Playing the song!\n");

  while true {}
}

```

### Examples

If you want to try the example, just run:

- `jai examples/example.jai && ./examples/example`

### Current operating system supported

- [x] MacOS
- [ ] Windows
- [ ] Linux

Note: PR is very welcome for missing OS.
