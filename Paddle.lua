--model class for paddle
Paddle = Classic{}

function Paddle:init(x,y,width,height,speed,color)
	-- coordinate
	self.x = x
	self.y = y

	--dimension
	self.width = width 
	self.height = height

	--velocity
	self.deltaY = speed

	-- color of paddle
	self.color = color
end

function Paddle:moveUp(dt)
	self.y = math.max(0,self.y - self.deltaY * dt)
end

function Paddle:moveDown(dt)
	self.y = math.min(VIRTUAL_HEIGHT - self.height,self.y + self.deltaY * dt)
end

function Paddle:renderPaddle()
	--set color of paddle
	if self.color == 'blue' then
		love.graphics.setColor(0,0,255,255)
	elseif self.color == 'red' then
		love.graphics.setColor(255,0,0,255)
	end

	--love.graphics.rectangle(mode,x,y,width,height)
	love.graphics.rectangle(FILL_MODE,self.x,self.y,self.width,self.height)
end