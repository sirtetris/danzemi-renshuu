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
   return o
end

function Rectangle:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.w, self.h)
end

function Rectangle:move()       -- 新しい位置＝現在の位置＋現在の速度
    self.xPos = self.xPos + self.xSpeed
    self.yPos = self.yPos + self.ySpeed
end

function Rectangle:friction()   -- 摩擦力（長方形は加速しなければ、段々遅くなる）
    xFac = 1    -- 今右へ動いてる
    yFac = 1    -- 下へ
    if self.xSpeed < 0 then         -- 左へ
        xFac = -1
    elseif self.xSpeed == 0 then    -- 止まった（x）
        xFac = 0
    end
    if self.ySpeed < 0 then         -- 上へ
        yFac = -1
    elseif self.ySpeed == 0 then    -- 止まった（y）
        yFac = 0
    end
    self.xSpeed = self.xSpeed - (0.5 * xFac)    -- 新しい速度は現在の速度ー0.5
    self.ySpeed = self.ySpeed - (0.5 * yFac)
end

function Rectangle:collide()    -- ゲームのウインドウを出るのを防ぐ
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

function Rectangle:accUp()      -- 上へ加速
    if math.abs(self.ySpeed) <= self.maxSpeed then
        self.ySpeed = self.ySpeed - 2
    end
end

function Rectangle:accDown()    -- 下へ加速
    if math.abs(self.ySpeed) <= self.maxSpeed then
        self.ySpeed = self.ySpeed + 2
    end
end

function Rectangle:accRight()   -- 右
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed + 2
    end
end

function Rectangle:accLeft()    -- 左
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed - 2
    end
end

-- ### globals
rect = Rectangle:new(20, 20, 100, 100)  -- 新しい長方形を作る
keysPressed = {}
-- ### /globals

-- ### callback functions

function love.load()
    love.window.setTitle("オブジェクト指向　テスト")
    love.window.setMode(800, 600, {})
end

function love.draw()
    love.graphics.print("Position: (" .. rect.xPos .. "|" .. rect.yPos .. ").", 20, 20)
    local keyStr = ""
    local keySum = 0
    for key, value in pairs(keysPressed) do
        if value then
            keyStr = keyStr .. key .. ", "
            keySum = keySum + 1
        end
    end
    love.graphics.print("Inputs: " .. keyStr .. " (" .. keySum .. ").", 20, 40)
    rect:draw()     -- 長方形を表す
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

    rect:collide()  -- ウインドウを出るのを防ぐ関数を実行する
    rect:move()     -- 速度によって動く関数
    rect:friction() -- 摩擦関数
end
