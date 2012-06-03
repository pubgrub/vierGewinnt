
GROUND_Y = 15
BASE_H = 20
COL_H = 180
COL_W = 10
SLOT_W = 30
BALL_R = SLOT_W / 2 - 2
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
-- player= 1
balls= {}
turn= 10
board = {}

waitForMouseUp = true

screenWidth= 0
screenHeight= 0

function player()
    return (turn % 2) + 1
end

function initBall()
    ball.body = love.physics.newBody( world, 490, 100, "dynamic")
    ball.body:setMass( 50)
    ball.shape = love.physics.newCircleShape( BALL_R)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape)
    ball.fixture:setRestitution( 0.05)
end

function initTower()
    tower.base = {}
    TOWER_X = ( screenWidth - TOWER_W) / 2
    local body = love.physics.newBody( world, TOWER_X, screenHeight - GROUND_Y - BASE_H)
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
        local shape = love.physics.newCircleShape(BALL_R)
        local y = 300
        local body = love.physics.newBody(world, x, y, "dynamic")
        local t = {}
        t.image = images.green
        t.fixture = love.physics.newFixture(body, shape)
        t.fixture:setRestitution(0.4)
        table.insert(players, t)
    end

    addPlayer(100)
    addPlayer(screenWidth - 100)
end

function initBalls()
    local shape = love.physics.newCircleShape(BALL_W)
    local i
    for i=1,42 do
        local x = (screenWidth - TOWER_W) / 2 + (SLOT_W + COL_W) / 2 + ((i - 1) % 7) * (COL_W + SLOT_W)
        local y = math.floor((i - 1) / 7) * COL_W
        local body = love.physics.newBody(world, x, y, "dynamic")
        body:setActive(i <= turn) -- fuers testen, normalerweise ist turn hier 0
        body:setLinearDamping(0.5)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setRestitution(0.4)
        table.insert(balls, fixture)
    end
end

function initBoard()
    board = {}
    board.positions = {}
    local boardBase = tower.base.fixture:getBody():getY()
    local x,y
    boardBalls = {}
    for y = 0, 5 do
        for x = 0,6 do
            local p = {}
            p.y = boardBase - BALL_R * 2 * ( y + 0.5)
            p.x = TOWER_X + COL_W + (COL_W + SLOT_W) * x + SLOT_W * 0.5
            table.insert( board.positions, p)
--            print( p.x, p.y)
--            b = {}
--            b.body = love.physics.newBody( world, p.x, p.y, "dynamic")
--            b.body:setMass( 50)
--            b.shape = love.physics.newCircleShape( BALL_R)
--            b.fixture = love.physics.newFixture(b.body, b.shape)
--            b.fixture:setRestitution( 0.05)
--            table.insert( boardBalls, b)
        end
    end
end

function love.load()
    love.graphics.setBackgroundColor( 200, 150, 100)

    screenWidth= love.graphics.getWidth()
    screenHeight= love.graphics.getHeight()

    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * love.physics.getMeter(), true)

    initBall()
    initTower()
    initGround()
    initPlayers()
    initBalls()
    initBoard()
end

aimLine= nil

function updatePlayer(dt)
    local x, y = love.mouse.getPosition()
    local body= players[player()].fixture:getBody()
    -- print(x, y, body:getX(), body:getY())
    local bx= body:getX()
    local by= body:getY()

    local dist = (math.sqrt((x - bx) * (x - bx) + (y - by) * (y - by)) - BALL_R) / 2
    if dist < 0 then dist= 0 end
    if dist > 100 then dist= 100 end

    local angle = math.atan2(y - by, x - bx)
    if player() == 1 then
        if angle > -PI16 then angle= -PI16 end
        if angle < -PI2 + PI16 then angle= -PI2 + PI16 end

        -- TODO: dist auf 0 wenn angle total falsch
    else
        if angle > -PI2 - PI16 then angle= -PI2 - PI16 end
        if angle < -PI + PI16 then angle= -PI + PI16 end
    end

    local pl= players[player()]

    pl.dist= dist
    pl.angle= angle

    aimLine= nil

    if dist > 0 then
        local sin= math.sin(angle + PI2)
        local cos= math.cos(angle + PI2)
        local x1, y1= bx + sin * BALL_W, by - cos * BALL_W
        local x2, y2= bx + sin * (BALL_W + dist), by - cos * (BALL_W + dist)

        aimLine= { x1= x1, y1= y1, x2= x2, y2= y2 }

        if love.mouse.isDown("l") then
            if not waitForMouseUp then

                local ball= balls[turn]
                ball:getBody():setActive(true)
                ball:getBody():setX(x1)
                ball:getBody():setY(y1)
                local fact= 10
                ball:getBody():setLinearVelocity((x2 - x1) * fact, (y2 - y1) * fact)
                turn = turn + 1

                print("click", x2 - x1, y2 - y1)

                waitForMouseUp = true
            end
        else
            waitForMouseUp = false
        end
    end

end

function updateBoard(dt)


    for i,p in ipairs(players) do
        for j,b in ipairs( p.balls) do
            local velX, velY = b.body:getLinearVelocity()
            if( velX == 0 and velY == 0) then
                local x,y = b.body:getPosition()
                if( x > TOWER_X and x < TOWER_X + TOWER_W and y > TOWER_Y and y < TOWER_Y + COH_H) then

                end
            end
        end
    end
end

function love.update( dt)
    world:update( dt)
    updatePlayer(dt)
    updateBoard(dt)
end

function drawPolygon( mode, fixture)
    local shape = fixture:getShape()
    local body = fixture:getBody()
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

function drawBalls()
    for i=1,turn do
        local ball= balls[i]
        if i % 2 == 0 then
            love.graphics.setColor(200, 0, 0)
        else
            love.graphics.setColor(0, 0, 200)
        end
        love.graphics.circle( "fill", ball:getBody():getX(), ball:getBody():getY(), ball:getShape():getRadius() )
    end
end

function drawGround()
    love.graphics.setColor( 220, 40, 60)
    drawRectangle("fill", ground);
end

function drawPlayers()
    for i,v in ipairs(players) do
        local body = v.fixture:getBody()
        local x, y = body:getPosition()
        local angle = x * 2 / BALL_W
        local dist= v.dist

        body:setAngle(angle)
        local o= 36 -- Warum 36??
        love.graphics.draw(v.image, x, y, angle, BALL_W / 36, BALL_W / 36, o, o)
    end

    if aimLine ~= nil then
        love.graphics.line(aimLine.x1, aimLine.y1, aimLine.x2, aimLine.y2)
    end
end

function drawPlayer_OLD()
    for i,v in ipairs(players) do
        local body = v.fixture:getBody()
        local x, y = body:getPosition()
        local angle = x * 2 / BALL_R
        local dist= v.dist



        local vx, vy = body:getLinearVelocity()
        local vv = vx * vx + vy * vy

        if vv < 20 and dist ~= nil and dist > 0 and i == player() then
            local sin= math.sin(v.angle + PI2)
            local cos= math.cos(v.angle + PI2)
            local x1, y1= x + sin * BALL_R, y - cos * BALL_R
            local x2, y2= x + sin * (BALL_R + dist), y - cos * (BALL_R + dist)
            love.graphics.line(x1, y1, x2, y2)

            angle= angle + v.angle + PI2 - PI16

            if love.mouse.isDown("l") then
                if not waitForMouseUp then
                    print("click", x2 - x1, y2 - y1)
                    -- v.fixture:setRestitution(0.1)
                    body:setLinearDamping(0.5)
                    local fact= 10
                    body:setLinearVelocity((x2 - x1) * fact, (y2 - y1) * fact)
                    waitForMouseUp = true
                end
            else
                waitForMouseUp = false
            end
        end

        body:setAngle(angle)
        local o= 36 -- Warum 36??
        love.graphics.draw(v.image, x, y, angle, BALL_R / 36, BALL_R / 36, o, o)
    end
end

function drawDebug()
--    love.graphics.setColor( 220, 200, 60)
--    for i,v in ipairs( boardBalls) do
--        love.graphics.circle( "fill", v.body:getX(), v.body:getY(), v.shape:getRadius() )
--    end
end

function love.draw()
    drawBall()
    drawBalls()
    drawTower()
    drawGround()
    drawPlayers()
    drawDebug()
end
