#import, file "../module.jai";

#import "Basic";

main :: () {
  result : ma_result;
  engine: ma_engine;

  result = ma_engine_init(null, *engine);
  assert(result == ma_result.MA_SUCCESS);

  result = ma_engine_play_sound(*engine, "./examples/sample.mp3", null);
  assert(result == ma_result.MA_SUCCESS);

  print("All good! Playing the song!\n");

  while true {}
}
