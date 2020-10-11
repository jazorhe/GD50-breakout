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

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-150, 150)
    self.balls[1].dy = math.random(-200)
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

    -- quick reset for testing purposes
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

    -- update positions based on velocity
    self.paddle:update(dt)

    for k, ball in pairs(self.balls) do
        ball:update(dt)

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

                -- trigger the brick's hit function, which removes it from play
                brick:hit()
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

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly
                --

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
                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
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



    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    -- for rendering powerups
    for k, power in pairs(self.powers) do
        power:update(dt)

        -- check powerup blocks collides with padddle
        if power.inPlay and power:collides(self.paddle) then
            gSounds['select']:play()
            power:collect({
                ['paddle'] = self.paddle
            })
        end

    end

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

-- TODO:this can probably live somehwere else (split: table insertion in above Playstate:update(dt) and initialization in Powerup:init())
function PlayState:spawnPowerup(x, y)
    if false then
        p = Powerup('ball', {
            ['x'] = x,
            ['y'] = y,
            ['skin'] = self.paddle.skin
        })
        table.insert(self.powers, p)
    end
end
