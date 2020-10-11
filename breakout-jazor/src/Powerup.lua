Powerup = Class{}

function Powerup:init(type, x, y)
    self.type = type
    self.power = gPowers[type]

    self.x = x
    self.y = y
    self.width = 16
    self.height = 16

    self.inPlay = true
    self.effective = false
end


function Powerup:update(dt)

end


function Powerup:render()

end


function Powerup:ballPower()
    gSounds['victory']:play()
end
