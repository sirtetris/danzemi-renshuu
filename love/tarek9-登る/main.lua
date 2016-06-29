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
        lFlag = false
        if self:getLower() < other:getUpper() then -- currently above
            hitAtY = other:getUpper() - self.h - 0.5
            lFlag = true
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
        return {x=hitAtX, y=hitAtY, landedFlag=lFlag}
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
    o.maxSpeed = 5
    o.jumpLock = 0
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
                self.ySpeed = 0
                self.yPos = hitY.y
                if hitY.landedFlag then
                    self.jumpLock = 0
                end
            elseif hitXY ~= false then
                collidesX = true
                collidesY = true
                self.xSpeed = 0
                self.ySpeed = 0
                self.xPos = hitXY.x
                self.yPos = hitXY.y
                if hitXY.landedFlag then
                    self.jumpLock = 0
                end
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

function Rectangle:gravity()
    self.ySpeed = self.ySpeed + 1.5
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

function Rectangle:jump()
    if self.jumpLock > 0 then
        return
    end
    self.ySpeed = self.ySpeed - 20
    self.jumpLock = 1
end

function Rectangle:tick(dt)
    self.hitBox.x = self.xPos
    self.hitBox.y = self.yPos
    self:move()
    self:friction()
    self:gravity()
end

-- ### globals
entities = {}
rect = Rectangle:new(30, 30, 30, 180)
table.insert(entities, rect)
floor = Rectangle:new(800, 5, 0, 590)
plattform1 = Rectangle:new(80, 5, 80, 520)
plattform2 = Rectangle:new(160, 5, 200, 450)
plattform3 = Rectangle:new(5, 50, 400, 390)
plattform4 = Rectangle:new(120, 5, 200, 340)
plattform5 = Rectangle:new(80, 5, 240, 290)
plattform6 = Rectangle:new(280, 5, 460, 290)
table.insert(entities, floor)
table.insert(entities, plattform1)
table.insert(entities, plattform2)
table.insert(entities, plattform3)
table.insert(entities, plattform4)
table.insert(entities, plattform5)
table.insert(entities, plattform6)
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
    if love.keyboard.isDown("space") then
        rect:jump()
    end
    if love.keyboard.isDown("right") then
        rect:accRight()
    end
    if love.keyboard.isDown("left") then
        rect:accLeft()
    end

    rect:tick(dt)
end
