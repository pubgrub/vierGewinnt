
TOWER_X = 400
TOWER_Y = 200
BASE_H = 20
COL_H = 180
COL_W = 10
SLOT_W = 30
TOWER_W = COL_W * 8 + SLOT_W * 7
TOWERSPIKE_H = 2

PI= math.pi
PI2= math.pi / 2
PI4= math.pi / 4
PI8= math.pi / 8
PI16= math.pi / 16

PLAYER_RADIUS= 40

ball= {}
tower= {}
players = {}
player= 1

screenWidth= 0
screenHeight= 0

function fixWorldXY( f)
   b = f:getBody()
   local x1, y1, x2, y2 = f:getBoundingBox()
   local w = x2 - x1
   local h = y2 - y1
   local bX, bY = b:getPosition()
   print( f)
   print( "Body getY: ", b:getY())
   print( "Body getPosition: ", b:getPosition())
   b:setPosition( bX + w / 2, bY + h / 2)
   print( "Body getY: ", b:getY())
   print( "Body getPosition: ", b:getPosition())

end

function newFixture( b, s)
   local f = love.physics.newFixture( b, s)
   fixWorldXY( f)
   return f
end

function initBall()
   ball.body = love.physics.newBody( world, 505, 100, "dynamic")
   ball.body:setMass( 50)
   ball.shape = love.physics.newCircleShape( 14)
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
    -- Create ground body.
    local b = love.physics.newBody(world, screenWidth / 2, screenHeight - 5, "static")
    local s = love.physics.newRectangleShape(0, 0, screenWidth, 10)
    ground = love.physics.newFixture(b, s)
end

function initPlayers()

    -- Load images.
    -- FIXME: Nur green wird benutzt
    local images = {
        green = love.graphics.newImage("green_ball.png"),
        big_love = love.graphics.newImage("big_love_ball.png"),
        love = love.graphics.newImage("love_ball.png"),
    }

    -- Image / radius pairs.
    -- FIXME: UNUSED
    local balldefs = {
        { i = images.green,     r = 32 , ox = 36, oy = 36},
        { i = images.big_love,  r = 46 , ox = 48, oy = 48},
        { i = images.love,      r = 28 , ox = 32, oy = 32},
    }

    local s = love.physics.newCircleShape(32)
    local x = 100
    local y = 300
    local b = love.physics.newBody(world, x, y, "dynamic")
    local t = {}
    t.i = images.green
    t.f = love.physics.newFixture(b, s)
    t.f:setRestitution(0.4);
    table.insert(players, t)
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
    local b= players[player].f:getBody()
    -- print(x, y, b:getX(), b:getY())
    local bx= b:getX()
    local by= b:getY()

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
    local s = fixture:getShape()
    local b = fixture:getBody()
    print( "drawPolygon start")
    print( "s:getPoints: ", s:getPoints())
    print( "b:getWorldPoints(s:getPoints() ): ", b:getWorldPoints(s:getPoints() ))
    print( "drawPolygon stop")

    love.graphics.polygon( mode, b:getWorldPoints(s:getPoints() ) )
end

function drawRectangle(mode, fixture)
    local x1, y1, x2, y2 = fixture:getBoundingBox()
    local w = x2 - x1
    local h = y2 - y1
    local b = fixture:getBody()
    love.graphics.rectangle(mode, b:getX() - w / 2, b:getY() - h / 2, w, h)
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

function drawPlayer()
    for i,v in ipairs(players) do
        local b = v.f:getBody()
        local x, y = b:getPosition()
        local angle = x * 2 / PLAYER_RADIUS
        local dist= v.dist
        local vx, vy = b:getLinearVelocity()
        local vv = vx * vx + vy * vy

        if vv < 20 and dist > 0 then
            local sin= math.sin(v.angle + PI2)
            local cos= math.cos(v.angle + PI2)
            local x1, y1= x + sin * PLAYER_RADIUS, y - cos * PLAYER_RADIUS
            local x2, y2= x + sin * (PLAYER_RADIUS + dist), y - cos * (PLAYER_RADIUS + dist)
            love.graphics.line(x1, y1, x2, y2)

            angle= angle + v.angle + PI2 - PI16

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
end

function drawGround()
    love.graphics.setColor( 220, 40, 60)
    drawRectangle("fill", ground);
end

function love.draw()
    drawBall()
    drawTower()
    drawGround()
    drawPlayer()
end








