Arcangle = {}

function Arcangle:new(w, h, xPos, yPos)
   o = {}
   setmetatable(o, {__index = Arcangle})
   o.w = w
   o.h = h
   o.xPos = xPos
   o.yPos = yPos
   return o
end

function Arcangle:draw()
		pacwidth = math.pi/6

    love.graphics.setColor(255, 255, 255)
    love.graphics.arc("fill", self.xPos, self.yPos,30,pacwidth,(math.pi * 2)-pacwidth )
end

function Arcangle:goUp()
    self.yPos = self.yPos - 5
end

function Arcangle:goDown()
    self.yPos = self.yPos + 5
end

function Arcangle:goRight()
    self.xPos = self.xPos + 5
end

function Arcangle:goLeft()
    self.xPos = self.xPos - 5
end
function Arcangle:supergo()
    self.xPos = self.xPos + 60
    self.yPos = self.yPos + 70

end
function Arcangle:superback()
	self.xPos = self.xPos - 60
    self.yPos = self.yPos - 70

end
function Arcangle:moving()
	 love.graphics.setColor(255, 0, 0)

	Mousex,Mousey = love.mouse.getPosition()
	love.graphics.arc("line", Mousex,Mousey,30,pacwidth,(math.pi * 2)-pacwidth )

end

-- ### globals
rect1 = Arcangle:new(30, 30, 150, 120)
rect2 = Arcangle:new(30, 30, 185, 120)
rect3 = Arcangle:new(10, 10, 300, 10)
rect4 = Arcangle:new(10,60,400,100)
-- ### /globals

-- ### callback functions

function love.load()
    love.window.setTitle("オブジェクト指向　テスト")
    love.window.setMode(600, 500, {})
end

function love.update(dt)
    rect3.yPos = (rect3.yPos + 1) % 300

    function love.keypressed(key, scancode)
    if scancode ~= nil then
        if scancode == "up" then
            rect1:goUp()
        elseif scancode == "down" then
            rect1:goDown()
        elseif scancode == "right" then
            rect1:goRight()
        elseif scancode == "left" then
            rect1:goLeft()
        elseif scancode == "space" then
        	rect2:supergo()
        	elseif scancode == "return" then
    		rect2:superback()
        end
    end
end


end
function love.draw()
	    love.graphics.setColor(255, 255, 255)

    love.graphics.print("Position: (" .. rect1.xPos .. "|" .. rect1.yPos .. ").", 20, 20)
    love.graphics.print("Position: (" .. rect2.xPos .. "|" .. rect2.yPos .. ").", 20, 40)

    rect1:draw()
    rect2:draw()
    rect3:draw()
    rect4:moving()


end

