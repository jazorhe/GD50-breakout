ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    -- grab game state from params
    self.paddle     = params.paddle
    self.bricks     = params.bricks
    self.health     = params.health
    self.score      = params.score
    self.highScores = params.highScores
    self.level      = params.level
    self.powers     = params.powers

    -- init new ball (random color for fun)
    self.ball = Ball(self.paddle.skin)
    self.adjustPaddle = false
end

function ServeState:update(dt)
    -- have the ball track the player
    self.paddle:update(dt)
    self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
    self.ball.y = self.paddle.y - 10

    if TEST_MODE then
        if love.keyboard.wasPressed(']') then
            self.score = self.score + 1000
        elseif love.keyboard.wasPressed('[')then
            self.score = self.score - 1000
        end

        if love.keyboard.wasPressed('1') then
            self.paddle:resize(1)
        elseif love.keyboard.wasPressed('2') then
            self.paddle:resize(2)
        elseif love.keyboard.wasPressed('3') then
            self.paddle:resize(3)
        elseif love.keyboard.wasPressed('4') then
            self.paddle:resize(4)
        end

    end

    if self.level == 2 and not self.adjustPaddle then
        self.paddle:resize(math.max(1, self.paddle.size - 1))
        self.adjustPaddle = true
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        -- pass in all important state info to the PlayState
        gStateMachine:change('play', {
            paddle      = self.paddle,
            bricks      = self.bricks,
            health      = self.health,
            score       = self.score,
            highScores  = self.highScores,
            ball        = self.ball,
            level       = self.level,
            powers      = self.powers
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    self.paddle:render()
    self.ball:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end
