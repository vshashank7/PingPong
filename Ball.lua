-- model class for ball
Ball = Classic{}

function Ball:init(x,y,width,height)
	--coordinate points
	self.x = x
	self.y = y 

	--dimension
	self.width = width
	self.height = height 

	--velocity
	self.deltaX = 100
	if math.random(1,2) == 2 then
		self.deltaX = -100
	end

	self.deltaY = math.random(-50,50)
end

function Ball:resetPosition()
	--reset coordinate to center
	self.x = VIRTUAL_WIDTH / 2 -2
	self.y = VIRTUAL_HEIGHT / 2 -2

	--reset velocity
	self.deltaX = 100
	if math.random(1,2) == 2 then
		self.deltaX = -100
	end

	self.deltaY = math.random(-50,50)
end

function Ball:moveBall(dt)
	self.x = self.x + self.deltaX * dt
	self.y = self.y + self.deltaY * dt
end

function Ball:renderBall()
	--set color of ball (green)
	love.graphics.setColor(0,255,0,255)

	--love.graphics.rectangle(mode,x,y,width,height)
	love.graphics.rectangle(FILL_MODE, self.x, self.y, self.width,self.height)
end

