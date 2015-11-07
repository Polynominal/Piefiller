local path = ...
local profiler = {}
local function hsvToRgb(h, s, v)
	local h,s,v = h,1,1
    local h,s,v = math.fmod(h,360),s,v
    if s==0 then return { v,v,v } end
    h=h/60
    i=math.floor(h)
    f=h-i
    p=v*(1-s)
    q=v*(1-s*f)
    t=v*(1-s*(1-f))
    
    if i==0 then r=v g=t b=p
    elseif i==1 then r=q g=v b=p
    elseif i==2 then r=p g=v b=t
    elseif i==3 then r=p g=q b=v
    elseif i==4 then r=t g=p b=v
    else r=v g=p b=q
    end
    
    r=r*255
    g=g*255
    b=b*255
    return { r,g,b }
end
local function copy(t)
	local ret = {} 
	for i,v in pairs(t) do 
		ret[i] = v 
		if type(v) == "table" then 
			ret[i] = copy(v)
		end 
	end 
	return ret 
end 
function setColor(...)
	local args = {...} 
	love.graphics.setColor(args[1] or 255,args[2] or 255,args[3] or 255,args[4] or 255)
end 
local color_data = {}
local colors = {}  
function profiler:new()
    local self = {} 
    setmetatable(self,{__index = profiler})
    self.data = {}
    self.last = 0 
	self.timer = 0 
    self:reset()
	self.depth = 2 
	self.small = false 
    self.x = 0 
	self.y = 0
	self.scale = 1
	self.step = 1
	return self
end
function profiler:reset()
	self.data = {} 
	self.x = 0 
	self.y = 0
	self.scale = 1
	for i=0,300 do 
		table.insert(colors,hsvToRgb(i,100,100))
	end 
end 
function profiler:attach()
   self.last = os.clock()
   local function hook()
        local depth = self.depth 
        local caller = debug.getinfo(depth)
        local taken = os.clock() - self.last
		if caller then 
			local last_caller
			local own = string.find(caller.source,path)
			if caller.func ~= hook and not own then  
				while caller do 
					if last_caller and not self.view_children then
						local name = caller.func 
						local lc = self.data[last_caller.func]
						if not lc.kids[name] then 
							lc.kids[name] = {                        
								parent = last_caller,
								func = caller.func,
								count = 0,
								time = 0,
								child_time = 0, 
								named_child_time = 0, 
								children = {},
								children_time = {},
								info = caller,
								kids = {},
							} 
						end 
						local kid = lc.kids[name]
						kid.count = kid.count + 1 
						kid.time = kid.time + taken 
					else 
						local name = caller.func 
						local raw = self.data[name] 
						if not raw then
							self.data[name] = {
								func = caller.func,
								count = 0,
								time = 0,
								child_time = 0, 
								named_child_time = 0, 
								children = {},
								children_time = {},
								info = caller,
								kids = {},
							}
						end
						raw = self.data[name]
						raw.count = raw.count + 1 
						raw.time = raw.time + taken
						last_caller = caller
					end 
					depth = depth + 1 
					caller = debug.getinfo(depth)
				end 
			end
		end 
    end
	local step = 10^self.step
	if self.step < 0 then 
		step = 1/-self.step 
	end 
	debug.sethook(hook,"",step)
end 
function profiler:dettach(mode)
    local totaltime = 0
    local parsed = {}
    local no = 0 
    for i,v in pairs(self.data) do 
        no = no + 1
        totaltime = totaltime + v.time 
		local i = no 
        parsed[i] = {}
        parsed[i].name = v.info.name
        parsed[i].time = v.time 
		parsed[i].src = v.info.source
        parsed[i].def = v.info.linedefined
        parsed[i].cur = v.info.currentline
		parsed[i].item = v 
		if not color_data[v.func] then 
			local i = math.random(#colors)
			color_data[v.func] = colors[i]
			table.remove(colors,i)
		end 
		
		parsed[i].color = color_data[v.func]
	end 
    local prc = totaltime/100
    for i,v in ipairs(parsed) do 
        parsed[i].prc = v.time/prc
    end 
    self.parsed = parsed 
    self.totaltime = totaltime 
	if not mode then debug.sethook() end 
end 
local largeFont = love.graphics.newFont(25)
function profiler:draw(args)
    local loading 
	local oldFont = love.graphics.getFont()
	local w,h = love.graphics.getDimensions()
	love.graphics.push()
	love.graphics.translate(self.x,self.y)
	love.graphics.scale(self.scale)
	local args = args or {}
	local rad = args["rad"] or 200 
    local mode = args["mode"] or "simple"
    local ret = args["return"]
    local pi = math.pi  
    if ret then 
        local lastangle = 0 
        local pieChart = {} 
        for i,v in ipairs(self.parsed) do 
            local angle = 3.6*v.prc
            local segment = {
                name = v.name or v.linedefined,
                angle = angle,
                start = lastangle,
                finish = lastangle + angle,
            } 
            lastangle = lastangle + angle 
        end 
    end 
	if self.parsed and self.totaltime > 0  then
        local lastangle = 0
        local font = love.graphics.getFont()
		for i,v in ipairs(self.parsed) do 
            local color = v.color
			local cx,cy = w/2,h/2
			local angle = math.rad(3.6*v.prc)
				setColor(color)
				love.graphics.arc("fill",cx,cy,rad,lastangle,lastangle + angle)
				setColor(colors.black)
				if v.prc > 1 then 
					love.graphics.arc("line",cx,cy,rad,lastangle,lastangle + angle)
				end 
				lastangle = lastangle + angle 
				setColor()
        end 
		lastangle = 0 
		for i,v in ipairs(self.parsed) do 
			
				local color = v.color
				local cx,cy = w/2,h/2
				local angle = math.rad(3.6*v.prc)
				local x = cx + rad * math.cos(lastangle + angle/2)
				local y = cy + rad * math.sin(lastangle + angle/2)
				if self.small then 
					txt = tostring(v.src).." @: "..tostring(v.name)
				else 
					txt = tostring(math.ceil(v.prc)).." % "..tostring(v.name).." : "..tostring(v.src).." @: "..tostring(v.def)
				end 
				local fw = font:getWidth(txt)
				local sx = 1 
				if cx < x then 
					sx = -1 
					fw = 0 
				end 
				if cy + rad/2 < y then 
					y = y + font:getHeight()  
				elseif cy + rad/2 > y then 
					y = y - font:getHeight()
				end 
				local ofx 
				love.graphics.print(txt,((x) + (-(fw+20))*sx),y)
				lastangle = lastangle + angle 		
		end
	else 
		loading  = true 
    end 
	self.timer = self.timer + love.timer.getDelta() 
	if self.timer > 20 then 
		self.timer = 0 
	end 
	love.graphics.setFont(largeFont)
	local t = "Depth: "..self.depth.." with step: "..self.step
	local fw = largeFont:getWidth(t)
	local fh = largeFont:getHeight()
	love.graphics.print(t,w/2 - fw/2,(fh+5))
	if loading then 
		t = "Loading..."
		fw = largeFont:getWidth(t)
		love.graphics.print("Loading...",w/2 - fw/2,h/2)
	end 
	love.graphics.pop() 
	love.graphics.setFont(oldFont)
end 
function profiler:mousepressed(x,y,b)
	if b == "wu" then
		local scale = self.scale - math.floor((0.05*self.scale)*1000)/1000
		if scale > 0 and scale > 0.1 then
			local lastzoom = self.scale
			local mouse_x = x - self.x
			local mouse_y = y - self.y
			self.scale = scale
			local newx = mouse_x * (self.scale/lastzoom)
			local newy = mouse_y * (self.scale/lastzoom)
			self.x = self.x + (mouse_x-newx)
			self.y = self.y + (mouse_y-newy)
		else
			self.scale = 0.1
		end
	elseif b == "wd" then
		local scale = self.scale + math.floor((0.05*self.scale)*1000)/1000
		local scalex = self.scale
		if scale > 0 and scale < 20 then
			local lastzoom = self.scale
			local mouse_x = x - self.x
			local mouse_y = y - self.y
			self.scale = scale
			local newx = mouse_x * (self.scale/lastzoom)
			local newy = mouse_y * (self.scale/lastzoom)
			self.x = self.x + (mouse_x-newx)
			self.y = self.y + (mouse_y-newy)
		else
			self.scale = 20
		end
	end		
end
function profiler:keypressed(key)
	if key == "r" then 
		self:reset()
	elseif key == "up" then 
		self:reset()	
		self.depth = self.depth - 1 
	elseif key == "down" then 
		self:reset()	
		self.depth = self.depth + 1 
	elseif key == "," then 
		self.step = self.step - 1
	elseif key == "." then  
		self.step = self.step +1 
	elseif key == "s" then 
		self.small = not self.small 
	elseif key == "c" then 
		self:reset()
		self.view_children = not self.view_children
	elseif key == "p" then 
		local parsed = copy(self.parsed)
		table.sort(parsed,function(a,b)
			return a.prc > b.prc
		end)
		local d = {"Depth: "..self.depth.." with step: "..self.step.."\r\n".."Total time: "..self.totaltime.."\r\n"} 
		
		for i,v in ipairs(parsed) do 
			local instance = {
				"-----"..(v.name or "def@"..v.def).."-----",
				"source:"..v.src..":"..v.def,
				"current line: "..v.cur, 
				"time: "..v.time,
				"percentage: "..math.ceil(v.prc).." %",
				"----------------",
			}
			for i,v in ipairs(instance) do 
				instance[i] = v.."\r\n"
			end 
			table.insert(d,table.concat(instance))
		end 
		local data = table.concat(d)
		love.filesystem.write("Profile",data)
		love.system.openURL(love.filesystem.getRealDirectory("Profile"))
	end 
end 
return profiler
