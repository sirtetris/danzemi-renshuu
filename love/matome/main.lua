-- TODO notes:
-- 1 TextIndicator class (wabbling over enemy/crosshair)
--      if active and right keys pressed mark 'owning' enemy dead
--      -> dead entity garbage collection routine
-- spawning of enemies
--      smhw over plattforms

-- constants
JAFONT = nil
JAFONT_60 = nil
STDFONT = nil
STDFONT_20 = nil
SCREEN_W = 1000
SCREEN_H = 730
-- /constants

TextIndicator = {} -- treat as Singleton (?)

function TextIndicator:new(xPos, yPos)
    local o = {}
    setmetatable(o, {__index = TextIndicator})
    o.name = "TextIndicator"
    o.xPos = xPos
    o.yPos = yPos
    o.xOrigin = xPos
    o.yOrigin = yPos
    o.owner = nil
    o.button = nil
    o.count = nil
    o.active = false
    return o
end

function TextIndicator:wiggle()
    dx = math.random(-4, 4)
    dy = math.random(-4, 4)
    self.xPos = self.xOrigin + dx
    self.yPos = self.yOrigin + dy
end

function TextIndicator:follow()
    oc = self.owner.hitBox:getCenter()
    --debugMsg = oc.x .. " | " .. oc.y
    self.xOrigin = oc.x - 26
    self.yOrigin = oc.y - 50
end

function TextIndicator:draw()
    if self.active then
        love.graphics.setColor(255, 5, 5)
        love.graphics.setFont(STDFONT_20);
        love.graphics.print(self.button .. " x " .. self.count, self.xPos, self.yPos)
        love.graphics.setFont(STDFONT);
    end
end

function TextIndicator:setOwner(o)
    self.owner = o
end

function TextIndicator:activate()
    self.button = string.char(math.random(97, 122))
    self.count = math.random(2, 5)
    self.active = true
end

function TextIndicator:deactivate()
    self.active = false
end

function TextIndicator:tick()
    if self.count <= 0 then
        self:deactivate()
    end
    self:follow()
    self:wiggle()
end

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

function HitBox:getCenter()
    return {x=self.x+(self.w/2), y=self.y+(self.h/2)}
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

function Entity:findNearest(limit, class)
    selfCenter = self.hitBox:getCenter()
    nearest = nil
    nearestDistance = 9999
    for i, e in ipairs(entities) do
        if e ~= self then
            if class == nil or (class ~= nil and e.name == class) then
                otherCenter = e.hitBox:getCenter()
                xDif = selfCenter.x - otherCenter.x
                yDif = selfCenter.y - otherCenter.y
                dist = math.sqrt((xDif*xDif) + (yDif*yDif))
                if dist < nearestDistance then
                    nearest = e
                    nearestDistance = dist
                end
            end
        end
    end
    if nearestDistance > limit then
        return nil
    else
        nCenter = nearest.hitBox:getCenter()
        return nearest
    end
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

function Block:new(xPos, yPos, len)
    local o = Entity:new(xPos, yPos, len*15, 15, false, false)
    setmetatable(o, {__index = Block})
    o.color = color
    o.len = len
    return o
end

function Block:draw()
    love.graphics.setColor(255, 255, 255)
    for offset=0, self.len*15, 15 do
        love.graphics.draw(images.grassblock, self.xPos + offset, self.yPos)
    end
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

function TriggerArea:draw()
    love.graphics.setColor(255, 0, 0, 50)
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.w, self.h)
    self.hitBox:draw()
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
    hoc = self.holder.hitBox:getCenter()
    self.xPos = hoc.x
    self.yPos = hoc.y-30
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
    local o = MovingThing:new(xPos, yPos, 141, 230, 3, 0.5, 34, false, false, false)
    setmetatable(o, {__index = Player})
    o.hp = 100
    o.animationDtSum = 0
    o.animationFrame = 0
    o.currImgKey = 'mc_s'
    o.holding = nil
    o.target = nil
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

    -- targeting enemies
    self.target = player:findNearest(350, "Enemy")

    -- animation
    self.animationDtSum = self.animationDtSum + dt
    imgKey = 'mc_'
    if self.xSpeed == 0 then
        imgKey = imgKey ..'s'
    else
        imgKey = imgKey .. 'w_'
        if self.xSpeed >= 0 then
            imgKey = imgKey .. 'r'
        else
            imgKey = imgKey .. 'l'
        end
        delay = 0.13
        if self.holding ~= nil then delay = 0.26 end
        if self.animationDtSum > delay and math.abs(self.xSpeed) > 0 then
            self.animationFrame = (self.animationFrame + 1) % 5
            self.animationDtSum = 0
        end
        imgKey = imgKey .. (self.animationFrame + 1)
    end
    self.currImgKey = imgKey
    --debugMsg = imgKey
end

function Player:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(images[self.currImgKey], self.xPos, self.yPos)
    self.hitBox:draw()
end

-- enemy insert
Enemy = {}
setmetatable(Enemy,{__index = MovingThing})

function Enemy:new(xPos, yPos)
    local o = MovingThing:new(xPos, yPos, 60, 60, 3, 0.5, 25, false, false)
    setmetatable(o, {__index = Enemy})
    o.alive = true
    o.name = "Enemy"
    return o
end

function Enemy:draw()
    love.graphics.setColor(50,50,50)   -- 色を設定
    love.graphics.circle("fill", self.xPos+self.w/2, self.yPos+self.h/2, 25,50) -- 長方形を描く
    self.hitBox:draw()
end

function Enemy:tick(dt)
    MovingThing.tick(self, dt) -- :tick(dt) doesn't work. because reasons
    if player.holding == nil then
        return
    end
    if player.xPos < self.xPos then
        self:accLeft()
    end
    if player.xPos > self.xPos then
        self:accRight()
    end
    if player.yPos < self.yPos then
        self:jump()
    end
end
-- /enemy insert

math.randomseed(os.time())
-- ### globals
debug = 0
debugMsg = ""
gamePhase = 0 -- 0=start, 1=game, 2=end
countdown = 120
score = 0
eggtimeout = 2
viewscale = 1
entities = {}
images = {}
player = Player:new(130, 80)
table.insert(entities, player)
enemy = Enemy:new(500, 300)
table.insert(entities, enemy)

test = TextIndicator:new(0, 0)
test:setOwner(enemy)
test:activate()

plattform1 = Block:new(0, 725, 400)
plattform2 = Block:new(10, 230, 15)
plattform3 = Block:new(300, 500, 20)
eggSpawn = TriggerArea:new(60, 220, 80, 10)
eggGoal = TriggerArea:new(600, 715, 180, 10)
table.insert(entities, plattform1)
table.insert(entities, plattform2)
table.insert(entities, plattform3)
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
    love.window.setMode(SCREEN_W, SCREEN_H, {})
    love.graphics.setBackgroundColor(150, 150, 150)
    images.mc_w_r1 = love.graphics.newImage('assets/mc_w_r1.png')
    images.mc_w_r2 = love.graphics.newImage('assets/mc_w_r2.png')
    images.mc_w_r3 = love.graphics.newImage('assets/mc_w_r3.png')
    images.mc_w_r4 = love.graphics.newImage('assets/mc_w_r4.png')
    images.mc_w_r5 = love.graphics.newImage('assets/mc_w_r5.png')
    images.mc_w_l1 = love.graphics.newImage('assets/mc_w_l1.png')
    images.mc_w_l2 = love.graphics.newImage('assets/mc_w_l2.png')
    images.mc_w_l3 = love.graphics.newImage('assets/mc_w_l3.png')
    images.mc_w_l4 = love.graphics.newImage('assets/mc_w_l4.png')
    images.mc_w_l5 = love.graphics.newImage('assets/mc_w_l5.png')
    images.bg = love.graphics.newImage('assets/bg.jpg')
    images.mc_s = love.graphics.newImage('assets/mc_s.png')
    images.aim = love.graphics.newImage('assets/aim.png')
    images.grassblock = love.graphics.newImage('assets/grassblock.png')
    music = love.audio.newSource("assets/mamimumemo.wav")
end

function love.draw()
    if gamePhase == 0 then
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(JAFONT_60);
        love.graphics.print("ゲームタイトル", (SCREEN_W/2)-215, 275)
        love.graphics.rectangle("line", (SCREEN_W/2)-220, 265, 433, 70)
        love.graphics.setFont(JAFONT);
        love.graphics.print("→　スペースキーでゲーム開始　←", (SCREEN_W/2)-168, 350)
        love.graphics.setFont(STDFONT);
    end

    if gamePhase == 1 then
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(images.bg, 0, 0)
        love.graphics.print("Position: (" .. player.xPos .. "|" .. player.yPos .. ").", 20, 20)
        love.graphics.print("debug: " .. debugMsg, 20, 40)
        love.graphics.setFont(STDFONT_20);
        love.graphics.setColor(20, 20, 20)
        love.graphics.print("TIME: " .. math.floor(countdown + 0.5), SCREEN_W-130, 20)
        love.graphics.print("SCORE: " .. score, SCREEN_W-130, 50)
        love.graphics.print("HP: " .. player.hp, SCREEN_W-130, 80)
        love.graphics.setFont(STDFONT);
        love.graphics.setColor(255, 255, 255)
        --
        love.graphics.scale(viewscale, viewscale)
        pc = player.hitBox:getCenter()
        love.graphics.translate(-pc.x+((SCREEN_W)/(2*viewscale)), -pc.y+(SCREEN_H/(2*viewscale)))
        -- RELAIVE FROM HERE
        for i, e in ipairs(entities) do
            e:draw()
        end

        -- bad foreground hack
        if player.target ~= nil then
            love.graphics.setColor(255, 255, 255)
            tc = player.target.hitBox:getCenter()
            love.graphics.draw(images.aim, tc.x-17, tc.y-17)
        end

        test:draw()
    end

    if gamePhase == 2 then
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(JAFONT_60);
        love.graphics.print("ゲームオーバー", (SCREEN_W/2)-215, 275)
        love.graphics.setFont(STDFONT_20);
        love.graphics.print(">  SCORE: " .. score .. "  <", (SCREEN_W/2)-85, 350)
        love.graphics.setFont(STDFONT);
    end
end

function love.update(dt)
    if gamePhase == 1 then
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

        test:tick()

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
    if scancode == "h" then
        debug = 1 - debug
    end
    if gamePhase == 0 and scancode == "space" then
        gamePhase = 1
        music:play()
    end
    if gamePhase == 1 then
        if scancode == "space" then
            player:jump()
        end
        if scancode == "f" then -- make player skill w/ timeout (e.g. only for 5s a time)
            viewscale = 0.5
        end
        if scancode == test.button then
            test.count = test.count - 1
        end
    end
end

function love.keyreleased(key, scancode)
    if scancode == "f" then
        viewscale = 1
    end
end
