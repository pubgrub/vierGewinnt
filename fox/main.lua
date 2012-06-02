function love.load()
   love.physics.setMeter(64)
   world = love.physics.newWorld(0, 9.81 * love.physics.getMeter(), true)
   
   const = {}
   const.towerX = 400
   const.towerY = 400 
   const.baseH = 20
   const.colH = 180
   const.colW = 10
   const.slotW = 30
   const.towerW = const.colW * 8 + const.slotW * 7

   objects = {}
   objects.ground = {}
   objects.ground.body = love.physics.newBody( world, 800 / 2, 600 - 50 / 2)
   objects.ground.shape = love.physics.newRectangleShape( 800, 50)
   objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)
   
   objects.ball = {}
   objects.ball.body = love.physics.newBody( world, 500, 100, "dynamic")
   objects.ball.body:setMass( 50)
   objects.ball.shape = love.physics.newCircleShape( 14)
   objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape)
   objects.ball.fixture:setRestitution( 0.9)
   
   objects.tower = {}
   objects.tower.base = {}
   objects.tower.base.body = love.physics.newBody( world, const.towerX, const.towerY + const.colH)
   objects.tower.base.shape = love.physics.newRectangleShape(  const.towerW, const.baseH)
   objects.tower.base.fixture = love.physics.newFixture( objects.tower.base.body, objects.tower.base.shape)
   
   objects.tower.cols = {}
   for i = 0,7 do
      col = {}
      col.body = love.physics.newBody( world, const.towerX +i * ( const.colW + const.slotW), const.towerY)
      col.shape = love.physics.newRectangleShape( const.colW, const.colH)
      col.fixture = love.physics.newFixture( col.body, col.shape)
      table.insert( objects.tower.cols, col)
   end

   
   love.graphics.setBackgroundColor( 200,150,100)
   love.graphics.setMode( 800, 600, false, true, 0)

   

end

function love.update( dt)
   world:update( dt)
end

function love.draw()
   love.graphics.setColor( 220, 40, 60)
   love.graphics.circle( "fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius() )
   drawRectangle( "fill", objects.tower.base)
   for i, col in ipairs( objects.tower.cols) do
      drawRectangle( "fill", col)         
   end
   
end



function drawRectangle( mode, o)
   local x1, y1, x2, y2 = o.fixture:getBoundingBox()
   local w = x2 - x1
   local h = y2 - y1
   love.graphics.rectangle( mode,  o.body:getX() - w / 2, o.body:getY() - h / 2, w, h)
end
