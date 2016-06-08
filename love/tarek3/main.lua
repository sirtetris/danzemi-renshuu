Rectangle = {}

function Rectangle:new(w, h, xPos, yPos)
   o = {}
   setmetatable(o, {__index = Rectangle})
   o.w = w
   o.h = h
   o.xPos = xPos
   o.yPos = yPos
   return o
end

function Rectangle:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.w, self.h)
end

function Rectangle:goUp()
    self.yPos = self.yPos - 10
end

function Rectangle:goDown()
    self.yPos = self.yPos + 10
end

function Rectangle:goRight()
    self.xPos = self.xPos + 10
end

function Rectangle:goLeft()
    self.xPos = self.xPos - 10
end

-- ### globals
rect1 = Rectangle:new(30, 30, 150, 120)
rect2 = Rectangle:new(30, 30, 185, 120)
rect3 = Rectangle:new(10, 10, 300, 10)
-- ### /globals

-- ### callback functions

function love.load()
    love.window.setTitle("オブジェクト指向　テスト")
    love.window.setMode(400, 300, {})
end

function love.update(dt)
    rect3.yPos = (rect3.yPos + 1) % 300
end

function love.draw()
    love.graphics.print("Position: (" .. rect1.xPos .. "|" .. rect1.yPos .. ").", 20, 20)
    love.graphics.print("Position: (" .. rect2.xPos .. "|" .. rect2.yPos .. ").", 20, 40)
    rect1:draw()
    rect2:draw()
    rect3:draw()
end

function love.keypressed(key, scancode)
    if scancode ~= nil then
        if scancode == "up" then
            rect1:goUp()
            rect2:goDown()
        elseif scancode == "down" then
            rect1:goDown()
            rect2:goUp()
        elseif scancode == "right" then
            rect1:goRight()
            rect2:goLeft()
        elseif scancode == "left" then
            rect1:goLeft()
            rect2:goRight()
        end
    end
end

-- ###/ callback functions
