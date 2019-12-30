module main

import os
import time
import miniaudio as ma

fn main() {
	os.clear()
	//load sounds
    //wav_file := 'click.wav'
    //println('Loading wav')
    //mut a := ma.from(wav_file)
    mp3_file := 'click.mp3'
    println('Loading mp3')
    mut a := ma.from(mp3_file)
    length := int(a.length())

    //println('Playing wav '+length.str())
    println('Playing mp3 '+length.str())
    a.play()
    time.sleep_ms(length)

    a.free()
}
