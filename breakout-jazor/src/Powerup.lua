Powerup = Class{}

powerFrames = {
    ['ball'] = 9,
    ['key'] = 10
}

function Powerup:init(type, params)
    self.type = type
    self.frame = powerFrames[self.type]

    self.powerEffect = {
        ['ball'] = function() return Powerup:ballPower() end,
        ['key'] = function() return Powerup:keyPower() end
    }
    self.powerEffect = self.powerEffect[self.type]

    self.x = params.x
    self.y = params.y
    self.width = 16
    self.height = 16

    self.inPlay = true
    self.active = false
end


function Powerup:update(dt)
    if self.inPlay then
        self.y = self.y + 2
        gSounds['victory']:play()
    end

    if self.active then
        -- self.powerInEffect(self, dt)
    end
end


function Powerup:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'], gFrames['powers'][self.frame], self.x - self.width / 2, self.y)
    end

    if self.active then
        -- self.powerRender(self)
    end

end

function Powerup:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    return true
end

function Powerup:collect()
    self.inPlay = false
    self.active = true
end

function Powerup:ballPower()

end

function Powerup:keyPower()
    keyCount = keyCount + 1
end
