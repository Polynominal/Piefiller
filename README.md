# Piefiller
Graphical profiler for Love2D 9.2
#Usage
1) require the file:
```lua
  piefiller = require("piefiller")
```
2) make a new instance of piefiller
```lua
  Pie = piefiller:new()
```
3) attach the piefiller to the part of your application that you want to monitor, it can be whatever but I suggest calling it in love.update or love.draw as this is what piefiller is all about.

```lua
 function love.update()
	Pie:attach()
		-- do something
	Pie:dettach()
 end
```
4) draw the output in your draw function and give event hooks for your pie.
```lua
 function love.draw()
	Pie:draw()
 end
 function love.keypressed(...)
 	Pie:keypressed(...)
 end
 function love.mousepressed(...)
 	Pie:mousepressed(...)
 end
```
5) When you get sufficient output press the "P" key to output to file.
#Keys
r 	= resets the pie 

up 	= decreases depth 

down 	= increases depth 

, 	= decreases step size 

.	= increases step size 

s	= shortens the names displayed

c	= hides/shows hidden processes

p	= saves to file called "Profile" and opens directory for you
# Additional notes
The best depth to search for is 2 and 3.

When used in large applications the output is difficult to read, however printing to file resolves this issue.
# Planned features
Make sure that text does not overlay.
