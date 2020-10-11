PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = {params.ball}
    self.level = params.level
    self.powers = params.powers
    self.bricksLeft = #self.bricks

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-150, 150)
    self.balls[1].dy = math.random(-200)
    self.balls[1].served = true

    self.keysNeeded = 0
    for k, brick in pairs(self.bricks) do
        if brick.key then
            self.keysNeeded = self.keysNeeded + 1
        end
    end
    self.keyBlocks = {}
    keyCount = 0
end

function PlayState:update(dt)
    -- handle pausing
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    if TEST_MODE then
        if love.keyboard.wasPressed('r') then
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = 3,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                powers = self.powers
            })
        end
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    -- update all balls
    for k, ball in pairs(self.balls) do

        -- attach unserved balls to paddle
        if ball.served == false then
            ball.x = self.paddle.x + (self.paddle.width / 2) - 4
            ball.y = self.paddle.y - 10
            if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
                ball.dx = math.random(-150, 150)
                ball.dy = math.random(-200)
                ball.served = true
            end
        else
            ball:update(dt)
        end

        -- detect ball collision with paddle
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

                -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)


                if not brick.key then
                    -- trigger the brick's hit function, which removes it from play
                    brick:hit()
                end

                if not brick.inPlay then
                    self:spawnPowerup(brick.x + brick.width / 2, brick.y)
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = ball
                    })
                end

                -- left edge; only check if we're moving right
                if ball.x + 2 < brick.x and ball.dx > 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - ball.width

                    -- right edge; only check if we're moving left
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + brick.width

                    -- top edge if no X collisions, always check
                elseif ball.y < brick.y then

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - ball.height

                    -- bottom edge if no X collisions or top collision, last possibility
                else

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + brick.height
                end

                -- slightly scale the y velocity to speed up the game
                ball.dy = ball.dy * 1.02

                -- only allow colliding with one brick, for corners
                break
            end
        end
        -- if ball goes below bounds, revert to serve state and decrease health
        if ball.y >= VIRTUAL_HEIGHT then
            gSounds['hurt']:play()
            table.remove(self.balls, k)

            if #self.balls == 0 then
                self.health = self.health - 1

                -- die or serve while making paddle larger
                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    local newSize = math.min(4, self.paddle.size + 1)
                    self.paddle:resize(newSize)

                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        powers = {}
                    })
                end
            end
        end
    end

    -- for rendering powerups
    for k, power in pairs(self.powers) do
        power:update(dt)

        -- check powerup blocks collides with padddle
        if power.inPlay and power:collides(self.paddle) then
            gSounds['select']:play()
            power:collect()
            if power.type == 'ball' then
                self.balls[#self.balls + 1] = Ball(self.paddle.skin)
                self.balls[#self.balls + 1] = Ball(self.paddle.skin)
            elseif power.type == 'key' then
                keyCount = keyCount + 1
            end
        end

    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
        if brick.key then
            table.insert(self.keyBlocks, brick)
        end

        self.bricksLeft = 0
        if brick.inPlay then
            self.bricksLeft = self.bricksLeft + 1
        end
    end

    if self.keysNeeded > 0 and keyCount > 0 then
        local index = math.random(#self.keyBlocks)
        self.keyBlocks[index]:hit()
        self.keyBlocks[index].key = false
        self.keyBlocks[index].inPlay = false
        self.keysNeeded = self.keysNeeded - 1
        keyCount = keyCount - 1
    end
    self.keyBlocks = {}

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    for k, ball in pairs(self.balls) do
        ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    for k, power in pairs(self.powers) do
        power:render()
    end

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end

function PlayState:spawnPowerup(x, y)

    if math.random(1,3) == 1 then
        p = Powerup('ball', {
            ['x'] = x,
            ['y'] = y
        })
        table.insert(self.powers, p)
    elseif self.keysNeeded > 0 and (math.random(1,5) == 1 or self.bricksLeft < 5) then
        p = Powerup('key', {
            ['x'] = x,
            ['y'] = y
        })
        table.insert(self.powers, p)
    end
end
