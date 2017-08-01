Profiler  = require("piefiller")
ProfOn = true
drawRect = true 
local Prof = Profiler:new()
function iterateSmall()
	for i=1,1000 do 
	end 
end
function iterateLarge()
	for i=1,100000 do 
		
	end 
end
function drawRectangles()
	for i=1,100 do 
		love.graphics.setColor(255,0,0)
		love.graphics.rectangle("line",i,i,i,i)
		love.graphics.setColor(255,255,255)
	end 
end 
function love.load()
end
function love.draw()
	if drawRect then 
		drawRectangles()
		Prof:detach()
	end 
	if ProfOn then 
		Prof:draw({50})
	end	
end
function love.update(dt)
	Prof:attach()
	iterateSmall()
	iterateLarge()
	if drawRect then 
		Prof:detach(true)
	else 
		Prof:detach()
	end  
	local data = Prof:unpack()
end
function love.keypressed(key)
	if key == "escape" then 
		ProfOn = not ProfOn
	elseif key == ";" then 
		drawRect = not drawRect 
	end 
	Prof:keypressed(key)
end
function love.mousepressed(...)
	Prof:mousepressed(...)
end 
