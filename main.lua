-- https://github.com/Ulydev/push
push = require 'Res/push'

-- load classic file to handle classes in lua
Classic = require 'Res/classic'

-- load ball and paddle model classes
require 'Paddle'
require 'Ball'

--Constant Variables
WINDOW_WIDTH = 960
WINDOW_HEIGHT = 570

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
WINNING_SCORE = 10

FILL_MODE = 'fill'

music = {
    ['paddle_hit_sound'] = love.audio.newSource('Music/paddleMusic.wav','static'),
    ['score_sound'] = love.audio.newSource('Music/scoreMusic.wav','static'),
    ['wall_hit_sound'] = love.audio.newSource('Music/wallMusic.wav','static'),
    ['winner_sound'] = love.audio.newSource('Music/winnerMusic.wav','static')
}


function love.load()
    -- love.window.setMode(WINDOW_WIDTH,WINDOW_HEIGHT,{
    --     fullscreen = false,
    --     resizable = false,
    --     vsync =true
    -- })

    -- using nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text and graphics
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Ping Pong')

    -- random number generator seed
    math.randomseed(os.time())

    -- to get the font style from file and declare size of font
    gameHeaderFont = love.graphics.newFont('Res/font.ttf',8)

    scoreFont = love.graphics.newFont('Res/font.ttf',32)

    --to set the the font
    love.graphics.setFont(gameHeaderFont)

    --initialize the score of players
    playerAScore = 0
    playerBScore = 0

    servingPlayer = 'A'
    if math.random(1,2) == 2 then
        servingPlayer = 'B'
    end

    --initialize player's paddle
    playerAPaddle = Paddle(5,30,5,20,PADDLE_SPEED,'blue')
    playerBPaddle = Paddle(VIRTUAL_WIDTH - 10,VIRTUAL_HEIGHT - 50,5,20,PADDLE_SPEED,'red')

    --initialize ball
    ball = Ball(VIRTUAL_WIDTH/2 - 2,VIRTUAL_HEIGHT/2 -2,4,4)

    --track the status of the game
    status = 'notStarted'

    -- set the virtual resolution , which will render within actual window
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = false,
        vsync =true
    })
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit() -- to terminate or exit the application
    elseif key == 'enter' or key == 'return' then
        if status == 'notStarted' or status == 'playing' then
            status = 'started'
        else
            status = 'notStarted'

            -- reset position of ball
            ball:resetPosition()
        end
    end
end


function love.update(dt)

    -- player A paddle movement
    if love.keyboard.isDown('w') then
        playerAPaddle:moveUp(dt)
    elseif love.keyboard.isDown('s') then
        playerAPaddle:moveDown(dt)
    end

    -- player B paddle movement
    if love.keyboard.isDown('up') then
        playerBPaddle:moveUp(dt)
    elseif love.keyboard.isDown('down') then
        playerBPaddle:moveDown(dt)
    end

    if status ~= 'notStarted' then
    --check for winner
        if playerAScore == WINNING_SCORE then
            status = 'notStarted'
            ball:resetPosition()
            playerAScore = 0
            playerBScore = 0
            servingPlayer = 'B'
            ball.deltaX = -100
            music.winner_sound:play()
            love.window.showMessageBox('We have a Winner','Player A Wins !!',{'OK',escapeButton = 1})
        end

        if playerBScore == WINNING_SCORE then
            status = 'notStarted'
            ball:resetPosition()
            playerAScore = 0
            playerBScore = 0
            servingPlayer = 'A'
            ball.deltaX = 100
            music.winner_sound:play()
            love.window.showMessageBox('We have a Winner','Player B Wins !!',{'OK',escapeButton = 1})
        end
    end

    if status == 'started' then
        -- move ball
        ball:moveBall(dt)

        --check if ball hits the horizontal edges of window
        if collidesWithUpperEdges(ball) then
            music.wall_hit_sound:play()
            ball.y = 0
            ball.deltaY = - 1 * ball.deltaY
        end

        if collidesWithLowerEdges(ball) then
            music.wall_hit_sound:play()
            ball.y = VIRTUAL_HEIGHT - ball.height
            ball.deltaY = -1 * ball.deltaY
        end

        --check if ball hits the vertical edges of window
        if collidesWithLeftEdge(ball) then
            music.score_sound:play()
            servingPlayer = 'A'
            playerBScore = playerBScore + 1
            ball:resetPosition()
            ball.deltaX = 100
            status = 'playing' 
        end

        if collidesWithRightEdge(ball) then
            music.score_sound:play()
            servingPlayer = 'B'
            playerAScore = playerAScore + 1
            ball:resetPosition()
            ball.deltaX = -100
            status = 'playing' 
        end

        --check if paddle A collides with ball reverse the ball direction
        if isCollisionHappend(playerAPaddle,ball) then
            ball.deltaX = ball.deltaX * -1.0
            ball.x = playerAPaddle.x + 5

            -- randomize deltaY in same direction
            if ball.deltaY < 0 then
                ball.deltaY = -1 * math.random(10,150)
            else
                ball.deltaY = math.random(10,150)
            end
        end
        
        --check if paddle B collides with ball reverse the ball direction
        if isCollisionHappend(playerBPaddle,ball) then
            ball.deltaX = ball.deltaX * -1.0
            ball.x = playerBPaddle.x - 4

            -- randomize deltaY in same direction
            if ball.deltaY < 0 then
                ball.deltaY = -1 * math.random(10,150)
            else
                ball.deltaY = math.random(10,150)
            end
        end
    end
end

function collidesWithUpperEdges(ballBox)
    if ballBox.y <= 0 then
        return true
    end

    return false
end

function collidesWithLowerEdges(ballBox)
    if ballBox.y + ballBox.height >= VIRTUAL_HEIGHT then
        return true
    end

    return false
end

function collidesWithLeftEdge(ballBox)
    if ballBox.x <= 0 then
        return true
    end

    return false
end

function collidesWithRightEdge(ballBox)
    if ballBox.x + ballBox.width >= VIRTUAL_WIDTH then
        return true
    end

    return false
end

function isCollisionHappend(paddleBox , ballBox)
    if paddleBox.x <= ballBox.x + ballBox.width and paddleBox.x + paddleBox.width >= ballBox.x then
        if paddleBox.y <= ballBox.y + ballBox.height and paddleBox.y + paddleBox.height >= ballBox.y then
            music.paddle_hit_sound:play()
            return true
        else
            return false
        end
    else
        return false
    end
end


function love.draw()

   --begin virtual resolution
   push:apply('start')

    --clear the screen with specified color love.graphics.clear(r,g,b,opaque)
   love.graphics.clear(40/255,45/255,52/255,255/255)

   -- set game header and font
   love.graphics.setFont(gameHeaderFont)

   if status == 'notStarted' then
        love.graphics.printf('Press Enter to Start the Game!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif status == 'started' then
        love.graphics.printf('Game Started', 0, 20, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Player : ' .. servingPlayer .. ' will serve', 0, 20, VIRTUAL_WIDTH, 'center')
    end


   --set players score text and font
   love.graphics.setFont(scoreFont)
   love.graphics.print(tostring(playerAScore),VIRTUAL_WIDTH/2 - 50,VIRTUAL_HEIGHT/3)
   love.graphics.print(tostring(playerBScore),VIRTUAL_WIDTH/2 + 30,VIRTUAL_HEIGHT/3)

   -- left paddle (Player A) 
   playerAPaddle:renderPaddle()

   -- right paddle (Player B)
   playerBPaddle:renderPaddle()

   -- center ball
   ball:renderBall()

   --end virtual resolution
   push:apply('end')
end