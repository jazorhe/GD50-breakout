Powerup = Class{}

powerFrames = {
    ['ball'] = 9
}

-- powerEffectInits = {
--     ['ball'] = function(power, params) return Powerup:ballPowerInit(power, params) end
-- }
--
-- powerEffectUpdates = {
--     ['ball'] = function(power, dt) return Powerup:ballPowerUpdate(power, dt) end
-- }
--
-- powerEffectRenders = {
--     ['ball'] = function(power) return Powerup:ballPowerRender(power) end
-- }
--
-- powerEffectDestorys = {
--     ['ball'] = function() return Powerup:ballPowerDestory() end
-- }

function Powerup:init(type, params)
    self.type = type
    self.frame = powerFrames[self.type]
    -- self.powerInit = powerEffectInits[self.type]
    -- self.powerInEffect = powerEffectUpdates[self.type]
    -- self.powerRender = powerEffectRenders[self.type]

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

function Powerup:collect(params)
    self.inPlay = false
    self.active = true
end

-- function Powerup:ballPowerInit(power, params)
--
-- end
--
-- function Powerup:ballPowerUpdate(power, dt)
--
-- end
--
-- function Powerup:ballPowerRender(power)
--
-- end
--
-- function Powerup:ballPowerDestory()
--
-- end
