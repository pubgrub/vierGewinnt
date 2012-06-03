
TOWER_X = 400
GROUND_Y = 15
BASE_H = 20
COL_H = 180
COL_W = 10
SLOT_W = 30
BALL_W = SLOT_W / 2 - 2
TOWER_W = COL_W * 8 + SLOT_W * 7
TOWERSPIKE_H = 2

PI= math.pi
PI2= math.pi / 2
PI4= math.pi / 4
PI8= math.pi / 8
PI16= math.pi / 16

ball= {}
tower= {}
players = {}
player= 1

waitForMouseUp = true

screenWidth= 0
screenHeight= 0

function initBall()
    ball.body = love.physics.newBody( world, 505, 100, "dynamic")
    ball.body:setMass( 50)
    ball.shape = love.physics.newCircleShape( BALL_W)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape)
    ball.fixture:setRestitution( 0.4)
end

function initTower()
    tower.base = {}
    local body = love.physics.newBody( world, ( screenWidth - TOWER_W) / 2, screenHeight - GROUND_Y - BASE_H)
    local shape = love.physics.newPolygonShape(  0,       0,
                                                 TOWER_W, 0,
                                                 TOWER_W, BASE_H,
                                                 0,       BASE_H)
    tower.base.fixture = love.physics.newFixture( body, shape)
    tower.cols = {}
    for i = 0,7 do
      col = {}
      local body = love.physics.newBody( world, ( screenWidth - TOWER_W) / 2 +i * ( COL_W + SLOT_W), screenHeight - GROUND_Y - BASE_H - COL_H)
      local shape = love.physics.newPolygonShape( 0, TOWERSPIKE_H,
                                                  0, COL_H,
                                                  COL_W, COL_H,
                                                  COL_W, TOWERSPIKE_H,
                                                  COL_W / 2, 0)
      col.fixture = love.physics.newFixture( body, shape)
      table.insert( tower.cols, col)
    end
end

function initGround()
    local body = love.physics.newBody(world, screenWidth / 2, screenHeight - 5, "static")
    local shape = love.physics.newRectangleShape(0, 0, screenWidth, 10)
    ground = love.physics.newFixture(body, shape)
end

function initPlayers()

    -- Load images.
    -- FIXME: Nur green wird benutzt
    local images = {
        green = love.graphics.newImage("green_ball.png"),
    --     big_love = love.graphics.newImage("big_love_ball.png"),
    --     love = love.graphics.newImage("love_ball.png"),
    }

    -- Image / radius pairs.
    -- FIXME: UNUSED
    -- local balldefs = {
    --     { i = images.green,     r = 32 , ox = 36, oy = 36},
    --     { i = images.big_love,  r = 46 , ox = 48, oy = 48},
    --     { i = images.love,      r = 28 , ox = 32, oy = 32},
    -- }

    local addPlayer= function(x)
        local shape = love.physics.newCircleShape(BALL_W)
        local y = 300
        local body = love.physics.newBody(world, x, y, "dynamic")
        local t = {}
        t.image = images.green
        t.fixture = love.physics.newFixture(body, shape)
        t.fixture:setRestitution(0.4);
        table.insert(players, t)
    end

    addPlayer(100)
    addPlayer(screenWidth - 100)
end

function love.load()
    love.graphics.setBackgroundColor( 200, 150, 100)

    screenWidth= love.graphics.getWidth();
    screenHeight= love.graphics.getHeight();

    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * love.physics.getMeter(), true)

    initBall()
    initTower()
    initGround()
    initPlayers()
end

function updatePlayer(dt)
    local x, y = love.mouse.getPosition()
    local body= players[player].fixture:getBody()
    -- print(x, y, body:getX(), body:getY())
    local bx= body:getX()
    local by= body:getY()

    local dist = (math.sqrt((x - bx) * (x - bx) + (y - by) * (y - by)) - BALL_W) / 2
    if dist < 0 then dist= 0 end
    if dist > 100 then dist= 100 end

    local angle = math.atan2(y - by, x - bx)
    if player == 1 then
        if angle > -PI16 then angle= -PI16 end
        if angle < -PI2 + PI16 then angle= -PI2 + PI16 end

        -- TODO: dist auf 0 wenn angle total falsch
    else
        if angle > -PI2 - PI16 then angle= -PI2 - PI16 end
        if angle < -PI + PI16 then angle= -PI + PI16 end
    end

    players[player].dist= dist
    players[player].angle= angle
end

function love.update( dt)
    world:update( dt)
    updatePlayer(dt)
end

function drawPolygon( mode, fixture)
    local shape = fixture:getShape()
    local body = fixture:getBody()

--    print( "drawPolygon start")
--    print( "s:getPoints: ", s:getPoints())
--    print( "b:getPositions: ", b:getPosition())
--    print( "b:getWorldPoints(s:getPoints() ): ", b:getWorldPoints(s:getPoints() ))
--    print( "drawPolygon stop")

    love.graphics.polygon( mode, body:getWorldPoints(shape:getPoints() ) )
end

function drawRectangle(mode, fixture)
    local x1, y1, x2, y2 = fixture:getBoundingBox()
    local w = x2 - x1
    local h = y2 - y1
    local body = fixture:getBody()
    love.graphics.rectangle(mode, body:getX() - w / 2, body:getY() - h / 2, w, h)
end

function drawBall()
    love.graphics.setColor( 220, 40, 60)
    love.graphics.circle( "fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius() )
end

function drawTower()
    love.graphics.setColor( 220, 40, 60)
    drawPolygon( "fill", tower.base.fixture)
    for i, col in ipairs( tower.cols) do
        drawPolygon( "fill", col.fixture)
    end
end

function drawGround()
    love.graphics.setColor( 220, 40, 60)
    drawRectangle("fill", ground);
end

function drawPlayer()
    for i,v in ipairs(players) do
        local body = v.fixture:getBody()
        local x, y = body:getPosition()
        local angle = x * 2 / BALL_W
        local dist= v.dist
        local vx, vy = body:getLinearVelocity()
        local vv = vx * vx + vy * vy

        if vv < 20 and dist ~= nil and dist > 0 and i == player then
            local sin= math.sin(v.angle + PI2)
            local cos= math.cos(v.angle + PI2)
            local x1, y1= x + sin * BALL_W, y - cos * BALL_W
            local x2, y2= x + sin * (BALL_W + dist), y - cos * (BALL_W + dist)
            love.graphics.line(x1, y1, x2, y2)

            angle= angle + v.angle + PI2 - PI16

            if love.mouse.isDown("l") then
                if not waitForMouseUp then
                    print("click", x2 - x1, y2 - y1)
                    -- v.fixture:setRestitution(0.1)
                    body:setLinearDamping(0.5)
                    local fact= 10
                    body:setLinearVelocity((x2 - x1) * fact, (y2 - y1) * fact)

                    player = 3 - player
                    waitForMouseUp = true
                end
            else
                waitForMouseUp = false
            end
        end

        body:setAngle(angle)
        local o= 36 -- Warum 36??
        love.graphics.draw(v.image, x, y, angle, BALL_W / 36, BALL_W / 36, o, o)
    end
end

function love.draw()
    drawBall()
    drawTower()
    drawGround()
    drawPlayer()
end
