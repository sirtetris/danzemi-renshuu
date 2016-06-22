Circle = {} -- 長方形というクラス

function Circle:new(xPos, yPos,radius,segments,red,blue,green,speed)    -- クラスのインスタンスを作るための関数
   o = {}                                   -- 新しいインスタンスを作る
   setmetatable(o, {__index = Circle})   -- メタテーブル...分からなくてもいいよ ;)
   o.xPos = xPos                            -- x位置
   o.yPos = yPos                            -- y位置
   o.radius = radius
   o.segments = segments
   o.aka = red
   o.ao = blue
   o.midori = green
   o.speed = speed
   return o                                 -- インスタンスを返す
end

function Circle:draw()                   -- クラスの関数、draw = （自分を）表す
    love.graphics.setColor(self.aka, self.ao, self.midori)   -- 色を設定
    love.graphics.circle("fill", self.xPos, self.yPos, self.radius,self.segments) -- 長方形を描く
end

function Circle:goUp()                   -- 上に動く　　
    self.yPos = self.yPos - self.speed
end

function Circle:goDown()
    self.yPos = self.yPos + self.speed
end

function Circle:goRight()
    self.xPos = self.xPos + self.speed
end

function Circle:goLeft()
    self.xPos = self.xPos - self.speed
end

-- ### globals
rect = Circle:new(50, 150,25,100,255,255,255,1)
rect2 = Circle:new(100,150,25,100,255,255,255,25)
rect3 = Circle:new(150,150,25,100,255,255,255,20)
rect4 = Circle:new(200,150,25,100,255,255,255,15)
rect5 = Circle:new(250,150,25,100,255,255,255,10)
rect6 = Circle:new(300,150,25,100,255,255,255,5)
rect7 = Circle:new(350,150,25,100,255,255,255,10) 
rect8 = Circle:new(400,150,25,100,255,255,255,15)
rect9 = Circle:new(450,150,25,100,255,255,255,20)
rect10 = Circle:new(500,150,25,100,255,255,255,25)
rect11 = Circle:new(550,150,25,100,255,255,255,1)-- 長方形のインスタンスを作る
-- ### /globals

-- ### callback functions

function love.load()                        -- ゲームを起動に一回実行されてる関数
    love.window.setTitle("オブジェクト指向　テスト")
    love.window.setMode(600, 500, {})
end


function love.update(dt)
    rect.yPos = (rect.yPos + rect.speed) % 500
    rect11.yPos = (rect11.yPos + rect11.speed) % 500
end

function love.draw()                        -- ゲームの実行中限り、繰り返し実行されてる関数
    love.graphics.print("Position: (" .. rect.xPos .. "|" .. rect.yPos .. ").", 20, 20) -- 位置情報を書く
    rect:draw()
    rect2:draw()
    rect3:draw()
    rect4:draw()
    rect5:draw()
    rect6:draw()
    rect7:draw()
    rect8:draw() 
    rect9:draw() 
    rect10:draw()
    rect11:draw()                               -- 長方形のインスタンスの関数を実行する
end

function love.keypressed(key, scancode)     -- キーボードが押されれば実行されてる関数
    if scancode ~= nil then
        if scancode == "up" then            -- scancodeはキーの名前（例えば：「a」、「space」、等）
            rect2:goUp()
            rect3:goUp()
            rect4:goUp()
            rect5:goUp()
            rect6:goUp()
            rect7:goUp()
            rect8:goUp()
            rect9:goUp()
            rect10:goUp()
        elseif scancode == "down" then
            rect2:goDown()
            rect3:goDown()
            rect4:goDown()
            rect5:goDown()
            rect6:goDown()
            rect7:goDown()
            rect8:goDown()
            rect9:goDown()
            rect10:goDown()
        elseif scancode == "right" then
            rect2:goRight()
            rect3:goRight()
            rect4:goRight()
            rect5:goRight()
            rect6:goRight()
            rect7:goRight()
            rect8:goRight()
            rect9:goRight()
            rect10:goRight()
        elseif scancode == "left" then
            rect2:goLeft()
            rect3:goLeft()
            rect4:goLeft()
            rect5:goLeft()
            rect6:goLeft()
            rect7:goLeft()
            rect8:goLeft()
            rect9:goLeft()
            rect10:goLeft()
        end
    end
end
