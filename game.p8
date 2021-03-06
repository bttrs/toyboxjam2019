pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- TODO's prioritised:
-- (* first player attack, still needs hitbox detection) 
-- * first enemy
-- * difficulty (gradually increase enemy strength)
-- * sound / sfx
-- thats the mvp. the game is playable :D
-- TODO's after mvp, not prioritised:
-- * highscore (maybe # of cleared rooms?)
-- * loot (second player attack)
-- * chest with key (key is loot in another room?)
-- * door with key (key is loot in another room?)
-- * story (at the beginning, an explanation on how you got there?)
-- * player dash/roll (maybe this should be prioritised quite high, since it increases the fun imo)
-- * ???


-- toy box jam start cart
-- by that tom hall & friends
-- sprites/sfx/code: that tom hall
-- sprites/sfx: lafolie
-- platforming anims: toby hefflin
-- music: gruber
-- additional code: see functions
-- if you did a function that is
-- uncredited, let me know!
-------------------------------
-- this contains a set of
-- creative assets to play
-- with. everyone has the same
-- set of "toys"... what will
-- you make of 'em?
-------------------------------
-- resources:
--
-- random useful sprites
--  (just go look or see asset list!)
-- random useful sfx
-- -00-21:sfx
-- -22-59:songs
-- -60-63:sfx

-- songs: by gruber
-- 00 happy land
-- 06 chill
-- 12 scary dungeon
-- 18 fight
-- 21 evil
-- 23 defeat
-- 24 celebrate
-- 25 puzzle
-- 29 sand

-- 33 read or wait my dude by that tom hall
-- (not on gruber level, but useful)
-------------------------------
function _init()
	setup_asciitables()
	game_manager.init()	
end

function _update60()
	game_manager.update()
end

function _draw()
	game_manager.draw()
end

game_manager={
	state=0,
}

game_states={
	title=0,
	play=1,
	gameover=2,
}

function game_manager.init()
	title_manager.init()
end

function game_manager.update()
	utils.update()
	if game_manager.state == game_states.title then
		title_manager.update()
	elseif game_manager.state == game_states.play then
		play_manager.update()
	elseif game_manager.state == game_states.gameover then
		gameover_manager.update()
	end
end

function game_manager.draw()
	if game_manager.state == game_states.title then
		title_manager.draw()
	elseif game_manager.state == game_states.play then
		play_manager.draw()
	elseif game_manager.state == game_states.gameover then
		gameover_manager.draw()
	end
end

function game_manager.switch_state(state)
	game_manager.state = state
	if game_manager.state == game_states.title then
		title_manager.init()
	elseif game_manager.state == game_states.play then
		play_manager.init()
	elseif game_manager.state == game_states.gameover then
		gameover_manager.init()
	end
end

title_manager={
	room={},
	roomba={},
}

function title_manager.init()
	play_manager.init()
	printh("init title screen")
	title_manager.room=generate_room(dry_room, 0,0,0, true)

	title_manager.roomba = roomba:new()
	title_manager.roomba.nocontrol = true
	title_manager.roomba.x = 64
	title_manager.roomba.y = 70
	title_manager.roomba.hull_rotation = 270
	music_manager.music(6)
end

function title_manager.update()
	local speed = 0.5
	
	title_manager.roomba:update()
	if title_manager.roomba.hull_rotation == 90 then
		title_manager.roomba.x -= speed
		if title_manager.roomba.x == 22 then
			title_manager.roomba.hull_rotation = 180
		end
	elseif title_manager.roomba.hull_rotation == 270 then
		title_manager.roomba.x += speed
		if title_manager.roomba.x == 98 then 
			title_manager.roomba.hull_rotation = 0
		end
	elseif  title_manager.roomba.hull_rotation == 180 then
		title_manager.roomba.y -= speed
		if title_manager.roomba.y == 70 then 
			title_manager.roomba.hull_rotation = 270
		end
	elseif  title_manager.roomba.hull_rotation == 0 then
		title_manager.roomba.y += speed
		if title_manager.roomba.y == 90 then 
			title_manager.roomba.hull_rotation = 90
		end
	end

	if btnp(❎) then
		sfx(1)
		game_manager.switch_state(game_states.play)
	end
end

function title_manager.draw()
	cls()
	draw_room(title_manager.room)

	offset = sin(utils.mstime/5) * 5
	y = 16

	title_manager.roomba:draw()
	dsprintxy("roomba", y,23+offset, 7, 2, 1)
	dsprintxy("nator!", y,38+offset, 7, 2, 1)
	printo("press ❎ to start", 30, 108, 7, 1)
end

gameover_manager={
	room={},
	music_delay=2, --in seconds, since the gameover sfx is a song actually
	music_start=0,
}

function gameover_manager.init()
	printh("init gameover screen")
	gameover_manager.room=generate_room(dry_room, 0,0,0, true)
	gameover_manager.music_start = utils.mstime + gameover_manager.music_delay
	music_manager.music(23)
end

function gameover_manager.update()
	utils.update()
	if gameover_manager.music_start > -1 and utils.mstime > gameover_manager.music_start then
		game_manager.music_start = -1
		music_manager.music(25, 5000)
	end
	if btnp(❎) then
		sfx(1)
		game_manager.switch_state(game_states.title)
	end
end

function gameover_manager.draw()
	cls()
	draw_room(gameover_manager.room)

	offset = sin(utils.mstime/5) * 5
	y = 32
	
	dsprintxy("game", y,23+offset, 8, 2, 1)
	dsprintxy("over", y,38+offset, 8, 2, 1)
	printo("press ❎ to restart", 30, 108, 7, 1)

	palt(5, true)
	palt(6, true)
	sprintc("you cleaned",8.5,7)	
	
	palt(5, true)
	palt(6, true)
	local l = flr(play_manager.cleared_rooms/10)+1
	local y = 64-(l*8)
	dsprintxy(play_manager.cleared_rooms.."",y, 75, 7)
	
	palt(5, true)
	palt(6, true)
	sprintc("rooms",11.2,7)

	palt()

	-- print("you cleaned "..play_manager.cleared_rooms.." rooms", 20,50)
	
end
-->8
-- play manager tab
play_manager={}

music_manager={
	current_song=-1
}

function music_manager.music(n, fadems)
	if music_manager.current_song != n then
		music_manager.current_song = n
		music(n, fadems)
	end
end

function play_manager.init()
	debug=false
	solids = {}
	moving_solids = {}
	trigger = {} -- {{x,y,w,h,type}}
	moving_trigger = {}
	projectiles={}
	--rooms_init()
	--char.init()
	play_manager.rooms = {}
	play_manager.cleared_rooms = 0
	play_manager.current_room_id = 1
	play_manager.room_id_seq = 1
	room = generate_room(default_room)
	play_manager.rooms[1] = room
	play_manager.roomba = roomba:new()
	load_room(room)
	music_manager.music(0)

	--p = projectile:new(30,30,utils.dir_d)
end

function play_manager.update()

	update_room(play_manager.rooms[play_manager.current_room_id])

	play_manager.roomba:update()
	foreach(projectiles, function(p) p:update() end)
	-- for debug
	debug_btnp()
end


function debug_btnp()
	if btnp(5) and btnp(4) then
		if debug then
			debug = false
		else
			debug = true
		end
		printh("toggle debug")
	end
end

function play_manager.draw()
	cls ()
	draw_room(play_manager.rooms[play_manager.current_room_id])
	
	foreach(projectiles, function(p) p:draw() end)

	play_manager.roomba:draw()
	if debug then
		foreach(solids, debug_draw_solids)
		foreach(trigger, debug_draw_trigger)
		foreach(moving_solids, debug_draw_moving_solids)
		foreach(moving_trigger, debug_draw_moving_trigger)

		--count generated rooms
		room_cnt = 0
		for k,v in pairs(play_manager.rooms) do
			room_cnt+=1
		end
		print("mstime: "..utils.mstime, 15,9)
		print("mem: "..flr(stat(0)).."KiB".." fps: "..stat(7), 15, 15)
		print("t-cpu: "..(flr(stat(1)*100)/100).." s-cpu: "..(flr(stat(2)*100)/100), 15, 21)
		print("roomnr: "..play_manager.current_room_id, 15, 27)
		print("rooms generated: "..room_cnt, 15, 33)
		print("solids amount: "..#solids+#moving_solids, 15, 39)
		print("trigger amount: "..#trigger+#moving_trigger, 15, 45)
		print("x: "..play_manager.roomba.x.." y: "..play_manager.roomba.y, 15, 51)
	end
end

function play_manager.mob_triggered(mob)
	local room = play_manager.rooms[play_manager.current_room_id]
	del(room.enemies, mob)
	sfx(2)
end

function play_manager.room_cleared()
	play_manager.cleared_rooms+=1
end

function play_manager.door_triggered(door)
	solids = {}
	trigger = {}
	projectiles = {}

	id = door.next_room_id
	printh("triggered room: "..id..", current room: "..play_manager.current_room_id)
	rev_dir =  reverse_dir(door.dir)
	if play_manager.rooms[id] == nil then
		--  generate_room(room_set, door_enter_pos, door_enter_id, difficulty)
		-- difficulty is the next room id since this is incrementing
		play_manager.rooms[id] = generate_room(get_random_room_set(), rev_dir, play_manager.current_room_id, id)
	end
	play_manager.current_room_id = id
	load_room(play_manager.rooms[id])
	play_manager.roomba.x = 64
	play_manager.roomba.y = 64
	if rev_dir == utils.dir_u then
		play_manager.roomba.y = 108
	elseif rev_dir == utils.dir_d then
		play_manager.roomba.y = 20
	elseif rev_dir == utils.dir_l then
		play_manager.roomba.x = 20
	elseif rev_dir == utils.dir_r then
		play_manager.roomba.x = 108
	end
	sfx(5)
end

function play_manager.next_room_nr()
	play_manager.room_id_seq += 1
	printh("next room id: "..play_manager.room_id_seq)
	return play_manager.room_id_seq
end

function debug_draw_solids(obj)
	rect(obj.x, obj.y, obj.x+obj.w-1, obj.y+obj.h-1, 8)
end

function debug_draw_moving_solids(obj)
	rect(obj.x, obj.y, obj.x+obj.w-1, obj.y+obj.h-1, 9)
end

function debug_draw_moving_trigger(obj)
	x = obj.x+obj.triggerbox.x
	y = obj.y+obj.triggerbox.y
	w = x + obj.triggerbox.w-1
	h = y + obj.triggerbox.h-1
	rect(x, y, w, h, 10)
end

function debug_draw_trigger(obj)
	x = obj.x+obj.triggerbox.x
	y = obj.y+obj.triggerbox.y
	w = x + obj.triggerbox.w-1
	h = y + obj.triggerbox.h-1
	rect(x, y, w, h, 3)
end

-->8
-- roomba!
roomba={
	x=64,
	y=64,
	w=8,
	h=8,
	triggerbox={x=0,y=0,w=9,h=9}, -- these are relative values
	sprites={
		hull=84,
		vacuum=0
	},
	hitpoints=5,
	vacuum_rotation=0,
	vacuum_rotation_speed=.1, -- every x seconds a new rotation update
	vacuum_rotation_amount=10, -- degrees to turn
	vacuum_next_rotation_time=0,
	hull_rotation=0,
	nocontrol=false,
	speed=1,
	-- (init function) direction=utils.dir_r, -- left, up, right or down
	-- (init function) look_direction=utils.dir_r, -- only left or right (used for mirroring of sprites)
	anim=nil,
	state=0,
	state_start_time=0,
	attackbox=nil
}

function roomba:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.anim = myannimator:new()
	o.anim:setsprite(o.sprites.idle, 30)
	o.trigger_type = trigger_type.mob
	o.vacuum_next_rotation_time += o.vacuum_rotation_speed
	o.trigger_type=trigger_type.roomba
	o.direction=utils.dir_d
	-- o.state =

	-- random placement, inside room
	-- should be replaced with a function that considers solids
	o.x = (flr(rnd(88))+16)
	o.y = (flr(rnd(88))+16)
	return o
end

function roomba:update()
	add(moving_solids, self)
	if utils.mstime > self.vacuum_next_rotation_time then
		self.vacuum_rotation += self.vacuum_rotation_amount
		self.vacuum_rotation = self.vacuum_rotation % 360
	end

	if self.nocontrol == false then
		self:update_idle()
	end
end

function roomba:update_idle()
	local char_copy = {}--copy(self)
	char_copy.x = self.x
	char_copy.y = self.y
	char_copy.w = self.w
	char_copy.h = self.h
	char_copy.direction = self.direction
	char_copy.triggerbox = self.triggerbox
	x_dir = nil
	y_dir = nil
	local speed = self.speed

	if btn(⬆️) then
		y_dir = utils.dir_u
	elseif btn(⬇️) then
		y_dir = utils.dir_d
	end
	if btn(➡️) then
		x_dir = utils.dir_r
	elseif btn(⬅️) then
		x_dir = utils.dir_l
	end


	if x_dir!=nil and y_dir!=nil then
		speed = sqrt(speed*speed/2)
	end

	if not (x_dir == nil and y_dir == nil) then 
		char_copy.direction = utils.combine_dirs(x_dir, y_dir)
	end

	if y_dir == utils.dir_u then
		char_copy.y -= speed
	elseif  y_dir == utils.dir_d then
		char_copy.y += speed
	end
	if x_dir == utils.dir_r then
		char_copy.x += speed
		char_copy.look_direction=utils.dir_r
	elseif x_dir == utils.dir_l then
		char_copy.x -= speed
		char_copy.look_direction=utils.dir_l
	end

	c = is_colliding(char_copy)
	if c == nil or c.trigger_type == trigger_type.roomba then
		self.x = char_copy.x
		self.y = char_copy.y
		self.direction=char_copy.direction
		self.hull_rotation=direction_to_degrees(self.direction)
	end

	t = is_triggering(self)
	if t != nil then
		if t.trigger_type==trigger_type.door and t.unlocked then
			play_manager.door_triggered(t)
		elseif t.trigger_type==trigger_type.mob then
			play_manager.mob_triggered(t)
			
		end
	end
end

function roomba:draw()
	spr_r_vac(self.sprites.vacuum, self.x, self.y, self.vacuum_rotation, 1,1)
	spr_r(self.sprites.hull, self.x, self.y, self.hull_rotation, 1,1)
	if debug then
		rect(self.x, self.y, self.x+self.w, self.y+self.h, 4)
	end
	if self.nocontrol == false then
		self:draw_hitpoints()
	end
end

function roomba:draw_hitpoints()
	local x = 1
	local y = 0
	local sprite = 64
	for i=1,self.hitpoints do
		spr(sprite,x,y)
		x += 10
	end
end

function roomba:hit()
	self.hitpoints -= 1
	if self.hitpoints <= 0 then
		printh("dead")
		game_manager.switch_state(game_states.gameover)
	end
end


function direction_to_degrees(direction)
	-- d	(7) 	= 0
	-- dl	(8) 	= 45
	-- l	(1) 	= 90
	-- ul	(2)	= 135
	-- u	(3) 	= 180
	-- etc
	d = direction - 7
	d = d % 8

	return d*45
end

-->8
-- char tab
char={
	x=64,
	y=64,
	w=8,
	h=8,
	triggerbox={x=0,y=0,w=8,h=8}, -- these are relative values
	speed=1,
	-- (init function) direction=utils.dir_r, -- left, up, right or down
	-- (init function) look_direction=utils.dir_r, -- only left or right (used for mirroring of sprites)
	anim=nil,
	state=0,
	state_start_time=0,
	attackbox=nil
}

char_animation={
	a_idle={128,129},
	a_run={144,145,146,147,146,145},
	a_attack={176,177,177,177,177,177},
}

char_anim_state={
	idle=0,
	melee_attack=1
}

function char.init()
	char.anim = myannimator:new()
 	char.anim:setsprite(char_animation.a_idle)
	char.direction = utils.dir_r
	char.look_direction = utils.dir_r
end


function char.draw()
	spr(char.anim:getsprite(), char.x, char.y,1, 1, char.look_direction==utils.dir_l)
	if char.state == char_anim_state.melee_attack then
		char.draw_attack()
	end
	if debug then
		rect(char.x, char.y, char.x+char.w, char.y+char.h, 4)
		if char.attackbox != nil then
			rect(char.x+char.attackbox.x, char.y+char.attackbox.y,char.x+char.attackbox.x+char.attackbox.w,  char.y+char.attackbox.y+char.attackbox.h, 2)
		end
	end
	if is_colliding(char) != nil then
		print("colliding",0,0,7)
	end
end

function char.draw_attack()
	local multi = 1
	local flip = char.look_direction == utils.dir_l
	if flip then
		multi = -1
	end
	offset_y = char.y
	offset_x = char.x + (8 * multi)
	if (char.anim.i==2) then
		--make other colors transparent
		--make this frame's whip ones whip color
		palt(4,true) --particle btm
		palt(9,true) --particle mid
		palt(10,true) -- particle top
		palt(1,true) -- landed whip
		pal(5,13) -- change gray to whip
		spr(178,offset_x,offset_y,1,1,flip)
		palt() -- restore all of it
		pal()
	elseif (char.anim.i==3) then
		--make other colors transparent
		--make this frame's whip ones whip color
		palt(4,true) --particle top
		palt(9,true) --particle mid
		palt(10,true) -- particle btm
		palt(5,true) -- curled whip
		pal(1,13) -- change dk blue to whip
		spr(178,offset_x,offset_y,1,1,flip)
		palt() -- restore all of it
		pal()
	elseif (char.anim.i==4) then
		--make other colors transparent
		--make this frame's whip ones whip color
		palt(4,true) --particle top
		palt(9,true) --particle mid
		--palt(10,true) -- particle btm
		palt(5,true) -- curled whip
		pal(1,13) -- change dk blue to whip
		spr(178,offset_x,offset_y,1,1,flip)
		palt() -- restore all of it
		pal()
	elseif (char.anim.i==5) then
		palt(4,true) --particle top
		--palt(9,true) --particle mid
		palt(10,true) -- particle btm
		palt(5,true) -- curled whip
		pal(1,13) -- change dk blue to whip
		spr(178,offset_x,offset_y,1,1,flip)
		palt() -- restore all of it
		pal()
	elseif (char.anim.i==6) then
		--palt(4,true) --particle top
		palt(9,true) --particle mid
		palt(10,true) -- particle btm
		palt(5,true) -- curled whip
		pal(1,13) -- change dk blue to whip
		spr(178,offset_x,offset_y,1,1,flip)
		palt() -- restore all of it
		pal()
	end
end

function char.check_attack_btn()
	if btnp(5) and not btnp(6) then
		char.anim:setsprite(char_animation.a_attack, 7, true)
		char.state = char_anim_state.melee_attack
		char.state_start_time = utils.mstime
	end
end

-- man kann scheinbar nicht  im update zeichnen <- stimmt
function char.update()
	if char.state == char_anim_state.idle then
		char.idle()
	elseif char.state == char_anim_state.melee_attack then
		char.update_melee_attack()
	end

	char.anim:update()
end

function char.get_melee_hitzone() 
	local multi = 1
	local w = 7
	local h = 6
	local offset = 8
	local flip = char.look_direction == utils.dir_l
	if flip then
		multi = -1
		offset = w
	end
	local y = 3
	local x = offset * multi
	-- printh("attackbox: {x="..x..", y="..y..", w="..w..", h="..h.."}")
	local triggerbox={x=x, y=y, w=w, h=h}
	local attackbox={x=x+char.x, y=y+char.y, w=w+char.w, h=h+char.h, triggerbox=triggerbox}
	return attackbox
end

function char.check_target_hit()
	if char.attackbox == nil then
		return
	end
	foreach(moving_trigger, function(t)
		d=t
		printh("{x="..d.x..", y="..d.y..", w="..d.w..", h="..d.h.."}")
		printh("triggerbox: {x="..d.triggerbox.x..", y="..d.triggerbox.y..", w="..d.triggerbox.w..", h="..d.triggerbox.h.."}")

	end)
	local obj = is_triggering(char.attackbox, false)
	
	if obj != nil then
		printh("attack: "..obj.trigger_type)
	else
		--printh("attack: nothing")
	end
end



function char.update_melee_attack() 
	local attack_length = .680

	
	if char.anim.i==4 or char.anim.i==5 then
		char.attackbox = char.get_melee_hitzone()
		char.check_target_hit()
	else
		char.attackbox = nil
	end

	if utils.mstime > attack_length + char.state_start_time then
		char.state = char_anim_state.idle
	end
end

function char.idle()
	char.anim:setsprite(char_animation.a_idle,10)
	char_copy = copy(char)
	x_dir = nil
	y_dir = nil
	local speed = char.speed

	if btn(⬆️) then
		y_dir = utils.dir_u
	elseif btn(⬇️) then
		y_dir = utils.dir_d
	end
	if btn(➡️) then
		x_dir = utils.dir_r
	elseif btn(⬅️) then
		x_dir = utils.dir_l
	end


	if not x_dir==nil and not y_dir==nil then
		speed = sqrt(speed*speed/2)
	end

	if not x_dir == nil and not y_dir == nil then 
		char_copy.direction = utils.combine_dirs(y_dir, y_dir)
	end

	if y_dir == utils.dir_u then
		char_copy.y -= speed
		char_copy.anim:setsprite(char_animation.a_run)
	elseif  y_dir == utils.dir_d then
		char_copy.y += speed
		char_copy.anim:setsprite(char_animation.a_run)
	end
	if x_dir == utils.dir_r then
		char_copy.x += speed
		char_copy.anim:setsprite(char_animation.a_run)
		char_copy.look_direction=utils.dir_r
	elseif x_dir == utils.dir_l then
		char_copy.x -= speed
		char_copy.anim:setsprite(char_animation.a_run)
		char_copy.look_direction=utils.dir_l
	end

	if is_colliding(char_copy) == nil then
		char = char_copy
	end

	t = is_triggering(char)
	if t != nil and t.trigger_type==trigger_type.door then
		play_manager.door_triggered(t)
	end

	char.check_attack_btn()
end

-->8
-- enemy tab

-- enemy default values
enemy={
	--hitpoints=3,
	x=64,
	y=64,
	w=8,
	h=8,
	triggerbox={x=-1,y=-1,w=10,h=10}, -- these are relative values
	speed=1,
	attackspeed=2, --attacks every x seconds
	next_attack_time=0,
	diagonal_attack=0,
	with_diag=false,
	sprites={
		idle={102,103},
		attack={102,103}
	},
	anim=nil,
}

function enemy:new(difficulty, o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.difficulty = difficulty or 1
	o.anim = myannimator:new()
	o.anim:setsprite(o.sprites.idle, 30)
	o.trigger_type = trigger_type.mob
	o.next_attack_time = utils.mstime + (o.attackspeed / 3)

	local r = flr(rnd(3))
	if r == 0 then
		o.with_diag = true
	end

	if o.difficulty >= 5 then
		o.attackspeed = 1.5
	elseif o.difficulty >= 20 then
		o.attackspeed = 1
	end 
	if o.difficulty <= 10 then
		o.diagonal_attack=flr(rnd(2))
	end
	-- o.state =

	-- random placement, inside room
	-- should be replaced with a function that considers solids
	o.x = (flr(rnd(88))+16)
	o.y = (flr(rnd(88))+16)
	return o
end

function enemy:update()
	if utils.mstime > self.next_attack_time then
		self:attack()
		self.next_attack_time += self.attackspeed
	end
end

function enemy:attack()
	sfx(0)
	if self.difficulty <= 15 then
		if self.diagonal_attack==1 then
			projectile:new(self.x,self.y,utils.dir_ul)
			projectile:new(self.x,self.y,utils.dir_ur)
			projectile:new(self.x,self.y,utils.dir_dl)
			projectile:new(self.x,self.y,utils.dir_dr)
		else
			projectile:new(self.x,self.y,utils.dir_l)
			projectile:new(self.x,self.y,utils.dir_u)
			projectile:new(self.x,self.y,utils.dir_r)
			projectile:new(self.x,self.y,utils.dir_d)
		end
	else
		if self.diagonal_attack==1 then
			projectile:new(self.x,self.y,utils.dir_ul)
			projectile:new(self.x,self.y,utils.dir_ur)
			projectile:new(self.x,self.y,utils.dir_dl)
			projectile:new(self.x,self.y,utils.dir_dr)
		else
			projectile:new(self.x,self.y,utils.dir_l)
			projectile:new(self.x,self.y,utils.dir_u)
			projectile:new(self.x,self.y,utils.dir_r)
			projectile:new(self.x,self.y,utils.dir_d)
		end
		if self.with_diag then
			self.diagonal_attack += 1
			self.diagonal_attack = self.diagonal_attack%2
		end
	end
end

function enemy:draw()
	self.anim:update()
	spr(self.anim:getsprite(), self.x, self.y)
end

projectile={
	x=64,
	y=64,
	w=8,
	h=8,
	speed_x=0,
	speed_y=0,
	direction=0,
	triggerbox={x=-1,y=-1,w=10,h=10}, -- these are relative values
	speed=1,
	sprites={95,94},
	anim=nil
}

function projectile:new(x,y,dir,o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.anim = myannimator:new()
	o.anim:setsprite(o.sprites)
	o.x=x
	o.y=y
	o.direction=dir
	o.speed_x = utils.dir_to_speed_x(dir, o.speed)
	o.speed_y = utils.dir_to_speed_y(dir, o.speed)
	add(projectiles, o)
	return o
end

function projectile:update()
	self.x += self.speed_x
	self.y += self.speed_y
	t = is_colliding(self)
	if t != nil and t.trigger_type != trigger_type.mob then
		sfx(11)
		if t.trigger_type == trigger_type.roomba then
			sfx(14)
			t:hit()
		end
		del(projectiles, self)
		return
	end
	self.anim:update()
end

function projectile:draw()
	spr(self.anim:getsprite(), self.x, self.y)
end

-->8
-- utils
utils={
 mstime=0, --yes i know this was a stupid mistake and the term is also wrong now
 dir_l=1, -- left
 dir_ul=2, -- up left
 dir_u=3, -- up
 dir_ur=4, -- up right 
 dir_r=5, -- right
 dir_dr=6, -- down right
 dir_d=7, -- down
 dir_dl=8, -- down left
}

trigger_type={
	door=0,
	mob=1,
	roomba=2,
}


function utils.update()
	utils.mstime=time()
end

myannimator= {
  i = 1,
  frames = 1,
  everyxframe = 10;
  arr = {},
}

function utils.dir_to_speed_x(dir, groundspeed)
	groundspeed = groundspeed or 1
	if dir == utils.dir_l then
		return groundspeed * -1
	elseif dir == utils.dir_ul or dir==utils.dir_dl then
		return sqrt(groundspeed*groundspeed/2) * -1
	elseif dir == utils.dir_u or dir == utils.dir_d then
		return 0
	elseif dir == utils.dir_ur or dir == utils.dir_dr then
		return sqrt(groundspeed*groundspeed/2)
	elseif dir == utils.dir_r then
		return groundspeed
	end
end

function utils.dir_to_speed_y(dir, groundspeed)
	groundspeed = groundspeed or 1
	if dir == utils.dir_l or dir == utils.dir_r then
		return 0
	elseif dir == utils.dir_ul or dir==utils.dir_ur then
		return sqrt(groundspeed*groundspeed/2) * -1
	elseif dir == utils.dir_u then
		return groundspeed * -1
	elseif dir == utils.dir_dl or dir == utils.dir_dr then
		return sqrt(groundspeed*groundspeed/2)
	elseif dir == utils.dir_d then
		return groundspeed
	end
end

function utils.combine_dirs(dir_1, dir_2)
	-- make one direction from two, e.g. dir_u + dir_l = dir_ul
	-- this only works for dirs that are 90° apart.
	-- this is based on the numbering of directions:
	-- left, up, right, down being odd numbers and the directions in between
	-- are even.
	if dir_1 == nil and dir_2 == nil then
		errtxt = "[utils.combine_dirs] cannot combine two nil values"
		printh(errtxt)
		stop(errtxt)
	elseif dir_1 == nil then
		return dir_2
	elseif dir_2 == nil then
		return dir_1
	end

	if abs(dir_1 - dir_2) != 2 and not (dir_1 == 1 and dir_2 == 7) and not (dir_1 == 7 and dir_2 == 1) then
		errtxt = "you cannot combine those directions: "..dir_1..", "..dir_2
		printh(errtxt)
		stop(errtxt)
	end

	if not (dir_1 == 1 and dir_2 == 7) and not (dir_1 == 7 and dir_2 == 1) then
		if dir_1 > dir_2 then
			return dir_2 + 1
		else 
			return dir_2 - 1
		end
	elseif dir_1 == 1 then
		return dir_2+1
	else
		return dir_1+1
	end
end

function reverse_dir(dir)
	if dir == utils.dir_l then
		return utils.dir_r
	elseif dir == utils.dir_r then
		return utils.dir_l
	elseif dir == utils.dir_u then
		return utils.dir_d
	elseif dir == utils.dir_d then
		return utils.dir_u
	elseif dir == utils.dir_ul then
		return utils.dir_dr
	elseif dir == utils.dir_ur then
		return utils.dir_dl
	elseif dir == utils.dir_dl then
		return utils.dir_ul
	elseif dir == utils.dir_dr then
		return utils.dir_ur
	end
	--this shuold never happen
	errtxt="wrong direction used: "..dir
	printh(errtxt)
	stop(errtxt)
end
-- TODO this might not be working
-- DEPRECATED: i think this is unused
function del_map(t, i)
	local n=#t
	if (i>0 and i<=n) then
		for j=i,n-1 do t[j]=t[j+1] end
		t[n]=nil
	end
end
 
-- prints sprite with rotation
function spr_r_vac(s,x,y,a,w,h)
	sw=(w or 1)*8
	sh=(h or 1)*8
	sx=(s%8)*8
	sy=flr(s/16)*8
	x0=flr(0.5*sw)
	y0=flr(0.5*sh)
	a=a/360
	sa=sin(a)
	ca=cos(a)
	for ix=0,sw-1 do
		for iy=0,sh-1 do
		dx=ix-x0
		dy=iy-y0
		xx=flr(dx*ca-dy*sa+x0)
		yy=flr(dx*sa+dy*ca+y0)
		if (xx>=2 and xx<sw-2 and yy>=2 and yy<=sh-2) then
		c = sget(sx+xx,sy+yy)
		if c!=1 and c!=2 then
				pset(x+ix,y+iy,c)
		end
		end
		end
	end
end

function spr_r(s,x,y,a,w,h)
	if a == 0 then
		spr(s,x,y,w,h)
		return
	elseif a == 180 then
		spr(s,x,y,w,h,true,true)
		return
	end
	sw=(w or 1)*8
	sh=(h or 1)*8
	sx=(s%8)*8
	sy=flr(s/16)*8
	x0=flr(0.5*sw)
	y0=flr(0.5*sh)
	a=a/360
	sa=sin(a)
	ca=cos(a)
	for ix=0,sw-1 do
		for iy=0,sh-1 do
		dx=ix-x0
		dy=iy-y0
		xx=flr(dx*ca-dy*sa+x0)
		yy=flr(dx*sa+dy*ca+y0)
		if (xx>=0 and xx<sw and yy>=0 and yy<=sh) then
			c = sget(sx+xx,sy+yy)
			if c!=0 and c!=2 then
				pset(x+ix,y+iy,c)
			end
		end
		end
	end
end

function myannimator:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- set the sprite and update after everyxframe
function myannimator:setsprite(sarr,everyxframe,reset)
	self.arr = sarr
	self.everyxframe = everyxframe
	if reset then
		self.i = 0
		self.frames = 0
	end
end

function myannimator:getsprite()
	if self.i > #self.arr then
		self.i = 1
	end
	return self.arr[self.i]
end

function myannimator:update()
	if self.frames == 0 then
		self.i += 1
	end
	self.frames = (self.frames+1) % self.everyxframe
end

function add_moving_solid(obj)
	add(moving_solids, obj)
end

function add_moving_trigger(obj)
	add(moving_trigger, obj)
end

function add_solid(obj)
	add(solids, obj)
end

function add_trigger(obj)
	add(trigger, obj)
end

function is_triggering(obj, debug)
	for t in all(trigger) do
	 if _trigger({t, obj}, debug) and t != obj then
	 	return t
	 end
	end
	for t in all(moving_trigger) do
	 if _trigger({t, obj}, debug) and t != obj then
	 	return t
	 end
	end
	return nil
end

function is_colliding(obj)
	for s in all(solids) do
		if collide({s, obj}) and s != obj then
			return s
		end
	end
	for s in all(moving_solids) do 
		if collide({s, obj}) and s != obj then
			return s
		end
	end
	return nil
end

function collide(pair)
	o1 = pair[1]
	o2 = pair[2]
	col = o1.x < o2.x + o2.w and o2.x < o1.x + o1.w and o1.y < o2.y + o2.h and o2.y < o1.y + o1.h
	return col;
end

function _trigger(pair, debug)
	o1 = pair[1]
	o2 = pair[2]
	x1 = o1.x+o1.triggerbox.x
	x2 = o2.x+o2.triggerbox.x
	y1 = o1.y+o1.triggerbox.y
	y2 = o2.y+o2.triggerbox.y
	w1 = o1.triggerbox.w
	w2 = o2.triggerbox.w
	h1 = o1.triggerbox.h
	h2 = o2.triggerbox.h
	col = x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
	if debug != nil then
		printh(x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1)
		printh(x1.." < "..x2+w2.." and "..x2.." < "..x1+w1.." and "..y1.." < "..y2+h2.." and "..y2.." < "..y1+h1)
	end
	return col;
end

function copy(obj)
	t={}
	for key, value in pairs(obj) do
	  t[key] = value
	end
	return t
end

function printh_door(d)
--{x=x, y=y, w=w, h=h, dir=dir, spritenr=sprite_nr, trigger_type=trigger_type.door,triggerbox={x=-1,y=-1,w=10,h=10}, next_room_id=room_id}
	printh("### DOOR START ###")
	printh("x: "..d.x..", y: "..d.y..", w: "..d.w..", h: "..d.h)
	printh("spritenr: "..d.spritenr)
	printh("trigger_type: "..d.trigger_type)
	printh("next_room_id: "..d.next_room_id)
	printh("triggerbox: {x="..d.triggerbox.x..", y="..d.triggerbox.y..", w="..d.triggerbox.w..", h="..d.triggerbox.h.."}")
	printh("### DOOR END ###")
end
-->8
-- room tab
default_room={
	wall={1,1,1,1,1,1,2},
	door={4},
	floor={}
}

grassy_room={
	wall={1,1,1,1,1,2,1,1,1,1,1,1,2},
	door={4},
	floor={10,10,10,10,10,11}
}

dry_room={
	wall={1,1,1,1,1,2,1,1,1,1,1,1,2},
	door={4},
	floor={9, -1, -1}
}

desert_room={
	wall={1,1,1,1,1,2,1,1,1,1,1,1,2},
	door={4},
	floor={14,14,15}
}

brick_grassy_room={
	wall={59,60},
	door={4},
	floor={10,10,10,10,10,11}
}

brick_desert_room={
	wall={59,60},
	door={4},
	floor={14,14,15}
}

function get_random_room_set()
	local random = flr(rnd(5))
	if random == 0 then
		return default_room
	elseif random == 1 then
		return grassy_room
	elseif random == 2 then
		return dry_room
	elseif random == 3 then
		return desert_room
	elseif random == 4 then
		return brick_grassy_room
	elseif random == 5 then
		return brick_desert_room
	end
end

function generate_room(room_set, door_enter_pos, door_enter_id, difficulty, title_screen)
	title_screen = title_screen or false
	printh("room generation: start")
	if door_enter_id != nil then
		printh("room generateion: door_enter_id: "..door_enter_id)
	end

	local room={
		walls={
			--{x=0,y=0,w=8,h=8,spritenr=1},
		},
		doors={
			--{x=0,y=0,w=8,h=8,spritenr=3, is_open=false, room_id=123},
		},
		floors={
			--{x=0,y=0,w=8,h=8,spritenr=98},
		},
		enemies={
			-- enemy objects, see enemy tab
		},
		cleared=false,
	}
	-- random integer between 2 and 4 (2,3,4)
	door_amount = flr(rnd(3)) + 2

	-- doors: {{utils.dir_l: {door}}}
	doors={}
	if title_screen == false then
		if door_enter_pos != nil and door_enter_id != nil then
			printh("room generation: NOT initial room")
			doors = get_doors(door_amount, room_set.door[1], {pos=door_enter_pos, door=get_door(door_enter_pos, door_enter_id, room_set.door[1])})
		else
			printh("room generation: inital room")
			doors = get_doors(door_amount, room_set.door[1])
		end

		if difficulty != nil then
			printh("generate enemies for difficulty: "..difficulty)
			local enemy_amount = flr(difficulty / 10)+1
			printh("enemy amount: "..enemy_amount)
			for i=1,enemy_amount do
				add(room.enemies, enemy:new(difficulty))
			end
		end

		printh("room generation: doors created")
	end

	door_pos_array = {}

	foreach(doors, function(d)
		add(room.doors,  d)
		add(door_pos_array, {x=d.x, y=d.y})
	end)

	is_door_fn = function(x, y)
		r = false
		foreach(door_pos_array, function(pos)
			if pos.x == x and pos.y == y then
				r = true
				return
			end
		end)
		return r
	end

	for x=0,15,1 do
	 for y=0,15,1 do
				if x==0 or x==15 or y==0 or y==15 then
					local random = flr(rnd(#room_set.wall))+1
					if is_door_fn(x, y) then
						-- don't overdraw
					elseif y==0 and x==8 then
						add(room.walls, {x=x*8, y=y*8, w=8, h=2, spritenr=room_set.wall[random]})
					elseif y==15 and x==8 then
						add(room.walls, {x=x*8, y=y*8, w=8, h=8, spritenr=room_set.wall[random]})
					elseif y==8 and x==0 then
						add(room.walls, {x=x*8, y=y*8, w=8, h=8, spritenr=room_set.wall[random]})
					elseif y==8 and x==15 then
						add(room.walls, {x=x*8, y=y*8, w=8, h=8, spritenr=room_set.wall[random]})
					elseif y==0 and x > 0 and x < 15 then
						add(room.walls, {x=x*8, y=y*8, w=8, h=2, spritenr=room_set.wall[random]})
					else
						add(room.walls, {x=x*8, y=y*8, w=8, h=8, spritenr=room_set.wall[random]})
					end
				else
					if room_set.floor[1] != nil then
						local random = flr(rnd(#room_set.floor))+1
						local sprite=room_set.floor[random]
						if sprite >= 0 then
							add(room.floors, {x=x*8, y=y*8, w=8, h=2, spritenr=room_set.floor[random]})
						end
					end
				end
		end
	end

	printh("room generation: done")
	return room
end

function load_room(room)
	foreach(room.walls, add_solid)
	foreach(room.doors, function(d)
		add_solid(d)
		add_trigger(d)
	end)
end

function update_room(room)
	moving_solids = {}
	moving_trigger = {}

	local room = play_manager.rooms[play_manager.current_room_id]
	if #room.enemies == 0 and room.cleared == false then
		foreach(room.doors, unlock_door)
		room.cleared = true
		play_manager.room_cleared()
	else
		foreach(room.enemies, add_moving_solid)
		foreach(room.enemies, add_moving_trigger)
		foreach(room.enemies, function(e) e:update() end)
	end
end

function draw_room(room)
	foreach(room.walls, draw_tile)
	foreach(room.doors, function(d)
		if d.spritenr == nil then
			printh("this door has no sprite: next_room_id "..d.next_room_id)
			printh_door(d)
			stop("this door has no sprite: next_room_id "..d.next_room_id, 10, 10)
		end
		draw_tile(d)
		if debug then
			print(d.next_room_id, d.x+1, d.y+2, 2)
		end
	end)
	foreach(room.floors, draw_tile)
	foreach(room.enemies, function(e) e:draw() end)
end

function draw_tile(tile)
	spr(tile.spritenr,tile.x,tile.y)
end

function get_door(pos, room_id, sprite_nr, sprite_nr_unlocked)
	if sprite_nr == nil then
		printh("FATAL door spritenr can't be nil")
		stop("door spritenr can't be nil")
	end
	if sprite_nr_unlocked == nil then
		sprite_nr_unlocked = 3
	end

	x=0
	y=0
	w=8
	h=8
	dir=pos
	if pos == utils.dir_l then
		x=0
		y=8*8
	elseif pos == utils.dir_r then
		x=15*8
		y=8*8
	elseif pos == utils.dir_u then
		x=8*8
		y=15*8
		h=2
	elseif pos == utils.dir_d then
		x=8*8
		y=0
	end
	unlocked=false
	return {x=x, y=y, w=w, h=h, dir=dir, spritenr=unlocked and sprite_nr_unlocked or sprite_nr, trigger_type=trigger_type.door,triggerbox={x=-1,y=-1,w=10,h=10}, next_room_id=room_id, unlocked=unlocked}
end

function unlock_door(door)
	door.unlocked=true
	door.spritenr=3
end

-- get door positions except for entry_door, since this is already a known position
-- existing door: {utils.dir_l: {door}}
function get_doors(door_amount, sprite_nr, existing_door)
	-- don't mind this function. It's fucked up. I'm just tired rn.
	if sprite_nr == nil then
		printh("sprite_nr cannot be nil")
		stop("sprite_nr cannot be nil")
	end

	printh("door amount for this room: "..door_amount)
	positions={}
	add(positions, utils.dir_r)
	add(positions, utils.dir_l)
	add(positions, utils.dir_u)
	add(positions, utils.dir_d)

	if existing_door != nil then
		del(positions, existing_door.dir)
		door_amount -= 1
	end

	fn = function(arr)
		printh("#arr: "..#arr.." , door_amount: "..door_amount)
		if #arr == door_amount then
			return arr
		end
		if #arr == 0 then
			stop()
		end
		delete_idx = flr(rnd(#arr)) + 1
		printh("delete index: "..delete_idx)
		del(arr, arr[delete_idx])
		return fn(arr)
	end

	positions = fn(positions)

	door_array = {}
	if existing_door != nil then
		add(door_array, existing_door.door)
		printh("get_doors: added existing door: {x: "..existing_door.door.x..", y: "..existing_door.door.y..", next_room_id: "..existing_door.door.next_room_id..", dir: "..existing_door.door.dir.."} ")
	end
	foreach(positions, function(dir)
		if existing_door != nil and existing_door.door.dir == dir then
			printh("WARNING: door was created at existing doors place o.O")
		else
			add(door_array, get_door(dir, play_manager.next_room_nr(), sprite_nr))
			printh("get_doors: added new door at "..dir)
		end
	end)
	return door_array
end

-->8
--ui stuff

----------------------------
-- sets up ascii tables
-- by yellow afterlife
-- https://www.lexaloffle.com/bbs/?tid=2420
-- btw after ` not sure if 
-- accurate
function setup_asciitables()
	chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`|██▒🐱⬇️░✽●♥☉웃⌂⬅️🅾️😐♪🅾️◆…➡️★⧗⬆️ˇ∧❎▤▥~"
	-- '
	s2c={}
	c2s={}
	for i=1,#chars do
		c=i+31
		s=sub(chars,i,i)
		c2s[c]=s
		s2c[s]=c
	end
end
---------------------------
function asc(_chr)
	return s2c[_chr]
end
---------------------------
function chr(_ascii)
	return c2s[_ascii]
end
-------------------------------
-- sprite print centered on x
function sprintc(_str,_y,_c,_c2,_c3)
	local i, num
	_x=63-(flr(#_str*8)/2)
	palt(0,false) -- make sure black is solid
	if (_c != nil) pal(7,_c) -- instead of white, draw this
	if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
	if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
	-- make color 5 and 6 transparent for font plus shadow on screen
		
	for i=1,#_str do
		num=asc(sub(_str,i,i))+160
		spr(num,_x+(i-1)*8,_y*8)
	end
	pal()
end

-------------------------------
-- double-sized sprite print at x,y pixel coords
function dsprintxy(_str,_x,_y,_c,_c2,_c3)
	local i, num,sx,sy
	palt(0,false) -- make sure black is solid
	if (_c != nil) pal(7,_c) -- instead of white, draw this
	if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
	if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
	-- make color 5 and 6 transparent for font plus shadow on screen
	-- (btw you can use this technique
	-- just to draw sprites bigger)
	for i=1,#_str do
		num=asc(sub(_str,i,i))+160
		sy=flr(num/16)*8
		sx=(num%16)*8
		sspr(sx,sy,8,8,_x+(i-1)*16,_y,16,16)
	end
	pal()
end

function printo(str, x, y, c0, c1)
	for xx = -1, 1 do
		for yy = -1, 1 do
		print(str, x+xx, y+yy, c1)
		end
	end
	print(str,x,y,c0)
end
__gfx__
00012000606660666066606660666066606660666066606616666661feeeeee87bbbbbb30000004000000030000300000b0dd030777777674f9f4fff7999a999
07d1257000000000000000000000000000000000007777006d6666d6e8888882b3333331040000000300000003000030d3000b0d76777777fffff9f49999979a
057d57d0666066606660566060333306608888066676d75062444426e8811882b33773310000040000000300000003b0000b030077777677ff4fffff99a99999
22566d11000000000000000000333300008888000077770064222246e8866882b3366531000400000003000000b00bb0b0030000777677779fff9ff999997997
11d6652206660666066605666033330660888806067d675664442446e8877282b3355131400000003000000030b30b003000dd0b677777774fffff9fa9999979
0d75d750000000000000000000331300008818000077770064222a96e8822182b33113310000000400000003003b00030b00000377777776ff4fffff999a9999
07521d70660666066606660660331306608818066605550664424446e8888882b33333310400000003000000030b00000300b00076777777ff9ff9ff99999799
0002100000000000000000000033330000888800000000006422224682222222311111110000400000003000000030000dd030b077776777f9ffff4f979999a9
111c111c7ccc7cc70000000005500550005070500500700000dddd00656565650d0aa000000aa000760000000766660006566650777777500007a90000000070
11c111c177ccc7cc000000000765676005076005000760050dddddd0666666650df99f000df99f0006500000766550000666666576666650000a0000000006d6
1c111c11c77ccc7c00000000076007605076660050766700dddddddd662226650de11e000de11e0700650000664500000659405676565650000aa90000006d60
c111c111cc77ccc7076007600765676050766605007676000555555066666665d55660070d66660200065006650450000009400076666650000a00000006d000
111c111c7cc77ccc07656760076007600766767007667670066666606655566509066602d5d6609200006560650045000009400076565650000a0000076d0000
11c111c1c7cc77cc0760076000000000576676655761166506dd6c6066111665000cc092090cc00200000650600004500009400076565650007aa9007dd6d000
1c111c11cc7cc77c1765676100000000766767667610016606dd6c606611166500c11c0200c11c000000604500000045000940000766650000a00a006d06d000
c111c1117cc7cc771d211d2100000000565655656610016606dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0bb3b3b030bbb0030150051001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
bb3b3b350bbb3300157556511575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
b3b33333bb3bbb305757651557576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
b3333335b3b3b33505766650057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
0b4334503bbb3b3505666650056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
0009450033b3b355575665155516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
0009450003335550156551511155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
095454540033350301500510015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000990000777770000077000007dd500007665000554455000007000067666500007000099999999750705607776777677777776777777767777777677777776
049aa94075666660007667000007500007666650554444550000770000565100007a900090040405565656507665766576666665766666657766665576666665
49a99a940065d56000077000077665507666666545444454000076700067650007aaa90094444445057775007665766576555565766776657676656576666665
9a9aa9a900666660076666707766665576565565455a9554000077770067650007aaa90090004005767766606555655576566765767665657667566576666665
9a9aa9a900655d60765555677666666576666665411a911407007000006765000a99990094444445057665007677767776566765767665657667566576666665
49a99a94006666606500005676666665765565654445544476666667006765007556559095555555565656506576657676577765766556657676656576666665
049aa940006777775650056577666655766666654444444407666670006765000aaaa90000055000750605606576657676666665766666657766665576666665
00499400005555500567765007766550655555555444444500777700067666500000000005064005000000005565556565555555655555556555555565555555
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000702826007282060
a979979400e88000d70cc07dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500602825006282050
a71991740e111800d77cc77dd70cc07d271881722708807203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0007700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0076670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0766667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d7666666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d0005500000077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0006600000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00006600007000070
08008000ab0000a00056650006555550aa4004aa0056650000665000766666666552155666666665000dd0009a9009a9776650006ddddd000006600070000007
2002821000028210202000000006822d02822222020220d000000000000000000000000000000000007665000076650005555555555555555555555055677655
0211111122111111022282100026cdcd1111110002200d0000000000000000000000000000000000075006500750065055666666666666666666665556555565
11ddcdcd01ddcdcd001111110216ddddddcdcddd21ddd00002000000000000000000000000000000065006500650000056676767676767676767766556677665
006ddddd106ddddd66ddcdcd0016dddd66666d0081cddd0022ddd000000000000000000000000000766666657666666556777777777777777777776556677665
006d5ddd006d5ddd600ddddd0015ddd066dddd001ddddd008dddd000002282000202820002222200766166657663666556777676767676767676776555677655
0065111d0065111d0005ddd00052111056d111111c66d1111dddd1000221166600211110002282dd766166657663666556766676666666666767766556555565
00520010005200100552211100520010052200000d6661001d66611100666c10011dddd000111110766666657666666556776756666666667577666556677665
0502001005020010500200100502001000502000000552221d666222666dddc066666666666dddd0655555556555555556766665555555555667766556677665
0028210020000000002821002200000002228200005000000000000000000000c0c6cc0000777700056650000000000056677665555575555566765555555555
02111110222821000211111002282100221116660205002002022210202221000cccccc0071111605600650007a00a7056776665565755665555555556677665
d21ddcd60111111021ddcdcd0111111000666c10022560220022822102282210cdd7d7d071111115607006000a9009a056677665565757676565565655555555
d1dd66660ddddcd0666ddddd0dddcdc0066dddcd101d5682011111111111111006ddddd071100115600006000000000056776665575757777576755757777775
00d66d00066dddd06066dd00066dddd05555dd0011ddd62206ddcdcd0ddcdcd00d665ddd71100115560065000000000056677665575756766557675675555557
202211000066dd00001221000066dd00021dd00000dd661260d5dddd6d5dddd000c5ccc071111115056694500a90000056776665565756666565565655677655
02000010002212000110020000221100200100000dd6dc116552ddd16522dd11005c00c0061111500000094507a0000056677665565755665555555556776665
0000000100012000000000200002100000100000d000c1105220011152220001050c00c000555500000000940000000056776665555575555567665556677665
0028226000000000628210000022000022000000222200001112000006822d0026822d0077777777002820000077770056776675555755555677666556776665
002222600028220026111100081d0000820d0000228110001112800026cdcd0016cdcd0000000000028e8200076566d056676756665575656577666556677665
061221600022222006dcdc00621d0000612d000011dcd00011dc600016dddd0006dddd000600600608e7e8007665666d56777667676575657667766555776655
06d11dd0061221160ddddd00611c0200611c0200d66665d5dddd656506dddd0006dddd000000000008eee8007665556d56677777777575757777766575555557
0dd1d1d00dd11ddd05dddd006cdd52016cdd5201dddd0d00ddd6060005ddd00005ddd00000500500028e82007666666d56667676767575756767666557777775
005111000dd1d1dd522dd0d0d66d5211d6665211211100001112000005221110052211100000000000282000076666d056666666666575656666666555555555
0015000000551110220100000d6652100dd6521020001000100020005002000150020001010100100028200000dddd0055666666665575656666665556677665
00105000001051000110000000dd510000dd51002000010010000200500000005000000000000000002820000000000005555555555755555555555055555555
062281100000000000400000202821000028210000282100000000000000000000000000000000007777777711111100566666660015d0005666666500000000
6d6dcdc00000122240900040111111102111111021111110030100000606330000003300000000007555555717777610655115510015d0006666666600000000
506dddd0000dd18090a040900ddbdbd00ddbdbd01ddbdbd003013300663138300031383000077000756556571777610065155551001d50006000000601111110
506dddd0000ddd11a00090a40666dddd1666dddd0666dddd00313830633313300633133000766700755555571776610051155551000d15006000000605555550
5006ddd000ddddd10405a00900d5dd0000d5dd0000d5dd00003313303331301363313013005665007555555717667610655115110001d5006000000605555550
00021111002d6dd00905004a005111000052110000521100033130131110000011100000000550007565565716116761655551510001d0006000000605155150
000200010222166d0a5000900520001005002000052201001110000010000000100000000000000075555557010016716555515100105d006000000605111150
0002000020011006dd1110a05020000050010000500001001000000000000000000000000000000077777777000001105111111500150d000000000005111150
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555775555775775557757755555775555775577557777555555775555557755555577555775557755557755555555555555555555555555555555775
55555555555770555770770577777775557777755770770057777055555770555577005555557755577577005557705555555555555555555555555555557700
55555555555770555500500557707700577770005507700555770775555500555577055555557705777777755777777555555555577777755555555555577005
55555555555500555555555577777775550777755577077557707700555555555577055555557705577077005557700055775555550000005555555555770055
55555555555775555555555557707700577777005770077057707705555555555557755555577005770057755557705555770555555555555577555557700555
55555555555500555555555555005005550770055500550055775775555555555555005555550055500555005555005557700555555555555577055555005555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755555775555777775557777755555777755777777555777755577777755577775555777755555775555557755555557755555555555577555557777755
57700775557770555500077555000775557707705770000057700005550007705770077557700775555770555557705555577005557777555557755555000775
57705770555770555577770055577700577007705777775557777755555577005577770055777770555500555555005555770055555000055555775555577700
57705770555770555770000555550775577777705500077557700775555770055770077555500770555775555557755555577555557777555557700555550005
55777700557777555777777557777700550007705777770055777700555770555577770055777700555770555557705555557755555000055577005555577555
55500005555000055500000055000005555555005500000555500005555500555550000555500005555500555577005555555005555555555550055555550055
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777755577777555577777555777775557777555775577555777755555577755775577557755555575555755775577555777755
57700775577007755770077557700775577007755770000057700000577000055770577055577005555557705770770057705555577557705777577057700775
57707770577777705777770057705500577057705777775557777755577077755777777055577055555557705777700557705555577777705777777057705770
57705000577007705770077557705775577057705770000557700005577057705770077055577055577557705770775557705555577777705770777057705770
55777775577057705777770055777700577777005577777557705555557777005770577055777755557777005770577555777775577007705770577055777700
55500000550055005500000555500005550000055550000055005555555000055500550055500005555000055500550055500000550055005500550055500005
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777775577777755775577557755775577557755775577557755775577777755777775557755555577777555557755555555555
57700775577007755770077557700000555770005770577057705770577777705577770055777700550077005770000555775555550077055577775555555555
57777700577057705777770055777755555770555770577057705770577777705557700555577005555770055770555555577555555577055770077555555555
57700005577077005770077555500775555770555770077055777700577007705577775555577055557700555770555555557755555577055500550055555555
57705555557707755770577057777700555770555577770055577005570055705770077555577055577777755777775555555775577777055555555557777775
55005555555005005500550055000005555500555550000555550055550555505500550055550055550000005500000555555500550000055555555555000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
__label__
60666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660666056606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666056606660666066606660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06660666066605660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066605660666066606660666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666066000000000000000000000040000000000000000000000000000000400000004000000000000000400000004000000040000000000000000060666066
00000000000000000000000004000000000000000000000000000000040000000400000000000000040000000400000004000000000000000000000000000000
66606660000000000000000000000400000000000000000000000000000004000000040000000000000004000000040000000400000000000000000066606660
00000000000000000000000000040000000000000000000000000000000400000004000000000000000400000004000000040000000000000000000000000000
06660666000000000000000040000000000000000000000000000000400000004000000000000000400000004000000040000000000000000000000006660666
00000000000000000000000000000004000000000000000000000000000000040000000400000000000000040000000400000004000000000000000000000000
66066606000000000000000004000000000000000000000000000000040000000400000000000000040000000400000004000000000000000000000066066606
00000000000000000000000000004000000000000000000000000000000040000000400000000000000040000000400000004000000000000000000000000000
60666066000000400000000000000000000000000000000000000000000000400000000000000000000000000000004000000000000000000000004060666066
00000000040000000000000000000000000000000000000000000000040000000000000000000000000000000400000000000000000000000400000000000000
66605660000004000000000000000000000000000000000000000000000004000000000000000000000000000000040000000000000000000000040066605660
00000000000400000000000000000000000000000000000000000000000400000000000000000000000000000004000000000000000000000004000000000000
06660566400000000000000000000000000000000000000000000000400000000000000000000000000000004000000000000000000000004000000006660566
00000000000000040000000000000000000000000000000000000000000000040000000000000000000000000000000400000000000000000000000400000000
66066606040000000000000000000000000000000000000000000000040000000000000000000000000000000400000000000000000000000400000066066606
00000000000040000000000000000000000000000000000000000000000040000000000000000000000000000000400000000000000000000000400000000000
60666066000000400000000000000000000000000000000000000000000000000000004000000040000000400000000000000000000000000000004060666066
00000000040000000000000000000000000000000000000000000000000000000400000004000000040000000000000000000000000000000400000000000000
66606660000004000000000000000000000000000000000000000000000000000000040000000400000004000000000000000000000000000000040066606660
00000000000400002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220004000000000000
06660666400000002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222224000000006660666
00000000000000041177777777771111111177777777111111117777777711111177111111117711117777777777111111117777777711110000000400000000
66066606040000001177777777771111111177777777111111117777777711111177111111117711117777777777111111117777777711110400000066066606
00000000000040001177770000777711117777000077771111777700007777111177771111777700117777000077771111777700007777110000400000000000
60666066000000401177770000777711117777000077771111777700007777111177771111777700117777000077771111777700007777110000004060666066
00000000040000001177777777770000117777001177770011777700117777001177777777777700117777777777000011777777777777000400000000000000
66606660000004001177777777770000117777001177770011777700117777001177777777777700117777777777000011777777777777000000040066606660
00000000000400001177770000777711117777001177770011777700117777001177777777777700117777000077771111777700007777000004000000000000
06660666400000001177770000777711117777001177770011777700117777001177777777777700117777000077771111777700007777004000000006660666
00000000000000041177770011777700111177777777000011117777777700001177770000777700117777777777000011777700117777000000000400000000
66066606040000001177770011777700111177777777000011117777777700001177770000777700117777777777000011777700117777000400000066066606
00000000000040001111000011110000111111000000001111111100000000111111000011110000111100000000001111110000111100000000400000000000
60666066000000401111000011110000111111000000001111111100000000111111000011110000111100000000001111110000111100000000000060666066
00000000040000002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220000000000000000
66605660000004002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220000000066606660
00000000000400002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220000000000000000
06660566400000001177771111777711111177777777111111777777777777111111777777771111117777777777111111111177771111110000000006660666
00000000000000041177771111777711111177777777111111777777777777111111777777771111117777777777111111111177771111110000000000000000
66066606040000001177777711777700117777000077771111111177770000001177770000777711117777000077771111111177770011110000000066066606
00000000000040001177777711777700117777000077771111111177770000001177770000777711117777000077771111111177770011110000000000000000
60666066000000001177777777777700117777777777770011111177770011111177770011777700117777777777000011111177770011110000000060666066
00000000000000001177777777777700117777777777770011111177770011111177770011777700117777777777000011111177770011110000000000000000
66606660000000001177770077777700117777000077770011111177770011111177770011777700117777000077771111111111000011110000000066606660
00000000000000001177770077777700117777000077770011111177770011111177770011777700117777000077771111111111000011110000000000000000
06660666000000001177770011777700117777001177770011111177770011111111777777770000117777001177770011111177771111110000000006660666
00000000000000001177770011777700117777001177770011111177770011111111777777770000117777001177770011111177771111110000000000000000
66066606000000001111000011110000111100001111000011111111000011111111110000000011111100001111000011111111000011110000000066066606
00000000000000001111000011110000111100001111000011111111000011111111110000000011111100001111000011111111000011110000000000000000
60666066000000002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220000000060666066
00000000000000002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220000000000000000
66606660000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000066606660
00000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000
06660666000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000006660666
00000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000
66066606000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000066066606
00000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000
60666066000000000000000000000000000000400000000000000000000000000000000000000000000000400000000000000040000000000000000060666066
00000000000000000000000000000000040000000000000000000000000000000000000000000000040000000000000004000000000000000000000000000000
66605660000000000000000000000000000004000000000000000000000000000000000000000000000004000000000000000400000000000000000066606660
00000000000000000000000000000000000400000000000000000000000000000000000000000000000400000000000000040000000000000000000000000000
06660566000000000000000000000000400000000000000000000000000000000000000000000000400000000000000040000000000000000000000006660666
00000000000000000000000000000000000000040000000000000000000000000000000000000000000000040000000000000004000000000000000000000000
66066606000000000000000000000000040000000000000000000000000000000000000000000000040000000000000004000000000000000000000066066606
00000000000000000000000000000000000040000000000000000000000000000000000000000000000040000000000000004000000000000000000000000000
60666066000000400000000000000040000000400000004000000000000000400000000000000000000000000000004000000000000000400000000060666066
00000000040000000000000004000000040000000400000000000000040000000000000000000000000000000400000000000000040000000000000000000000
66606660000004000000000000000400000004000000040000000000000004000000000000000000000000000000040000000000000004000000000066606660
00000000000400000000000000040000000400000004000000000000000400000000000000000000000000000004000000000000000400000000000000000000
06660666400000000000000040000000400000004000000000000000400000000000000000000000000000004000000000000000400000000000000006660666
00000000000000040000000000000004000000040000000400000000000000040000000000000000000000000000000400000000000000040000000000000000
66066606040000000000000004000000040000000400000000000000040000000000000000000000000000000400000000000000040000000000000066066606
00000000000040000000000000004000000040000000400000000000000040000000000000000000000000000000400000000000000040000000000000000000
60666066000000000000000000000000000000400000000000000000000000000000004000000000000000000000000000000000000000400000000060666066
00000000000000000000000000000000040000000000000000000000000000000400000000000000000000000000000000000000040000000000000000000000
66606660000000000000000000000000000004000000000000000000000000000000040000000000000000000000000000000000000004000000000066606660
00000000000000000000000000000000000400000000000000000000000000000004000000000000000000000000000000000000000400000000000000000000
06660666000000000000000000000000400000000000000000000000000000004000000000000000000000000000000000000000400000000000000006660666
00000000000000000000000000000000000000040000000000000000000000000000000400000000000000000000000000000000000000040000000000000000
66066606000000000000000000000000040000000000000000000000000000000400000000000000000000000000000000000000040000000000000066066606
00000000000000000000000000000000000040000000000000000000000000000000400000000000000000000000000000000000000040000000000000000000
60666066000000400000000000000040000000000000004000000040000000000000004000000000000000400000004000000040000000000000004060666066
00000000040000000000000004000000000000000400000004000000000000000400000000000000040000000400000004000000000000000400000000000000
66606660000004000000000000000400000000000000040000000405765000000000040000000000000004000000040000000400000000000000040066606660
00000000000400000000000000040000000000000004000000040056776000000004000000000000000400000004000000040000000000000004000000000000
06660666400000000000000040000000000000004000000040000d05677000004000000000000000400000004000000040000000000000004000000006660666
000000000000000400000000000000040000000000000004000007d6567000000000000400000000000000040000000400000004000000000000000400000000
66066606040000000000000004000000000000000400000004000566567000000400000000000000040000000400000004000000000000000400000066066606
000000000000400000000000000040000000000000004000000040d5677000000000400000000000000040000000400000004000000000000000400000000000
60666066000000000000000000000040000000400000000000000056776000400000000000000040000000400000004000000000000000400000000060666066
00000000000000000000000004000000040000000000000000000005765000000000000004000000040000000400000000000000040000000000000000000000
66606660000000000000000000000400000004000000000000000000000004000000000000000400000004000000040000000000000004000000000066606660
00000000000000000000000000040000000400000000000000000000000400000000000000040000000400000004000000000000000400000000000000000000
06660666000000000000000040000000400000000000000000000000400000000000000040000000400000004000000000000000400000000000000006660666
00000000000000000000000000000004000000040000000000000000000000040000000000000004000000040000000400000000000000040000000000000000
66066606000000000000000004000000040000000000000000000000040000000000000004000000040000000400000000000000040000000000000066066606
00000000000000000000000000004000000040000000000000000000000040000000000000004000000040000000400000000000000040000000000000000000
60666066000000000000004000000000000000000000004000000000000000400000000000000000000000400000000000000000000000400000004060666066
00000000000000000400000000000000000000000400000000000000040000000000000000000000040000000000000000000000040000000400000000000000
66606660000000000000040000000000000000000000040000000000000004000000000000000000000004000000000000000000000004000000040066605660
00000000000000000004000000000111111111111111111111000011111110000111111111000011111111111111111111000000000400000004000000000000
06660666000000004000000000000177717771777117711771000117777711000177711771000117717771777177717771000000400000004000000006660566
00000000000000000000000400000171717171711171117111000177171771040117117171000171111711717171711711000000000000040000000400000000
66066606000000000400000000000177717711771177717771000177717771000017117171000177711711777177111710000000040000000400000066066606
00000000000000000000400000000171117171711111711171000177171771000017117171000111711711717171711710000000000040000000400000000000
60666066000000000000000000000171017171777177117711000117777711000017117711000177111711717171711710000000000000000000004060666066
00000000000000000000000004000111011111111111111110000011111110000411111114000111141111111111111110000000000000000400000000000000
66605660000000000000000000000400000000000000040000000000000000000000040000000400000004000000040000000000000000000000040066606660
00000000000000000000000000040000000000000004000000000000000000000004000000040000000400000004000000000000000000000004000000000000
06660566000000000000000040000000000000004000000000000000000000004000000040000000400000004000000000000000000000004000000006660666
00000000000000000000000000000004000000000000000400000000000000000000000400000004000000040000000400000000000000000000000400000000
66066606000000000000000004000000000000000400000000000000000000000400000004000000040000000400000000000000000000000400000066066606
00000000000000000000000000004000000000000000400000000000000000000000400000004000000040000000400000000000000000000000400000000000
60666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660666066606660666066606660666066606660666066606660666066606660666066606660666056606660666066606660666066606660666066606660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06660666066606660666066606660666066606660666066606660666066606660666066606660666066605660666066606660666066606660666066606660666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606660666066606
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
000101010181010001000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000c0000040400000000000000000000000000000000000000000000000000000000000c0c00000000000000000001000000000000000001000000
0000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002e1502e1502f1502f1502f150351503715000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200002e5502e5503555035550166003a5503a55037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001c620385503455031550305502e5502d5501d6201d6201d6001d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000006500065000650006551305014050140501405014050140501405013050110500e0500b0500905008050070500605005050050500505006050070500105001030010230000000000000000000000000
000400000024000231062002100000240002310022100213190001a00023000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a750267502a7500070032750377003970039700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
000200000b3240d331103411c341233412634127341293412c3312e32500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700180062307623000000762300623000000000000623076230000007623006230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000307342b751237511d75117751127510d75108751037310271501713007050c7000a700077000670004700027000170000700007000070000700007000070000700017000070000700007000070000700
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000312502b250252502025019250122500e2500e6300e6300e6351520010200072000420000200002000d20009200082000820000200002000120026100121001e100061000d10019100251000c10024100
0006000019150201501c150231502313519130201301c130231302312519120201201c120231202311519110201101c1102311023115001000010000100001000010000100001000010000100001000010000100
000900000b6500b6500b6531c6001c6501c650156300e630096300763005610036100161001615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c6301c630232541c35120353173501b3501935422230246002460025600266002660027600156000f6000b6000760006600056000460004600046000020000200002000020000200002000020000200
0003000028630286301e6501a650186501664014640106400f6400c630096300663005630026100161001610016102750020500235002c5002e50022500295002e500325001f5002a5002d500265002a5001c500
000300000863111631206003365032651306512a651226511a651136410d641086410463101631006110061500000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000017630106300e6500e6301063213652186521e6522a6523663236632306323062221622126220661200612006120161200612006150060000600006000060000600006000060000600006000060000600
010c00201125411255052550000000000112541125505255000000000011254112550525500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000705005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000205004050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000005002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400001c5151e5151a515150151c5151e5151a015155151c5151e5151a515150151c5151e5151a015155151c5151e51517015230151c5151e51517015230151c5151e515165151c0151c5151e515160151c515
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020515215151c5151901520515215151c0151951520515215151c5151901520515215151c0151951520515215151c0151901520515215151c01525515285152651525515210151c5151a5151901515515
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
010a000024045270352d02523045260352c02522045250352b02522035250352b02522035250252b01522725257252b71522715257152b71522715257152b7151700017000170001700017000130000c00000000
010a000021705247052a7052072523715297151f72522715287151f71522715287151f71522715287151f71522715287151f71522715287151f70522705287051770017700177001770017700137000c70000700
010c00000f51014510185101b510205102451011510165101a5101d510225102651013510185101c5101f5102451028510285102851028510285102851028515240042450225504255052650426502265050e500
010c000014730187301b730207302473027730167301a7301d730227302673029730187301c7301f73024730287302b730307403073030730307303072030715247042470225704257052670426702267050e700
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5011e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50130011
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
010200002067021670316602f65031650336503365033650386503f6503f650326502f6502f650006002f6502e6502d650006002b650296502760024650216001e65019600116500a60000630066000161000010
010200000e6510c6530a6520b653056530000000000000000e6510c6530a652000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000013535000002b5070000037535000001f507000002b5350000000000000001f53500000000000000013505000002b5070000037535000001f507000002b5350000000000000001f535000000000000000
011000000062200622006220062202622026220262202622006220062200622006220262202622026220262200622006220062200622026220262202622026220062200622006220062202622026220262202622
__music__
00 16174344
00 16174344
01 16174344
00 16174344
00 18194344
02 18194344
00 1a424344
01 1a1b4344
00 1a1b4344
00 1a1c4344
00 1a1c4344
02 1d1e4344
01 1f204344
00 1f214344
00 1f204344
00 1f214344
00 22234344
02 1f244344
01 25264344
00 25264344
02 27284344
00 292a4344
03 2b2c4344
04 2d2e4344
04 2f304344
01 31324344
00 31324344
00 33344344
02 35364344
01 37384344
00 393a4344
00 373b4344
02 393b4344
03 3e424344

