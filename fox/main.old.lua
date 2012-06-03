TOWER_X = 400
TOWER_Y = 200 
BASE_H = 20
COL_H = 180
COL_W = 10
SLOT_W = 30
TOWER_W = COL_W * 8 + SLOT_W * 7
TOWERSPIKE_H = 2

function setWorldXY( f)
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
   setWorldXY( f)
   return f
end

function love.load()
   love.physics.setMeter(64)
   world = love.physics.newWorld(0, 9.81 * love.physics.getMeter(), true)

   ball = {}
   ball.body = love.physics.newBody( world, 505, 100, "dynamic")
   ball.body:setMass( 50)
   ball.shape = love.physics.newCircleShape( 14)
   ball.fixture = love.physics.newFixture(ball.body, ball.shape)
   ball.fixture:setRestitution( 0.4)
   
   tower = {}
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
   
   love.graphics.setBackgroundColor( 200,150,100)
end

function love.update( dt)
   world:update( dt)
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

function drawRectangle( mode, fixture)
   local b = fixture:getBody()
   local x1, y1, x2, y2 = fixture:getBoundingBox()
   local w = x2 - x1
   local h = y2 - y1
   love.graphics.rectangle( mode, b:getX() - w / 2, b:getY() - h / 2, w, h)
end

function love.draw()
   love.graphics.setColor( 220, 40, 60)
   love.graphics.circle( "fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius() )
   drawRectangle( "fill", tower.base.fixture)
   for i, col in ipairs( tower.cols) do
      drawPolygon( "fill", col.fixture)         
   end
end








