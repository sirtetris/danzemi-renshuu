MovingObject = {}

function MovingObject:new(xPos, yPos, maxSpeed)
    local o = {}
    setmetatable(o, {__index = MovingObject})
    o.xPos = xPos
    o.yPos = yPos
    o.xSpeed = 0
    o.ySpeed = 0
    o.maxSpeed = maxSpeed
    return o
end

function MovingObject:move()
    self.xPos = self.xPos + self.xSpeed
    self.yPos = self.yPos + self.ySpeed
end

function MovingObject:friction()
    fac = 1
    if self.xSpeed < 0 then
        fac = -1
    elseif self.xSpeed == 0 then
        fac = 0
    end
    self.xSpeed = self.xSpeed - (0.5 * fac)
end

function MovingObject:gravity()
    self.ySpeed = self.ySpeed + 1.5
end

function MovingObject:collide()
    if self.xPos > 780 then
        self.xSpeed = 0
        self.xPos = 780
    end
    if self.xPos < 0 then
        self.xSpeed = 0
        self.xPos = 0
    end
    if self.yPos > 580 then
        self.ySpeed = 0
        self.yPos = 580
    end
    if self.yPos < 0 then
        self.ySpeed = 0
        self.yPos = 0
    end
end

function MovingObject:accRight()
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed + 2
    end
end

function MovingObject:accLeft()
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed - 2
    end
end

Box = {}
setmetatable(Box, {__index = MovingObject})

function Box:new(w, h, xPos, yPos, maxSpeed)
    local o = MovingObject:new(xPos, yPos, maxSpeed)
    setmetatable(o, {__index = Box})
    o.w = w
    o.h = h
    o.jumpLock = 0
    return o
end

function Box:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.w, self.h)
end

function Box:tick(dt)
    self.jumpLock = math.max(self.jumpLock - dt, 0)
end

function Box:jump()
    if self.jumpLock > 0 then
        return
    end
    self.ySpeed = self.ySpeed - 20
    self.jumpLock = 1
end

-- ### globals
rect = Box:new(20, 20, 100, 100, 10)
keysPressed = {}
-- ### /globals

-- ### callback functions

function love.load()
    love.window.setTitle("オブジェクト指向　テスト")
    love.window.setMode(800, 600, {})
end

function love.draw()
    if rect.jumpLock > 0 then
        love.graphics.print("jumpLock", 20, 20)
    end
    rect:draw()     -- 長方形を表す
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

    rect:move()
    rect:collide()
    rect:friction()
    rect:tick(dt)
    rect:gravity()
end
