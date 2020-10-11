# GD50-breakout

\-- Enter Description Here...

# Developing & Learning Notes:
-   ## breakout0
    -   StartState.lua
    -   Dependencies.lua
    -   constants.lua
    -   Folder Structure


-   ## breakout1: The Sprite Sheet Update
    -   Sprite Sheets (Util.lua)
    -   Use of sprite sheet for various sizes quads:

Quads Division:

<img src="/img/quad-with-different-sizes.png" width="70%">

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

-   ## breakout2: The Bounce Update
    -   Ball.lua
    -   Added GenerateQuadsBalls to Util.lua
    -   Used AABB to check ball collision with Paddle
    -   Added Collision with walls


-   ## breakout3: The Brick Update
    -   Brick.lua
    -   Added GenerateQuadsBricks to Util.lua
    -   LevelMaker.lua
    -   Check Ball collides with Bricks and set "self.input" (good for small games)


-   ## breakout4: The Collision Update
    -   Tweak Paddle Bounce dx if moving in same direction
    -   Check which edge of Brick does the Ball collide with


Paddle Collision:

<img src="/img/paddle-collision.png" width="70%">


        -- left edge; only check if we're moving right
        if self.ball.x + 2 < brick.x and self.ball.dx > 0 then

            -- flip x velocity and reset position outside of brick
            self.ball.dx = -self.ball.dx
            self.ball.x = brick.x - 8

        -- right edge; only check if we're moving left
        elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then

            -- flip x velocity and reset position outside of brick
            self.ball.dx = -self.ball.dx
            self.ball.x = brick.x + 32

        -- top edge if no X collisions, always check
        elseif self.ball.y < brick.y then

            -- flip y velocity and reset position outside of brick
            self.ball.dy = -self.ball.dy
            self.ball.y = brick.y - 8

        -- bottom edge if no X collisions or top collision, last possibility
        else

            -- flip y velocity and reset position outside of brick
            self.ball.dy = -self.ball.dy
            self.ball.y = brick.y + 16
        end

        -- slightly scale the y velocity to speed up the game
        self.ball.dy = self.ball.dy * 1.02

        -- only allow colliding with one brick, for corners
        break


-   ## breakout5: The Hearts Update
    -   Passing Parameters when entering different States
    -   ServeState.lua
    -   renderHealth(health)
    -   renderScore(score)
    -   GameOverState.lua


-   ## breakout6: The Pretty Colors Update
    -   Skip
    -   Alternate
    -   Lua's Continue


Color Patterns and Skipping:

<img src="/img/breakout6.png" width="70%">


-   ## breakout7: The Tier Update
    -   Add tier and color switching logic in Brick.lua


-   ## breakout8: The Particle Update
    -   https://love2d.org/wiki/ParticleSystem
    -   Colour Pallete
    -   Init Particle System
    -   self.psystem:emit(n) when Brick:hit()
    -   self.psystem:update(dt) in Brick:update(dt)
    -   Brick:renderParticles()

Particle Smoke Effect:

<img src="/img/breakout8.png" width="70%">


-   ## breakout9: The Progression Update
    -   Initial self.level in StartState.lua
    -   Pass the level parameter into ServeState and PlayState
    -   Pass the level parameter into VictoryState
    -   VictoryState.lua handles increment of level
    -   Pass the level parameter back to ServeState


-   ## breakout10: The High Score Update
    -   File System Functions


File System Functions:

<img src="/img/file-sys-functions.png" width="70%">


-   ## breakout11: The Enter High Score Update
    -   Choose Name Update


-   ## breakout12: The Paddle Select Update
    -   PaddleSelectState.lua
    -   Pass in skin value when initializing Paddle


Paddle Seleciton:

<img src="/img/breakout12.png" width="70%">


# Assignment 2
-   ## Objectives
    -   [x] Read and understand all of the Breakout source code from Lecture 2.
    -   [ ] Add a powerup to the game that spawns two extra Balls.
    -   [ ] Grow and shrink the Paddle when the player gains enough points or loses a life.
    -   [ ] Add a locked Brick that will only open when the player collects a second new powerup, a key, which should only spawn when such a Brick exists and randomly as per the Ball powerup.


-   ## Extra Ball Powerup Update
    -   Add Powers Sprite (Util.lua)
    -   Whenever a brick breaks, there is a chance it drops the Ball Powerup (Brick.lua)
    -   Powerup.lua: very basic, only in control for dropping powerup blocks and detech collidsion with paddle
    -   Need to allow multiple balls in play in PlayState
    -   Need to update and render all balls
    -   Only when no balls are in play where the game switches state


-   ## Paddle Size Update
    -   To Be Completed...


-   ## Key Powerup Update
    -   To Be Completed...


##  Helpful Links:
    -   Makrdown Language: https://guides.github.com/features/mastering-markdown/
