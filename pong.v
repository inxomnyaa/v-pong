module main

import time
import gx
//import gl
import gg
import glfw
import freetype

const (
	Width = 1000 //px windows
	Height = 500 //px window
	PaddleHeight = 10 //px
	PaddleWidth = 40 //px
	PaddleSpeedComputer = 4 //px/s
	PaddleSpeed = 5 //px/s
	PaddlePadding = 20 //px from top/bottom
	TickSpeed = 10 //ms refresh rate
	BallSize = 25 //px
	BallVelocity = 1 //px/s movement speed
	TextSize = 12 //px
)

const (
	text_cfg = gx.TextCfg{
		align:gx.ALIGN_LEFT
		size:TextSize
		color:gx.Green
	}
	over_cfg = gx.TextCfg{
		align:gx.ALIGN_LEFT
		size:TextSize
		color:gx.White
	}
)

const (
	BackgroundColor = gx.Black
	UIColor = gx.Purple
	PaddleColor = gx.Green
)

struct PaddleComputer {
mut:
    x int
    score int
}

struct PaddlePlayer {
mut:
    x int
    score int
}

struct Ball {
mut:
	x int
	y int
	dx int
	dy int
	speed int
	collided bool
}

struct Game {
mut:
	height int
	width int
	ball Ball
	player PaddlePlayer
	computer PaddleComputer
	// gg context for drawing
	gg          &gg.GG
	// ft context for font drawing
	ft          &freetype.FreeType
	font_loaded bool
}

fn main() {
	glfw.init_glfw()
	mut game := &Game{
		gg: gg.new_context(gg.Cfg {
			width: Width
			height: Height
			use_ortho: true // This is needed for 2D drawing
			create_window: true
			window_title: 'V Pong'
			window_user_ptr: game
		})
		ft: 0
		height: Height 
		width: Width
	}
	game.gg.window.set_user_ptr(game) // TODO remove this when `window_user_ptr:` works
	game.init_game()
	println('Starting the game loop...')
	game.gg.window.onkeydown(key_down)
	go game.run() // Run the game loop in a new thread
	gg.clear(BackgroundColor)
	// Try to load font
	game.ft = freetype.new_context(gg.Cfg{
			width: Width
			height: Height
			use_ortho: true
			font_size: 18
			scale: 2
	})
	game.font_loaded = (game.ft != 0 )
	for {
		gg.clear(BackgroundColor)
		game.draw_scene()
		game.gg.render()
		if game.gg.window.should_close() {
			game.gg.window.destroy()
			return
		}
	}
}

fn (g mut Game) init_game() {
	println('Init game...')
	//mut ball := &Ball{
	g.ball = Ball{
		//x: g.width / 2
		//y: g.height / 2
		x: (g.player.x + ((PaddleWidth+BallSize) / 2))
		y: (g.height - PaddlePadding - PaddleHeight)
		dx: BallVelocity
		dy: -BallVelocity
		collided: false
	}
	g.player = PaddlePlayer{
		x: 10
	}
	g.computer = PaddleComputer{
		x: 10
	}
}

fn (g mut Game) reset() {
	println('Reset ball...')
	g.ball = Ball{
		//x: g.width / 2
		//y: g.height / 2
		x: (g.player.x + ((PaddleWidth+BallSize) / 2))
		y: (g.height - PaddlePadding - PaddleHeight)
		dx: BallVelocity
		dy: -BallVelocity
		collided: false
	}
	g.computer = PaddleComputer{
		x: 10
	}
}

//fn (g mut Game) draw_scene() {
fn (g mut Game) draw_scene() {
	g.draw_ball()
	g.draw_paddle()
	//g.draw_field()
	//g.draw_ui()
	g.draw_debug()
}

fn (g &Game) draw_ball() {
		color := UIColor
		g.gg.draw_rect(g.ball.x, g.ball.y,
			BallSize, BallSize, color)
}

fn (g &Game) draw_paddle() {
		color := PaddleColor
		g.gg.draw_rect(g.computer.x, PaddlePadding,
			PaddleWidth, PaddleHeight, color)
		g.gg.draw_rect(g.player.x, g.height - (PaddlePadding + PaddleHeight),
			PaddleWidth, PaddleHeight, color)
}

fn (g mut Game) run() {
	for {
		g.move_computer()
		g.check_ball_collision()
		g.move_ball()
		//ball.speed = ball.speed + SPEEDINCREASE
		//g.ball.dx *= ball.speed
		//g.ball.dy *= ball.speed
		//println('bdx $g.ball.dx bdy $g.ball.dy')
		// Refresh
		glfw.post_empty_event() // force window redraw
		time.sleep_ms(TickSpeed)
	}
}

fn (g mut Game) move_ball() {
	//if g.ball.y >= g.height - Height || g.ball.y <= 0 {
		//if g.ball.collided || g.ball.y >= (g.height - PaddlePadding){//TODO remove or when player added
		if g.ball.collided{
			println('ball bounce paddle')
			g.ball.dy = - g.ball.dy
			g.ball.collided = false
		}
		//TODO else score
	//if g.ball.x >= g.width - Width || g.ball.x <= 0 {
	//bounce from side walls
	if g.ball.x >= g.width - BallSize || g.ball.x <= 0 {
		g.ball.dx = - g.ball.dx
	}
	if(g.ball.y > (g.height - BallSize)){
		//Computer scored
		g.computer.score += 1
		g.reset()
		return
	}
	if(g.ball.y < BallSize){
		//Player scored
		g.player.score += 1
		g.reset()
		return
	}
	g.ball.x += g.ball.dx
	g.ball.y += g.ball.dy
}

fn (g mut Game) move_computer() {
	ball := g.ball
	//TODO target center of ball with center of target
	//if ball further left move left
	if ball.x < g.computer.x {
		g.computer.x -= PaddleSpeedComputer
	}
	//if ball further right move right
	else if ball.x > g.computer.x {
		g.computer.x += PaddleSpeedComputer
	}
	if(g.computer.x < 0){
		 g.computer.x = 0
	}
	if(g.computer.x > (g.width - PaddleWidth)){
		g.computer.x = (g.width - PaddleWidth)
	}
}

fn (g mut Game) check_ball_collision() {
	ball := g.ball
	//computer := g.computer
	//player := g.player
	//top (computer) paddle
	//if(ball.y <= (PaddlePadding + PaddleHeight) && (ball.y + ball.dy) >= PaddlePadding){
	if(ball.dy < 0 && ball.y <= (PaddlePadding + PaddleHeight) && (ball.y) >= PaddlePadding
	&& ball.x > (g.computer.x - BallSize) && ball.x <= (g.computer.x + PaddleWidth)){
		g.ball.collided = true
		println('ball collided computer')
	}
	//bottom (player) paddle
	//if(ball.y <= (g.height - PaddlePadding - PaddleHeight) && (ball.y + ball.dy) >= (g.height - PaddlePadding)){
	//if(ball.y <= (g.height - PaddlePadding - PaddleHeight) && (ball.y) >= (g.height - PaddlePadding)){
	if(ball.dy > 0 && (ball.y + BallSize) >= (g.height - PaddlePadding - PaddleHeight) && (ball.y + BallSize) <= (g.height - PaddlePadding)
	&& ball.x > (g.player.x - BallSize) && ball.x <= (g.player.x + PaddleWidth)){
		g.ball.collided = true
		println('ball collided player')
	}
	if(g.ball.collided){
		println('BALL COLLIDED')
	}
}

fn (g mut Game) draw_debug() {
	if g.font_loaded {
		g.ft.draw_text((g.ball.x + BallSize), (g.ball.y + BallSize), '$g.ball.x $g.ball.y', text_cfg)
		g.ft.draw_text(5, 5, 'Score: $g.computer.score', text_cfg)
		g.ft.draw_text(5, 2 + 5 + TextSize, '$g.computer.x', text_cfg)
		mut text := ''
		if(g.ball.dy < 0){ text = 'Moving up'}
		else {text = 'Moving down'}
		g.ft.draw_text(5, 5 + TextSize * 3, text, text_cfg)
		g.ft.draw_text(5, 5 + TextSize * 4, 'Collided: $g.ball.collided', text_cfg)
		g.ft.draw_text(5, g.height - 5 - TextSize, 'Score: $g.player.score', text_cfg)
		g.ft.draw_text(5, g.height - 2 - 5 - TextSize - TextSize, '$g.player.x', text_cfg)
	}
}

// TODO: this exposes the unsafe C interface, clean up
fn key_down(wnd voidptr, key, code, action, mods int) {
	println(action.str())
	if action != 2 && action != 1 {
		return
	}
	// Fetch the game object stored in the user pointer
	mut game := &Game(glfw.get_window_user_pointer(wnd))
	// global keys
	//match key {
	//	glfw.KEY_ESCAPE {
	//		glfw.set_should_close(wnd, true)
	//	}
	//	glfw.key_space {
	//		if game.state == .running {
	//			game.state = .paused
	//		} else if game.state == .paused {
	//			game.state = .running
	//		} else if game.state == .gameover {
	//			game.init_game()
	//			game.state = .running
	//		}
	//	}
	//	else {}
	//}

	//if game.state != .running {
	//	return
	//}
	// keys while game is running
	match key {
	glfw.KeyLeft {
		game.move_right(-PaddleSpeed)
	}
	glfw.KeyRight {
		game.move_right(PaddleSpeed)
	}
	else { }
	}
}

fn (g mut Game) move_right(dx int) bool {
	g.player.x += dx
	
	if(g.player.x < 0){
		 g.player.x = 0
	}
	if(g.player.x > (g.width - PaddleWidth)){
		g.player.x = (g.width - PaddleWidth)
	}
	return true
}