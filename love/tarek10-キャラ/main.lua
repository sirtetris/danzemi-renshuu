-- constants
-- /constants

HitBox = {}

function HitBox:new(x, y, w, h, noClip)
    local o = {}
    setmetatable(o, {__index = HitBox})
    o.name = "HitBox"
    o.x = x
    o.y = y
    o.w = w
    o.h = h
    o.noClip = noClip
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
    if debug == 1 then
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    end
end

Entity = {}

function Entity:new(xPos, yPos, w, h, noClip)
    local o = {}
    setmetatable(o, {__index = Entity})
    o.name = "Entity"
    o.xPos = xPos
    o.yPos = yPos
    o.w = w
    o.h = h
    o.xSpeed = 0
    o.ySpeed = 0
    o.maxSpeed = 5
    o.jumpLock = 0
    o.hitBox = HitBox:new(xPos, yPos, w, h, noClip)
    return o
end

function Entity:getAllCollidesWith()
    collisions = {}
    for i, e in ipairs(entities) do
        if e ~= self then
            sh = self.hitBox
            oh = e.hitBox
            if sh:collidesWith(oh) then
                table.insert(collisions, e)
            end
        end
    end
    return collisions
end

function Entity:draw()
    self.hitBox:draw()
end

function Entity:tick(dt)
    self.hitBox.x = self.xPos
    self.hitBox.y = self.yPos
end

Block = {}
setmetatable(Block, {__index = Entity})

function Block:new(xPos, yPos, w, h, color)
    local o = Entity:new(xPos, yPos, w, h, false)
    setmetatable(o, {__index = Block})
    o.color = color
    return o
end

function Block:draw()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.w, self.h)
    self.hitBox:draw()
end

function Block:draw()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.w, self.h)
    self.hitBox:draw()
end

Egg = {}
setmetatable(Egg, {__index = Entity})

function Egg:new(xPos, yPos)
    local o = Entity:new(xPos, yPos, 40, 60, true)
    setmetatable(o, {__index = Egg})
    o.name = "Egg"
    o.holder = nil
    return o
end

function Egg:draw()
    love.graphics.setColor(200, 200, 200)
    rx = self.w/2
    ry = self.h/2
    love.graphics.ellipse("fill", self.xPos+rx, self.yPos+ry, rx, ry)
    self.hitBox:draw()
end

function Egg:tick(dt)
    Entity.tick(self, dt) -- :tick(dt) doesn't work. because reasons
    if self.holder == nil then
        return
    end
    self.xPos = self.holder.xPos
    self.yPos = self.holder.yPos
end

function Egg:getPickedUp(someone)
    self.holder = someone
end

function Egg:getDropped()
    self.holder = nil
end

MovingThing = {}
setmetatable(MovingThing, {__index = Entity})

function MovingThing:new(xPos, yPos, w, h, maxSpeed, frictionFactor, jumpForce, flying, noClip)
    local o = Entity:new(xPos, yPos, w, h, noClip)
    setmetatable(o, {__index = MovingThing})
    o.maxSpeed = maxSpeed
    o.frictionFactor = frictionFactor
    o.jumpForce = jumpForce
    o.flying = flying
    return o
end

function MovingThing:move()
    collidesX = false
    collidesY = false
    for i, e in ipairs(entities) do
        if e ~= self and not e.hitBox.noClip then
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

function MovingThing:friction()
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
    self.xSpeed = self.xSpeed - (self.frictionFactor * xFac)
    self.ySpeed = self.ySpeed - (self.frictionFactor * yFac)
end

function MovingThing:gravity()
    self.ySpeed = self.ySpeed + 1.5
end

function MovingThing:accRight()
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed + 2
    end
end

function MovingThing:accLeft()
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed - 2
    end
end

function MovingThing:accUp()
    if math.abs(self.ySpeed) <= self.maxSpeed then
        self.ySpeed = self.ySpeed - 2
    end
end

function MovingThing:accDown()
    if math.abs(self.ySpeed) <= self.maxSpeed then
        self.ySpeed = self.ySpeed + 2
    end
end

function MovingThing:jump()
    if self.jumpLock > 0 then
        return
    end
    self.ySpeed = self.ySpeed - self.jumpForce
    self.jumpLock = 1
end

function MovingThing:tick(dt)
    Entity.tick(self, dt) -- :tick(dt) doesn't work. because reasons
    self:move()
    self:friction()
    if not self.flying then
        self:gravity()
    end
end

Player = {}
setmetatable(Player, {__index = MovingThing})

function Player:new(xPos, yPos)
    local o = MovingThing:new(xPos, yPos, 116, 158, 5, 0.5, 30, false, false)
    setmetatable(o, {__index = Player})
    o.alive = true
    o.animationDtSum = 0
    o.animationFrame = 0
    o.currImgKey = 'mc_w_r1'
    o.holding = nil
    return o
end

function Player:pickUp()
    candidates = self:getAllCollidesWith()
    for i, e in ipairs(candidates) do
        if e.name == "Egg" then
            e:getPickedUp(self)
            self.holding = e
        end
    end
end

function Player:drop()
    if self.holding ~= nil then
        self.holding:getDropped()
        self.holding = nil
    end
end

function Player:tick(dt)
    MovingThing.tick(self, dt) -- :tick(dt) doesn't work. because reasons
    self.animationDtSum = self.animationDtSum + dt
    imgKey = 'mc_w_'
    if self.xSpeed >= 0 then
        imgKey = imgKey .. 'r'
    else
        imgKey = imgKey .. 'l'
    end
    if self.animationDtSum > 0.3 and math.abs(self.xSpeed) > 0 then
        self.animationFrame = (self.animationFrame + 1) % 4
        self.animationDtSum = 0
    end
    self.currImgKey = imgKey .. (self.animationFrame + 1)
end

function Player:draw()
    love.graphics.draw(images[self.currImgKey], self.xPos, self.yPos, 0, 0.2, 0.2)
    self.hitBox:draw()
end

-- ### globals
debug = 0
debugMsg = ""
entities = {}
images = {}
player = Player:new(30, 180)
table.insert(entities, player)
egg1 = Egg:new(340, 280)
table.insert(entities, egg1)
floor = Block:new(0, 590, 800, 5, {200, 200, 200})
plattform1 = Block:new(80, 520, 80, 5, {100, 200, 100})
plattform2 = Block:new(200, 450, 160, 5, {100, 100, 200})
plattform3 = Block:new(400, 390, 5, 50, {200, 100, 100})
plattform4 = Block:new(200, 340, 120, 5, {200, 200, 100})
plattform5 = Block:new(240, 290, 80, 5, {200, 100, 200})
plattform6 = Block:new(560, 290, 180, 5, {100, 200, 200})
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
    love.graphics.setBackgroundColor(150, 150, 150)
    images.mc_w_r1 = love.graphics.newImage('assets/mc_w_r1.png')
    images.mc_w_r2 = love.graphics.newImage('assets/mc_w_r2.png')
    images.mc_w_r3 = love.graphics.newImage('assets/mc_w_r3.png')
    images.mc_w_r4 = love.graphics.newImage('assets/mc_w_r4.png')
    images.mc_w_l1 = love.graphics.newImage('assets/mc_w_l1.png')
    images.mc_w_l2 = love.graphics.newImage('assets/mc_w_l2.png')
    images.mc_w_l3 = love.graphics.newImage('assets/mc_w_l3.png')
    images.mc_w_l4 = love.graphics.newImage('assets/mc_w_l4.png')
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Position: (" .. player.xPos .. "|" .. player.yPos .. ").", 20, 20)
    love.graphics.print("debug: " .. debugMsg, 20, 40)
    for i, e in ipairs(entities) do
        e:draw()
    end
end

function love.update(dt)
    if love.keyboard.isDown("space") then
        player:jump()
    end
    if love.keyboard.isDown("right") then
        player:accRight()
    end
    if love.keyboard.isDown("left") then
        player:accLeft()
    end
    if love.keyboard.isDown("g") then
        player:pickUp()
    end
    if love.keyboard.isDown("d") then
        player:drop()
    end

    for i, e in ipairs(entities) do
        e:tick(dt)
    end
end

function love.keypressed(key, scancode)
    if scancode == 'h' then
        debug = 1 - debug
    end
end
