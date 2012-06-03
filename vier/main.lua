
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
balls= {}
board = {}
border = {}

waitForMouseUp = true

screenWidth= 0
screenHeight= 0

towerX= 0

function player()
    return (#balls % 2) + 1
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
    towerX = ( screenWidth - TOWER_W) / 2
    local body = love.physics.newBody( world, towerX, screenHeight - GROUND_Y - BASE_H)
    local shape = love.physics.newPolygonShape(  0, 0,  TOWER_W, 0,  TOWER_W, BASE_H,  0, BASE_H)
    tower.base.fixture = love.physics.newFixture( body, shape)
    tower.cols = {}
    for i = 0,7 do
        local col = {}
        local body = love.physics.newBody( world, ( screenWidth - TOWER_W) / 2 +i * ( COL_W + SLOT_W), screenHeight - GROUND_Y - BASE_H - COL_H)
        local shape = love.physics.newPolygonShape( 0, TOWERSPIKE_H,  0, COL_H,  COL_W, COL_H,  COL_W, TOWERSPIKE_H,  COL_W / 2, 0)
        col.fixture = love.physics.newFixture( body, shape)
        table.insert( tower.cols, col)
    end
end

function initBorders()
    local body
    local shapeH = love.physics.newRectangleShape(0, 0, screenWidth, 10)
    local shapeV = love.physics.newRectangleShape(0, 0, 10, screenHeight + 50)
    body = love.physics.newBody(world, screenWidth / 2, screenHeight - 5, "static")
    border.ground = love.physics.newFixture(body, shapeH)
    body = love.physics.newBody(world, screenWidth / 2, -50, "static")
    border.top    = love.physics.newFixture(body, shapeH)
    body = love.physics.newBody(world, -5, screenHeight / 2 - 25, "static")
    border.left   = love.physics.newFixture(body, shapeV)
    body = love.physics.newBody(world, screenWidth + 5, screenHeight / 2 - 25, "static")
    border.right  = love.physics.newFixture(body, shapeV)
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
        body:setLinearDamping(0.5)
        local t = {}
        t.image = images.green
        t.fixture = love.physics.newFixture(body, shape)
        t.fixture:setRestitution(0.4)
        t.initX= x
        table.insert(players, t)
    end

    addPlayer(100)
    addPlayer(screenWidth - 100)
end

function initBalls()
end

function initBalls_OLD()
    local shape = love.physics.newCircleShape(BALL_R)
    local i
    for i = 1, 42 do
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

ballShape= nil

function addNewBall(x, y, vx, vy)
    if ballShape == nil then
        ballShape = love.physics.newCircleShape(BALL_R)
    end
    local body = love.physics.newBody(world, x, y, "dynamic")
    -- body:setActive(false)
    body:setLinearDamping(0.5)
    local fact= 10
    body:setLinearVelocity(vx * fact, vy * fact)
    local fixture = love.physics.newFixture(body, ballShape)
    fixture:setRestitution(0.4)
    table.insert(balls, fixture)
end

function initBoard()
    local solutionMatrix = { 7, 7, 7, 15, 10, 10, 10,
                             7, 7, 7, 15, 10, 10, 10,
                             7, 7, 7, 15, 10, 10, 10,
                             1, 1, 1,  1,  0,  0,  0,
                             1, 1, 1,  1,  0,  0,  0,
                             1, 1, 1,  1,  0,  0,  0 }
    board = {}
    board.positions = {}
    board.value = ""
    local boardBase = tower.base.fixture:getBody():getY()
    local x,y
    boardBalls = {}
    for y = 5, 0, -1 do
        for x = 0,6 do
            local p = {}
            p.y = boardBase - BALL_R * 2 * ( y + 0.5)
            p.x = towerX + COL_W + (COL_W + SLOT_W) * x + SLOT_W * 0.5
            p.player = 0
            p.matrix = solutionMatrix[ (5 - y) * 7 + x + 1]
            table.insert( board.positions, p)
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
    initBorders()
    initPlayers()
    initBalls()
    initBoard()
end

function updateBalls(dt)
    for i, ball in ipairs(balls) do
        local body= ball:getBody()
        local vx, vy = body:getLinearVelocity()
        local vv = vx * vx + vy * vy
        local x= body:getX()
        local y= body:getY()
        if vv < 20 and (x < towerX or x > towerX + TOWER_W) then
            body:setActive(false)
        end
    end
end

aimLine= nil

function updateCurrentPlayer(dt)
    local x, y = love.mouse.getPosition()

    local pl= players[player()]
    local body= pl.fixture:getBody()
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

    pl.dist= dist
    pl.angle= angle

    aimLine= nil

    if dist > 0 then
        local sin= math.sin(angle + PI2)
        local cos= math.cos(angle + PI2)
        local x1, y1= bx + sin * BALL_R, by - cos * BALL_R
        local x2, y2= bx + sin * (BALL_R + dist), by - cos * (BALL_R + dist)

        aimLine= { x1= x1, y1= y1, x2= x2, y2= y2 }

        if love.mouse.isDown("l") then
            if not waitForMouseUp then
                addNewBall(x1, y1, x2 - x1, y2 - y1)

                print("click", x2 - x1, y2 - y1)

                waitForMouseUp = true
            end
        else
            waitForMouseUp = false
        end
    end

end

function updatePlayers(dt)
    updateCurrentPlayer(dt)

    for i, pl in ipairs(players) do
        local body= pl.fixture:getBody()
        local vx= math.abs(body:getLinearVelocity())
        if vx < 30 then
            local dx= body:getX() - pl.initX
            if dx < -50 then
                body:setLinearVelocity(30, 0)
            elseif dx < -10 then
                body:setLinearVelocity(10, 0)
            elseif dx > 50 then
                body:setLinearVelocity(-30, 0)
            elseif dx > 10 then
                body:setLinearVelocity(-10, 0)
            end
         end
    end
end

function updateBoard(dt)
    local changed = false
    
    function checkRow( p, offset)
        print( "checkRow, p, offset: ", p, offset)
        local playerSum = 0
        local player = board.positions[ p].player
        for i = offset,offset*4,offset do
            local playerSum = playerSum + board.positions[p + offset].player
            if( playerSum == player * 4) then return player end
        end
        return 0
    end

    for j,p in ipairs( board.positions) do
        x = p.x
        y = p.y
        if( p.player == 0) then
            for i=1,#balls do
                local ball= balls[i]
                vx, vy = ball:getBody():getLinearVelocity()
                if vx == 0 and vy == 0 then
                    bx = ball:getBody():getX()
                    by = ball:getBody():getY()
                    if math.abs( x - bx) < 3 and math.abs( y - by) < 3 then
                        p.player =  (i % 2) + 1
                        changed = true
                        break
                    end
                end
            end
        end
    end
    if changed then
        str = ""
        for j,p in ipairs( board.positions) do
            if( p.player ~= 0) then
                str = str .. tostring( p.player) .. " "
            else
                str = str .. "_ "
            end
            if( j % 7 == 0) then
                print( str)
                str = ""
            end
        end

        for j,p in ipairs( board.positions) do
            if( p.player > 0) then
                local matrix = p.matrix
                print( "matrix: ", matrix)
                if( matrix > 7) then
                    matrix = matrix - 8
                    winner = checkRow( j, 6)
                end                
                if( matrix > 3) then
                    matrix = matrix - 4
                    winner = checkRow( j, 8)
                end                
                if( matrix > 1) then
                    matrix = matrix - 2
                    winner = checkRow( j, 7)
                end                
                if( matrix > 0) then
                    winner = checkRow( j, 1)
                end                
            end             
        end
        if( winner > 0) then gameWon( winner) end
    end
end

function love.update( dt)
    world:update( dt)
    updateBalls(dt)
    updatePlayers(dt)
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
    for i=1,#balls do
        local ball= balls[i]
        if ball:getBody():isActive() then
            if i % 2 == 0 then
                love.graphics.setColor(200, 0, 0)
            else
                love.graphics.setColor(0, 0, 200)
            end
            love.graphics.circle( "fill", ball:getBody():getX(), ball:getBody():getY(), ball:getShape():getRadius() )
        end
    end
end

function drawBorder()
    love.graphics.setColor( 220, 40, 60)
    drawRectangle("fill", border.ground);
end

function drawPlayers()
    for i,v in ipairs(players) do
        local body = v.fixture:getBody()
        local x, y = body:getPosition()
        local angle = x * 2 / BALL_R
        local dist= v.dist

        body:setAngle(angle)
        local o= 36 -- Warum 36??
        love.graphics.draw(v.image, x, y, angle, BALL_R / 36, BALL_R / 36, o, o)
    end

    if aimLine ~= nil then
        love.graphics.line(aimLine.x1, aimLine.y1, aimLine.x2, aimLine.y2)
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
    drawBorder()
    drawPlayers()
    drawDebug()
end
