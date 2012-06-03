-- Example: Avalanche of LOVE

-- Contains all the balls.
balls = {}

-- Contains all the boxes. (Terrain)
boxes = {}

players = {}
player= 1

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
    world = love.physics.newWorld(0, 400)

    -- Create ground body.
    local b = love.physics.newBody(world, screenWidth / 2, screenHeight - 5, "static")
    local s = love.physics.newRectangleShape(0, 0, screenWidth, 10)
    ground = love.physics.newFixture(b, s)

    local s = love.physics.newCircleShape(32)

    local x = 100
    local y = 300
    local b = love.physics.newBody(world, x, y, "dynamic")
    local t = {}
    t.i = images.green
    t.f = love.physics.newFixture(b, s)
    t.f:setRestitution(0.4);
    table.insert(players, t)

    -- Add all the balls.
    -- addball(balldefs[1], 50) -- Add 100 green.
    -- addball(balldefs[2], 5) -- Add 5 big.
    -- addball(balldefs[3], 25) -- Add 50 pink.

    -- This generates the terrain.
    -- for i = 0, 10 do
    --     addbox(i*50, i*50+100)
    -- end

end

pi= math.pi
pi2= math.pi / 2
pi4= math.pi / 4
pi8= math.pi / 8
pi16= math.pi / 16

playerRadius= 40

function love.update(dt)

    -- Update the world.
    world:update(dt)

    local x, y = love.mouse.getPosition()
    local b= players[player].f:getBody()
    -- print(x, y, b:getX(), b:getY())
    local bx= b:getX()
    local by= b:getY()

    local dist = (math.sqrt((x - bx) * (x - bx) + (y - by) * (y - by)) - playerRadius) / 2
    if dist < 0 then dist= 0 end
    if dist > 100 then dist= 100 end
    players[player].dist= dist

    local angle = math.atan2(y - by, x - bx)
    if angle > -pi16 then angle= -pi16 end
    if angle < -pi2 + pi16 then angle= -pi2 + pi16 end
    players[player].angle= angle

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

function drawRectangle(mode, fixture)
   local x1, y1, x2, y2 = fixture:getBoundingBox()
   local w = x2 - x1
   local h = y2 - y1
   local b = fixture:getBody()
   love.graphics.rectangle(mode, b:getX() - w / 2, b:getY() - h / 2, w, h)
end

-- function _xyOfs(x, y,

function love.draw()

    -- Draw all the balls.
    for i,v in ipairs(players) do
        local b = v.f:getBody()
        local x, y = b:getPosition()
        local angle = x * 2 / playerRadius
        local dist= v.dist
        local vx, vy = b:getLinearVelocity()
        local vv = vx * vx + vy * vy

        if vv < 20 and dist > 0 then
            local sin= math.sin(v.angle + pi2)
            local cos= math.cos(v.angle + pi2)
            local x1, y1= x + sin * playerRadius, y - cos * playerRadius
            local x2, y2= x + sin * (playerRadius + dist), y - cos * (playerRadius + dist)
            love.graphics.line(x1, y1, x2, y2)

            angle= angle + v.angle + pi2 - pi16

            if love.mouse.isDown("l") then
                print("click", x2 - x1, y2 - y1)
                -- v.f:setRestitution(0.1)
                b:setLinearDamping(0.5)
                local fact= 10
                b:setLinearVelocity((x2 - x1) * fact, (y2 - y1) * fact)
            end
        end

        b:setAngle(angle)
        love.graphics.draw(v.i, x, y, angle, 1, 1, 36, 36)
    end
    -- Draw all the boxes.
    -- for i,v in ipairs(boxes) do
    --     love.graphics.polygon("line", v.s:getPoints())
    -- end

    drawRectangle("fill", ground);
    -- love.graphics.polygon("line", ground:getShape():getPoints())
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
