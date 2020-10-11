Powerup = Class{}

powerFrames = {
    ['ball'] = 9
}

powerEffects = {
    ['ball'] = function() return Powerup:ballPower() end
}

function Powerup:init(type, x, y)
    self.type = type
    self.frame = powerFrames[self.type]
    self.power = powerEffects[self.type]

    self.x = x
    self.y = y
    self.width = 16
    self.height = 16

    self.inPlay = true
    self.effective = false
end


function Powerup:update(dt)
    self.y = self.y + 2
end


function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powers'][self.frame], self.x - self.width / 2, self.y)
end


function Powerup:ballPower()
    gSounds['victory']:play()
end
