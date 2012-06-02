-- Example: Avalanche of LOVE

-- Contains all the balls.
balls = {}

-- Contains all the boxes. (Terrain)
boxes = {}

function love.load()

    -- love.graphics.setMode(1024, 768)

    local screenWidth= love.graphics.getWidth();
    local screenHeight= love.graphics.getHeight();

    -- Fat lines.
    love.graphics.setLineWidth(2)

    -- Load images.
    images = {
        green = love.graphics.newImage("green_ball.png"),
        big_love = love.graphics.newImage("big_love_ball.png"),
        love = love.graphics.newImage("love_ball.png"),
    }

    -- Image / radius pairs.
    balldefs = {
        { i = images.green,     r = 32 , ox = 36, oy = 36},
        { i = images.big_love,  r = 46 , ox = 48, oy = 48},
        { i = images.love,      r = 28 , ox = 32, oy = 32},
    }

    -- Create the world.
    world = love.physics.newWorld(0, 50)

    -- Create ground body.
    local b = love.physics.newBody(world, screenWidth / 2, screenHeight - 5, "static")
    local s = love.physics.newRectangleShape(0, 0, screenWidth, 10)
    ground = love.physics.newFixture(b, s)

    local s = love.physics.newCircleShape(30)

    local x = 100
    local y = 300
    local b = love.physics.newBody(world, x, y, "dynamic")
    local t = {}
    t.i = images.green
    t.f = love.physics.newFixture(b, s)
    table.insert(balls, t)

    -- Add all the balls.
    -- addball(balldefs[1], 50) -- Add 100 green.
    -- addball(balldefs[2], 5) -- Add 5 big.
    -- addball(balldefs[3], 25) -- Add 50 pink.

    -- This generates the terrain.
    -- for i = 0, 10 do
    --     addbox(i*50, i*50+100)
    -- end

end

function love.update(dt)

    -- Update the world.
    world:update(dt)

    -- Check whether we need to reset some balls.
    -- When they move out of the screen, they
    -- respawn above the screen.
    -- for i,v in ipairs(balls) do
    -- local x, y = v.b:getPosition()
    --     if x > 850 or y > 650 then
    --         v.b:setPosition(math.random(0, 400), -math.random(100, 1500))
    --         v.b:setLinearVelocity(0, 0)
    --     end
    -- end

end

function love.draw()
    -- Draw all the balls.
    for i,v in ipairs(balls) do
        local b= v.f:getBody()
        love.graphics.draw(v.i, b:getX(), b:getY(), b:getAngle(), 1, 1, -15, -15)
    end
    -- Draw all the boxes.
    -- for i,v in ipairs(boxes) do
    --     love.graphics.polygon("line", v.s:getPoints())
    -- end

    love.graphics.polygon("line", ground:getShape():getPoints())
end

-- Adds a static box.
function addbox(x, y)
    local t = {}
    t.b = ground
    t.s = love.physics.newRectangleShape(x, y, 50, 50)
    t.f = love.physics.newFixture(t.b, t.s)
    table.insert(boxes, t)
end


-- Adds X balls.
function addball(def, num)

    local s = love.physics.newCircleShape(def.r)

    for i=1,num do
        local x, y = math.random(0, 400), -math.random(100, 1500)
        local t = {}
        t.b = love.physics.newBody(world, x, y, "dynamic")
        t.f = love.physics.newFixture(t.b, s)
        t.i = def.i
        t.ox = def.ox
        t.oy = def.oy
        -- t.b:setMassFromShapes()
        table.insert(balls, t)
    end
end
