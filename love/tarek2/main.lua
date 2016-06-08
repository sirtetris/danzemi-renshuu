Rectangle = { }

function Rectangle:new (o, w, h, xPos, yPos)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self.w = w
   self.h = h
   self.xPos = xPos
   self.yPos = yPos
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
rect = Rectangle:new(nil, 20, 20, 100, 100)
-- ### /globals

-- ### callback functions

function love.load()
    love.window.setTitle("オブジェクト指向　テスト")
    love.window.setMode(400, 300, {})
end

function love.draw()
    love.graphics.print("Position: (" .. rect.xPos .. "|" .. rect.yPos .. ").", 20, 20)
    rect:draw()
end

function love.keypressed(key, scancode)
    if scancode ~= nil then
        if scancode == "up" then
            rect:goUp()
        elseif scancode == "down" then
            rect:goDown()
        elseif scancode == "right" then
            rect:goRight()
        elseif scancode == "left" then
            rect:goLeft()
        end
    end
end

-- ###/ callback functions
