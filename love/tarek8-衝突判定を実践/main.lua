HitBox = {}

function HitBox:new(x, y, w, h)
    local o = {}
    setmetatable(o, {__index = HitBox})
    o.x = x     -- x座標
    o.y = y     -- y座標
    o.w = w     -- 幅
    o.h = h     -- 高さ
    return o
end

function HitBox:getUpper()
    return self.y
end

function HitBox:getLower()
    return self.y + self.h
end

function HitBox:getLeftmost()
    return self.x
end

function HitBox:getRightmost()
    return self.x + self.w
end

function HitBox:collidesWith(other)
    if (((self:getLower() >= other:getUpper()) and
         (self:getUpper() <= other:getLower())) and
        ((self:getRightmost() >= other:getLeftmost()) and
         (self:getLeftmost() <= other:getRightmost()))) then
        return true
    else
        return false
    end
end

function HitBox:collidesWithDelta(other, dx, dy)
    if (((self:getLower() + dy >= other:getUpper()) and
         (self:getUpper() + dy <= other:getLower())) and
        ((self:getRightmost() + dx >= other:getLeftmost()) and
         (self:getLeftmost() + dx <= other:getRightmost()))) then
        hitAtX = 0
        hitAtY = 0
        if self:getLower() < other:getUpper() then -- currently above
            hitAtY = other:getUpper() - self.h - 0.5
        end
        if self:getUpper() > other:getLower() then -- currently below
            hitAtY = other:getLower() + 0.5
        end
        if self:getRightmost() < other:getLeftmost() then -- currently left of
            hitAtX = other:getLeftmost() - self.w - 0.5
        end
        if self:getLeftmost() > other:getRightmost() then -- currently right of
            hitAtX = other:getRightmost() + 0.5
        end
        return {x=hitAtX, y=hitAtY}
    else
        return false
    end
end

function HitBox:draw()
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

Rectangle = {}

function Rectangle:new(w, h, xPos, yPos)
    local o = {}
    setmetatable(o, {__index = Rectangle})
    o.w = w
    o.h = h
    o.xPos = xPos
    o.yPos = yPos
    o.xSpeed = 0
    o.ySpeed = 0
    o.maxSpeed = 10
    o.hitBox = HitBox:new(xPos, yPos, w, h)
    return o
end

function Rectangle:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.w, self.h)
    self.hitBox:draw()
end

function Rectangle:move()
    collidesX = false
    collidesY = false
    for i, e in ipairs(entities) do
        if e ~= self then
            sh = self.hitBox
            oh = e.hitBox
            hitX = sh:collidesWithDelta(oh, self.xSpeed, 0)
            hitY = sh:collidesWithDelta(oh, 0, self.ySpeed)
            hitXY = sh:collidesWithDelta(oh, self.xSpeed, self.ySpeed)
            if hitX ~= false then
                collidesX = true
                self.xSpeed = 0
                self.xPos = hitX.x
            elseif hitY ~= false then
                collidesY = true
                self.yPos = hitY.y
            elseif hitXY ~= false then
                collidesX = true
                collidesY = true
                self.xPos = hitXY.x
                self.yPos = hitXY.y
            end
        end
    end
    if not collidesX then
        self.xPos = self.xPos + self.xSpeed
    end
    if not collidesY then
        self.yPos = self.yPos + self.ySpeed
    end
end

function Rectangle:friction()
    xFac = 1
    yFac = 1
    if self.xSpeed < 0 then
        xFac = -1
    elseif self.xSpeed == 0 then
        xFac = 0
    end
    if self.ySpeed < 0 then
        yFac = -1
    elseif self.ySpeed == 0 then
        yFac = 0
    end
    self.xSpeed = self.xSpeed - (0.5 * xFac)
    self.ySpeed = self.ySpeed - (0.5 * yFac)
end

function Rectangle:accUp()
    if math.abs(self.ySpeed) <= self.maxSpeed then
        self.ySpeed = self.ySpeed - 2
    end
end

function Rectangle:accDown()
    if math.abs(self.ySpeed) <= self.maxSpeed then
        self.ySpeed = self.ySpeed + 2
    end
end

function Rectangle:accRight()
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed + 2
    end
end

function Rectangle:accLeft()
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed - 2
    end
end

function Rectangle:tick()
    self.hitBox.x = self.xPos
    self.hitBox.y = self.yPos
    self:move()
    self:friction()
end

-- ### globals
entities = {}
rect = Rectangle:new(70, 70, 180, 180)
table.insert(entities, rect)
b1 = Rectangle:new(400, 5, 80, 80)
b2 = Rectangle:new(5, 400, 80, 85)
b3 = Rectangle:new(400, 5, 80, 485)
b4 = Rectangle:new(5, 400, 475, 85)
table.insert(entities, b1)
table.insert(entities, b2)
table.insert(entities, b3)
table.insert(entities, b4)
-- ### /globals

-- ### callback functions

function love.load()
    love.window.setTitle("オブジェクト指向　テスト")
    love.window.setMode(800, 600, {})
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Position: (" .. rect.xPos .. "|" .. rect.yPos .. ").", 20, 20)
    for i, e in ipairs(entities) do
        e:draw()
    end
end

function love.update(dt)
    if love.keyboard.isDown("up") then
        rect:accUp()
    end
    if love.keyboard.isDown( "down") then
        rect:accDown()
    end
    if love.keyboard.isDown("right") then
        rect:accRight()
    end
    if love.keyboard.isDown("left") then
        rect:accLeft()
    end

    rect:tick()
end
