-- constants
JAFONT = nil
JAFONT_60 = nil
STDFONT = nil
STDFONT_20 = nil
-- /constants

HitBox = {}

function HitBox:new(x, y, w, h, noClip, playerNoClip)
    local o = {}
    setmetatable(o, {__index = HitBox})
    o.name = "HitBox"
    o.x = x
    o.y = y
    o.w = w
    o.h = h
    o.noClip = noClip
    o.playerNoClip = playerNoClip
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

function Entity:new(xPos, yPos, w, h, noClip, playerNoClip)
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
    o.hitBox = HitBox:new(xPos, yPos, w, h, noClip, playerNoClip)
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
    local o = Entity:new(xPos, yPos, w, h, false, false)
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

TriggerArea = {}
setmetatable(TriggerArea, {__index = Entity})

function TriggerArea:new(xPos, yPos, w, h)
    local o = Entity:new(xPos, yPos, w, h, true, true)
    setmetatable(o, {__index = TriggerArea})
    o.color = color
    return o
end

MovingThing = {}
setmetatable(MovingThing, {__index = Entity})

function MovingThing:new(xPos, yPos, w, h, maxSpeed, frictionFactor, jumpForce, flying, noClip, playerNoClip)
    local o = Entity:new(xPos, yPos, w, h, noClip, playerNoClip)
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
        haveToTest = true
        if e == self then haveToTest = false end
        if e.hitBox.noClip then haveToTest = false end
        if self.hitBox.noClip then haveToTest = false end
        if self.name == "Player" and e.hitBox.playerNoClip then haveToTest = false end
        if e.name == "Player" and self.hitBox.playerNoClip then haveToTest = false end
        if e.name == "Egg" and self.name == "Egg" then haveToTest = false end
        if haveToTest then
            sh = self.hitBox
            oh = e.hitBox
            hitX = sh:collidesWithDelta(oh, self.xSpeed, 0)
            hitY = sh:collidesWithDelta(oh, 0, self.ySpeed)
            hitXY = sh:collidesWithDelta(oh, self.xSpeed, self.ySpeed)
            if hitX ~= false then
                collidesX = true
                self.xSpeed = 0
                if hitX.x ~= 0 then -- FIXME bad hack
                    self.xPos = hitX.x
                end
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
function MovingThing:accUp()
    if math.abs(self.ySpeed) <= self.maxSpeed then
        self.ySpeed = self.ySpeed - 0.5
    end
end

function MovingThing:accDown()
    if math.abs(self.ySpeed) <= self.maxSpeed then
        self.ySpeed = self.ySpeed + 0.5
    end
end
function MovingThing:tekiRight()
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed + 0.5
    end
end
function MovingThing:tekiLeft()
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed - 0.5
    end
end



Egg = {}
setmetatable(Egg, {__index = MovingThing})

function Egg:new(xPos, yPos)
    local o = MovingThing:new(xPos, yPos, 20, 30, 0, 0, 0, false, false, true)
    setmetatable(o, {__index = Egg})
    o.name = "Egg"
    o.holder = nil
    o.color = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
    return o
end

function Egg:draw()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    rx = self.w/2
    ry = self.h/2
    love.graphics.ellipse("fill", self.xPos+rx, self.yPos+ry, rx, ry)
    love.graphics.setColor(30, 30, 30)
    love.graphics.ellipse("line", self.xPos+rx, self.yPos+ry, rx, ry)
    self.hitBox:draw()
end

function Egg:tick(dt)
    MovingThing.tick(self, dt) -- :tick(dt) doesn't work. because reasons
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
    self.ySpeed = 0
end

Player = {}
setmetatable(Player, {__index = MovingThing})

function Player:new(xPos, yPos)
    local o = MovingThing:new(xPos, yPos, 58, 79, 3, 0.5, 24, false, false, false)
    setmetatable(o, {__index = Player})
    o.hp = 100
    o.animationDtSum = 0
    o.animationFrame = 0
    o.currImgKey = 'mc_w_r1'
    o.holding = nil
    o.name = "Player"
    return o
end

function Player:takeDamage(dmg)
    self.hp = self.hp - dmg
end

function Player:pickUp()
    candidates = self:getAllCollidesWith()
    for i, e in ipairs(candidates) do
        if e.name == "Egg" and self.holding == nil then
            e:getPickedUp(self)
            self.holding = e
            self.maxSpeed = 1.5
        end
    end
end

function Player:drop()
    if self.holding ~= nil then
        self.holding:getDropped()
        self.holding = nil
        self.maxSpeed = 5
    end
end

function Player:die()
    gamePhase = 2
end

function Player:tick(dt)
    if self.hp <= 0 then
        self:die()
    end
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
    love.graphics.draw(images[self.currImgKey], self.xPos, self.yPos, 0, 0.1, 0.1)
    self.hitBox:draw()
end

Boss = {}
setmetatable(Boss, {__index = Entity})

function Boss:new(xPos, yPos,aSize)
    local o = Entity:new(xPos, yPos, aSize, aSize, true, false)
    setmetatable(o, {__index = Boss})
    o.pi = aSize
    o.dtSum = 0

    return o
end
function Boss:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", self.xPos, self.yPos, self.pi, 100)
    self.hitBox:draw()
end
function Boss:tick(dt)
    Entity.tick(self, dt)
         self.dtSum = self.dtSum + dt

    if self.dtSum >= 10 then

    table.insert(entities, Teki:new(self.xPos,self.yPos,10))




        self.dtSum = 0
    end

end
Teki = {}
setmetatable(Teki, {__index = MovingThing})

function Teki:new(xPos, yPos,aSize)
    local o = MovingThing:new(xPos, yPos, aSize, aSize, 5, 0.5, 30, true, true)
    setmetatable(o, {__index = Teki})
    o.pi = aSize
    return o
end

function Teki:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", self.xPos, self.yPos, self.pi, 100)
    self.hitBox:draw()
end

function Teki:tick(dt)
    MovingThing.tick(self, dt)

    if self.hitBox:collidesWith(player.hitBox) then

        player:takeDamage(50)
    end


        if self.yPos - player.yPos <=0 then

        self:accDown()
else

        self:accUp()

end

if self.xPos - player.xPos <=0 then

        self:tekiRight()

else

        self:tekiLeft()
  
end
end

function MovingThing:matsuRight()
        self.xPos = self.xPos + 0.5
        if self.xPos == 150 then
          self.time = 1
        end

end
function MovingThing:matsuLeft()
         self.xPos = self.xPos - 0.5
        if self.xPos == 0 then
        self.time = 0
      end
end

Matsu = {}
setmetatable(Matsu, {__index = MovingThing})

function Matsu:new(w,h,xPos, yPos)
    local o = MovingThing:new(xPos, yPos, w, h, 5, 0.5, 30, true, true)
    setmetatable(o, {__index = Matsu})
    o.time = 0
    return o
end

function Matsu:draw()
    self.hitBox:draw()

    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.w, self.h)

end

function Matsu:tick(dt)
    MovingThing.tick(self, dt)

    if self.hitBox:collidesWith(player.hitBox) then

        player:takeDamage(50)
    end


          if  self.time == 0 then

        self:matsuRight()

elseif  self.time == 1 then


        self:matsuLeft()
  
end
end
Kawateki = {}
setmetatable(Kawateki, {__index = MovingThing})

function Kawateki:new(w,h,xPos, yPos)
    local o = MovingThing:new(xPos, yPos, w, h, 5, 0.5, 30, true, true)
    setmetatable(o, {__index = Kawateki})
    o.time = 0
    return o
end

function Kawateki:draw()
    self.hitBox:draw()

    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.w, self.h)

end

function Kawateki:tick(dt)
    MovingThing.tick(self, dt)

    if self.hitBox:collidesWith(player.hitBox) then

        player:takeDamage(50)
    end
end


-- ### globals
debug = 0
bos = Boss:new(500,150,40)
entities = {}
kawateki=Kawateki:new(20,15,250,300)
table.insert(entities, kawateki)

table.insert(entities, bos)

debugMsg = ""
gamePhase = 0 -- 0=start, 1=game, 2=end
countdown = 120
score = 0
eggtimeout = 2

images = {}
player = Player:new(130, 700)
table.insert(entities, player)
tekihairetsu = {}
rect3 = Matsu:new(10, 10, 100, 320)
table.insert(entities, rect3)

floor = Block:new(0, 725, 600, 5, {99, 59, 39})
ceiling = Block:new(0, 0, 600, 5, {99, 59, 39})
wall_l = Block:new(0, 5, 5, 720, {99, 59, 39})
wall_r = Block:new(595, 5, 5, 720, {99, 59, 39})
plattform1 = Block:new(80, 520, 80, 5, {100, 200, 100})
plattform2 = Block:new(250, 450, 110, 5, {100, 100, 200})
plattform3 = Block:new(400, 390, 5, 50, {200, 100, 100})
plattform4 = Block:new(60, 230, 80, 5, {200, 200, 100}) 
plattform5 = Block:new(240, 290, 80, 5, {200, 100, 200})
plattform6 = Block:new(250, 620, 80, 5, {200, 100, 200})
eggSpawn = TriggerArea:new(60, 220, 80, 10)
eggGoal = TriggerArea:new(500, 715, 80, 10)
table.insert(entities, floor)
table.insert(entities, ceiling)
table.insert(entities, wall_l)
table.insert(entities, wall_r)
table.insert(entities, plattform1)
table.insert(entities, plattform2)
table.insert(entities, plattform3)
table.insert(entities, plattform4)
table.insert(entities, plattform5)
table.insert(entities, plattform6)
table.insert(entities, eggSpawn)
table.insert(entities, eggGoal)
-- ### /globals

-- ### callback functions

function love.load()
    STDFONT = love.graphics.getFont()
    STDFONT_20 = love.graphics.newFont(20);
    JAFONT = love.graphics.newFont("assets/ipaexg.ttf", 20);
    JAFONT_60 = love.graphics.newFont("assets/ipaexg.ttf", 60);
    love.window.setTitle("オブジェクト指向　テスト")
    love.window.setMode(600, 730, {})
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
    if gamePhase == 0 then
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(JAFONT_60);
        love.graphics.print("ゲームタイトル", 85, 275)
        love.graphics.rectangle("line", 80, 265, 433, 70)
        love.graphics.setFont(JAFONT);
        love.graphics.print("→　スペースキーでゲーム開始　←", 132, 350)
        love.graphics.setFont(STDFONT);
    end

    if gamePhase == 1 then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("Position: (" .. player.xPos .. "|" .. player.yPos .. ").", 20, 20)
        love.graphics.print("debug: " .. debugMsg, 20, 40)
        love.graphics.setFont(STDFONT_20);
        love.graphics.print("TIME: " .. math.floor(countdown + 0.5), 480, 20)
        love.graphics.print("SCORE: " .. score, 480, 50)
        love.graphics.setFont(STDFONT);
        for i, e in ipairs(entities) do
            e:draw()
        end
    end

    if gamePhase == 2 then
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(JAFONT_60);
        love.graphics.print("ゲームオーバー", 85, 275)
        love.graphics.setFont(STDFONT_20);
        love.graphics.print(">  SCORE: " .. score .. "  <", 215, 350)
        love.graphics.setFont(STDFONT);
    end
end

function love.update(dt)
    if gamePhase == 1 then
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

        countdown = countdown - dt
        if countdown <= 0.5 then
            gamePhase = 2
        end

        startEggs = 0
        goalEggs = 0

        for i, e in ipairs(entities) do
            e:tick(dt)

            if eggSpawn.hitBox:collidesWith(e.hitBox) and e.name == "Egg" then
                startEggs = startEggs + 1
            end
            if eggGoal.hitBox:collidesWith(e.hitBox) and e.name == "Egg" then
                goalEggs = goalEggs + 1
            end
        end
        --debugMsg = "s: " .. startEggs .. " | g: " .. goalEggs

        score = goalEggs
        if startEggs == 0 then
            eggtimeout = eggtimeout - dt
            if eggtimeout <= 0 then
                table.insert(entities, Egg:new(math.random(70, 130), 194))
                eggtimeout = 2
            end
        end
    end
end

function love.keypressed(key, scancode)
    if gamePhase == 0 and scancode == "space" then
        gamePhase = 1
    end
    if scancode == "h" then
        debug = 1 - debug
    end
end
