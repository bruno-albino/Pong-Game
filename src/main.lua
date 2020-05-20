WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

X_MIDDLE = VIRTUAL_WIDTH / 2
Y_MIDDLE = VIRTUAL_HEIGHT / 2

Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'


function love.load()
  love.window.setTitle('Pong')

  math.randomseed(os.time())
  
  love.graphics.setDefaultFilter('nearest', 'nearest')

  smallfont = love.graphics.newFont('04B_03__.TTF', 8)
  scorefont = love.graphics.newFont('04B_03__.TTF', 32)
  victoryFont = love.graphics.newFont('04B_03__.TTF', 24)
  love.graphics.setFont(smallfont)

  sounds = {
    ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
    ['point_scored'] = love.audio.newSource('point_scored.wav', 'static'),
    ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
  }

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = true,
    vsync = true,
    resizable = true
  })

  player1score = 0
  player2score = 0

  servingPlayer = math.random(2) == 1 and 1 or 2

  victoryPlayer = 0

  

  player1 = Paddle(10, 30, 5, 20)
  player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)


  if servingPlayer == 1 then
    ball.dx = 100
  else
    ball.dx = -100
  end


  gameState = 'start'
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)
  if gameState == 'play' then

      -- CHECK COLISION OF THE PADDLES
    if ball:collides(player1) then
      ball.dx = -ball.dx * 1.03
      ball.x = player1.x + 5

      sounds['paddle_hit']:play()

      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
    end


    if ball:collides(player2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x - 4
  
      sounds['paddle_hit']:play()

      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
    end

  end

  -- CHECK COLISION OF THE TOP
  if ball.y <= 0 then
    ball.y = 0
    ball.dy = -ball.dy

    sounds['wall_hit']:play()
  end

  -- CHECK COLISION OF THE BOTTOM
  if ball.y >= VIRTUAL_HEIGHT - 4 then
    ball.y = VIRTUAL_HEIGHT - 4
    ball.dy = -ball.dy

    sounds['wall_hit']:play()
  end
  

  -- check scores
  if ball.x <= 0 then
    player2score = player2score + 1
    servingPlayer = 1
    ball:reset()
    ball.dx = 100

    sounds['point_scored']:play()

    if player2score == 10 then
      gameState = 'victory'
      victoryPlayer = 2

    else
      gameState = 'serve'
    end
  end

  if ball.x >= VIRTUAL_WIDTH - 4 then
    player1score = player1score + 1
    servingPlayer =  2
    ball:reset()
    ball.dx = -100

    sounds['point_scored']:play()
    
    if player1score == 10 then
      gameState = 'victory'
      victoryPlayer = 1
    else
      gameState = 'serve'
    end
  end


  -- PLAYER 1 COMMANDS
  if love.keyboard.isDown('w') then
    player1.dy = - PADDLE_SPEED
  elseif love.keyboard.isDown('s') then
    player1.dy = PADDLE_SPEED
  else
    player1.dy = 0
  end

  -- PLAYER 2 COMMANDS
  if love.keyboard.isDown('up') then
    player2.dy = - PADDLE_SPEED
  elseif love.keyboard.isDown('down') then
    player2.dy = PADDLE_SPEED

  else 
    player2.dy = 0
  end


  player1:update(dt)
  player2:update(dt)

  if gameState == 'play' then
    ball:update(dt)
  end
end




function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()

  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'serve'

    elseif gameState == 'serve' then
      gameState = 'play'

    elseif gameState == 'victory' then
      gameState = 'start'
      player1score = 0
      player2score = 0
    end
  end


end


function love.draw()
  push:apply('start')

  -- background
  love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

  -- set font and display welcome message
  love.graphics.setFont(smallfont)
  if gameState  == 'start' then
    love.graphics.printf('Welcome to Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter to Play!', 0, 32, VIRTUAL_WIDTH, 'center')

  elseif gameState == 'serve' then
    love.graphics.printf("Player ".. tostring(servingPlayer) .."'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter to Serve!', 0, 32, VIRTUAL_WIDTH, 'center')

  elseif gameState == 'victory' then
    love.graphics.setFont(victoryFont)
    love.graphics.printf("Player " .. tostring(victoryPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(smallfont)
    love.graphics.printf('Press Enter to restart!', 0, 42, VIRTUAL_WIDTH, 'center')
  end

  -- set font and display score points
  love.graphics.setFont(scorefont)
  love.graphics.print(player1score, X_MIDDLE - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(player2score, X_MIDDLE + 30, VIRTUAL_HEIGHT / 3)


  -- print the BALL
  ball:render()

  -- LEFT PADDLE
  player1:render()

  -- RIGHT PADDLE
  player2:render()

  displayFPS()

  push:apply('end')
end

function displayFPS()
  love.graphics.setColor(0, 1, 0, 1)

  love.graphics.setFont(smallfont)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)

  love.graphics.setColor(1, 1, 1, 1)

end