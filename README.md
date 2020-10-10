# GD50-breakout
-- Enter Description Here...

## Developing and Learning Notes:
* breakout0
    * StartState
    * Dependencies.lua
    * constants.lua
    * Folder Structure

* breakout1: The Sprite Sheet Update
    * Sprite Sheets (Util.lua)
    * Use of sprite sheet for various sizes quads:
    * StartState

    <img src="/img/quad-with-different-sizes.png" width="70%">

```
function GenerateQuadsPaddles(atlas)
    local x = 0
    local y = 64

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        -- smallest
        quads[counter] = love.graphics.newQuad(x, y, 32, 16,
            atlas:getDimensions())
        counter = counter + 1
        -- medium
        quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16,
            atlas:getDimensions())
        counter = counter + 1
        -- large
        quads[counter] = love.graphics.newQuad(x + 96, y, 96, 16,
            atlas:getDimensions())
        counter = counter + 1
        -- huge
        quads[counter] = love.graphics.newQuad(x, y + 16, 128, 16,
            atlas:getDimensions())
        counter = counter + 1

        -- prepare X and Y for the next set of paddles
        x = 0
        y = y + 32
    end

    return quads
end
```

* breakout2: The Bounce Update
    *

* breakout3: The Brick Update
    *

## Up Next
* Procedural Layouts
* Managing State
* Levels
* Player Health
* Particle Systems
* Collision Detection Revisited
* Persistent Save Data
