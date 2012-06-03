
TOWER_X = 400
TOWER_Y = 200
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

PLAYER_RADIUS= BALL_W

ball= {}
tower= {}
players = {}
player= 1

screenWidth= 0
screenHeight= 0

function fixWorldXY( f)
    body = f:getBody()
    local x1, y1, x2, y2 = f:getBoundingBox()
    local w = x2 - x1
    local h = y2 - y1
    local bX, bY = body:getPosition()
    print( f)
    print( "Body getY: ", body:getY())
    print( "Body getPosition: ", body:getPosition())
    body:setPosition( bX + w / 2, bY + h / 2)
    print( "Body getY: ", body:getY())
    print( "Body getPosition: ", body:getPosition())
end

function newFixture( body, shape)
    local f = love.physics.newFixture( body, shape)
    fixWorldXY( f)
    return f
end

function initBall()
    ball.body = love.physics.newBody( world, 505, 100, "dynamic")
    ball.body:setMass( 50)
    ball.shape = love.physics.newCircleShape( BALL_W)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape)
    ball.fixture:setRestitution( 0.4)
end

function initTower()
    tower.base = {}
    local body = love.physics.newBody( world, TOWER_X, TOWER_Y + COL_H)
    local shape = love.physics.newRectangleShape(  TOWER_W, BASE_H)
    tower.base.fixture = newFixture( body, shape)
    tower.cols = {}
    for i = 0,7 do
      col = {}
      local body = love.physics.newBody( world, TOWER_X +i * ( COL_W + SLOT_W), TOWER_Y)
      local shape = love.physics.newPolygonShape( 0, TOWERSPIKE_H,
                                                  0, COL_H,
                                                  COL_W, COL_H,
                                                  COL_W, TOWERSPIKE_H,
                                                  COL_W / 2, 0)
      col.fixture = newFixture( body, shape)
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
    love.graphics.setBackgroundColor( 200,150,100)

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

    local dist = (math.sqrt((x - bx) * (x - bx) + (y - by) * (y - by)) - PLAYER_RADIUS) / 2
    if dist < 0 then dist= 0 end
    if dist > 100 then dist= 100 end
    players[player].dist= dist

    local angle = math.atan2(y - by, x - bx)
    if angle > -PI16 then angle= -PI16 end
    if angle < -PI2 + PI16 then angle= -PI2 + PI16 end
    players[player].angle= angle
end

function love.update( dt)
    world:update( dt)
    updatePlayer(dt)
end

function drawPolygon( mode, fixture)
    local shape = fixture:getShape()
    local body = fixture:getBody()
    print( "drawPolygon start")
    print( "shape:getPoints: ", shape:getPoints())
    print( "body:getPositions: ", body:getPosition())
    print( "body:getWorldPoints(shape:getPoints() ): ", body:getWorldPoints(shape:getPoints() ))
    print( "drawPolygon stop")

    love.graphics.polygon( mode, body:getWorldPoints(shape:getPoints() ) )
    -- for i = 1, 0 do end
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
    drawRectangle( "fill", tower.base.fixture)
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
        local angle = x * 2 / PLAYER_RADIUS
        local dist= v.dist
        local vx, vy = body:getLinearVelocity()
        local vv = vx * vx + vy * vy

        if vv < 20 and dist ~= nil and dist > 0 then
            local sin= math.sin(v.angle + PI2)
            local cos= math.cos(v.angle + PI2)
            local x1, y1= x + sin * PLAYER_RADIUS, y - cos * PLAYER_RADIUS
            local x2, y2= x + sin * (PLAYER_RADIUS + dist), y - cos * (PLAYER_RADIUS + dist)
            love.graphics.line(x1, y1, x2, y2)

            angle= angle + v.angle + PI2 - PI16

            if love.mouse.isDown("l") then
                print("click", x2 - x1, y2 - y1)
                -- v.fixture:setRestitution(0.1)
                body:setLinearDamping(0.5)
                local fact= 10
                body:setLinearVelocity((x2 - x1) * fact, (y2 - y1) * fact)
            end
        end

        body:setAngle(angle)
        love.graphics.draw(v.image, x, y, angle, BALL_W / 36, BALL_W / 36) -- , BALL_W, BALL_W)
    end
end

function love.draw()
    drawBall()
    drawTower()
    drawGround()
    drawPlayer()
end
