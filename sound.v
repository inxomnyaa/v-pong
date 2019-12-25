module main

import os
import time
import miniaudio as ma

fn main() {
	os.clear()
	//load sounds
	println('Load sounds...')
	//mut sound_beep := ma.from(wav_boop_paddle)
	mut t := ma.from('./resources/sounds/click.wav')
	t.play()
	//println('Loaded wav,length '+sound_beep.length().str())
	println('Load sounds...')
	//sound_beep.play()
	println('Load sounds...')
	//time.sleep_ms(int(sound_beep.length()))
	//sound_beep.free()
	for {
		
	}
}