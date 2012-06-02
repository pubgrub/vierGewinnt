function love.load()
   love.physics.setMeter(64)
   world = love.physics.newWorld(0, 9.81 * love.physics.getMeter(), true)

   objects = {}
   objects.ground = {}
   objects.ground.body = love.physics.newBody( world, 600 / 2, 600 - 50 / 2)
   objects.ground.shape = love.physics.newRectangleShape( 600, 50)
   objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)
   
   objects.ball = {}
   objects.ball.body = love.physics.newBody( world, 200, 100, "dynamic")
   objects.ball.body:setMass( 50)
   objects.ball.shape = love.physics.newCircleShape( 50)
   objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape)
   objects.ball.fixture:setRestitution( 0.9)
   
   love.graphics.setBackgroundColor( 200,150,100)
   love.graphics.setMode( 600, 600, false, true, 0)

end

function love.update( dt)
   world:update( dt)
end

function love.draw()
   love.graphics.setColor( 220, 40, 60)
   love.graphics.circle( "fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius() )
end
