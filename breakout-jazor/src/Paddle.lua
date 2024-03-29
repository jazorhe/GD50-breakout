Paddle = Class{}

function Paddle:init(skin, size)

    self.dx = 0
    self.skin = skin
    self.size = size
    if self.size == 1 then
        self.width = 32
    elseif self.size == 2 then
        self.width = 64
    elseif self.size == 3 then
        self.width = 96
    else
        self.width = 128
    end
    self.height = 16

    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT - 32

end

function Paddle:update(dt)
    -- keyboard input
    if love.keyboard.isDown('left') or love.keyboard.isDown('a')   then
        self.dx = -PADDLE_SPEED
    elseif love.keyboard.isDown('right') or love.keyboard.isDown('d')  then
        self.dx = PADDLE_SPEED
    else
        self.dx = 0
    end

    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end
end

--[[
    Render the paddle by drawing the main texture, passing in the quad
    that corresponds to the proper skin and size.
]]
function Paddle:render()
    love.graphics.draw(gTextures['main'], gFrames['paddles'][self.size + 4 * (self.skin - 1)],
        self.x, self.y)
end


function Paddle:resize(size)
    self.size = size
    if self.size == 1 then
        self.width = 32
    elseif self.size == 2 then
        self.width = 64
    elseif self.size == 3 then
        self.width = 96
    else
        self.width = 128
    end
    self.height = 16
end
