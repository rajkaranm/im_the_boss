function CheckCollision(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and
	bx < ax + aw and
	ay < by + bh and
	by < ay + ah
end

-- Picks a random direction for the enemy to move
function chooseEnemyDirection()
    local angle = math.random() * math.pi * 2
    enemy.dx = math.cos(angle)
    enemy.dy = math.sin(angle)
end

-- Respawn enemy from a random side of the screen
function respawnEnemy()
    local side = math.random(4)

    if side == 1 then -- Left
	enemy.x = -enemy.w
	enemy.y = math.random(screenH)
    elseif side == 2 then -- Right
	enemy.x = screenW + enemy.w
	enemy.y = math.random(screenH)
    elseif side == 3 then -- Top
	enemy.x = math.random(screenW)
	enemy.y = -enemy.h
    else -- Bottom
	enemy.x = math.random(screenW)
	enemy.y = screenH + enemy.h
    end

    chooseEnemyDirection()
end


function love.load()
    math.randomseed(os.time())
    love.mouse.setVisible(false)


    screenW, screenH = 800, 600
    love.window.setMode(screenW, screenH)
    love.window.setTitle("I'm The Boss")
    game_state = 'starting'

    -- Load Assets
    background = love.graphics.newImage("assets/background.png")
    shoot_sound = love.audio.newSource("assets/shoot.wav", "static")
    reload_sound = love.audio.newSource("assets/reload.wav", "static")

    -- Player setup
    player = {
	x = 100,
	y = 100,
	w = 10,
	h = 10,
	speed = 400,
	bullet = 60

    }
    player.sprite = love.graphics.newImage("assets/crosshair.png")
    player.sprite_width = player.sprite:getWidth()
    player.sprite_height = player.sprite:getHeight()

    -- Enemy setup
    enemy = {
	x = 300,
	y = 300,
	w = 50,
	h = 50,
	speed = 500,
	dx = 0,
	dy = 0,
	sprite = love.graphics.newImage("assets/boss.png")
    }

    -- Choose initial random direction for enemy
    chooseEnemyDirection()

    -- State variables
    kill = false
    win = false

    -- Score
    score = 0

    start_time = love.timer.getTime()
    time = love.timer.getTime()
end


function love.mousepressed(x, y, button)
    if button == 1 then
	if player.bullet > 0 and game_state == 'playing' then
	    player.bullet = player.bullet - 1
	    shoot_sound:play()
	end
    end
end


function love.update(dt)
    -- Player movement

    player.x = love.mouse.getX() - (player.sprite_width / 2)
    player.y = love.mouse.getY() - (player.sprite_height / 2)

    
    if game_state == 'playing' then

	-- Mouse click to "kill"
	kill = love.mouse.isDown(1)


	if player.x < 0 - player.sprite_width then
	    player.x = screenW
	end
	if player.x > screenW then
	    player.x = 0
	end
	if player.y < 0 - player.sprite_height then
	    player.y = screenH
	end
	if player.y > screenH then
	    player.y = 0
	end


	-- Move enemy
	enemy.x = enemy.x + enemy.dx * enemy.speed * dt
	enemy.y = enemy.y + enemy.dy * enemy.speed * dt

	-- If enemy is far outside the screen, respawn it
	local margin = 60
	if enemy.x < -margin or enemy.x > screenW + margin
	    or enemy.y < -margin or enemy.y > screenH + margin then
	    respawnEnemy()
	end

	-- Check For Timer
	if love.timer.getTime() - start_time > 60 then
	    game_state = 'stop'
	end

	time = love.timer.getTime()


	-- Collision check (kill enemy)
	if CheckCollision(player.x, player.y, player.w, player.h,
			  enemy.x, enemy.y, enemy.w, enemy.h) and kill and player.bullet > 0 then
	    respawnEnemy()
	    score = score + 1
	    -- win = true
	    -- player.canMove = false
	end	
    end

    if game_state == 'stop' and love.keyboard.isDown('return') then
	reload_sound:play()
	game_state = 'playing'
	score = 0
	start_time = love.timer.getTime()
	player.bullet = 60
    end

    if game_state == 'starting' and love.keyboard.isDown('return') then
	reload_sound:play()
	game_state = 'playing'
    end
    
    
end

function love.draw()
    -- Draw Background
    love.graphics.draw(background, 0, 0)

    -- Draw Score
    love.graphics.print(string.format("Score: %d", tostring(score)), 5, 5, 0, 2, 2)
    love.graphics.print(string.format("Bullet: %d", tostring(player.bullet)), 5, 50, 0, 2, 2)
    love.graphics.print(
	string.format("Time: %d", tostring(time - start_time)),
	screenW - 110,
	5, 0, 2, 2
    )

    -- Draw enemy if not dead
    if game_state == 'playing' then
	love.graphics.draw(enemy.sprite, enemy.x, enemy.y)
    end

    if game_state == 'stop' then
	 love.graphics.print("Press Enter To Restart!", screenW / 4, screenH / 2, 0, 3, 3)
    end

    if game_state == 'starting' then
	love.graphics.draw(enemy.sprite, screenW/2.4, screenH/3, 0, 3, 3)
	love.graphics.print("Press Enter To Play!", screenW / 3.6, screenH / 2, 0, 3, 3)
    end
    

    -- Draw player
    love.graphics.draw(player.sprite, player.x, player.y)

end
