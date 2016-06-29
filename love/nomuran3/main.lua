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
rect = Circle:new(10, 0,25,100,255,255,255,1)
rect2 = Circle:new(300,150,25,100,255,255,255,25)
-- 長方形のインスタンスを作る
-- ### /globals

-- ### callback functions

function love.load()                        -- ゲームを起動に一回実行されてる関数
    love.window.setTitle("オブジェクト指向　テスト")
    love.window.setMode(600, 500, {})
end

function love.update(dt)
    if rect2.xPos < rect.xPos then rect.xPos = rect.xPos -1
    end
    if rect2.xPos > rect.xPos then rect.xPos = rect.xPos +1
    end
    if rect2.yPos < rect.yPos then rect.yPos = rect.yPos -1
    end
    if rect2.yPos > rect.yPos then rect.yPos = rect.yPos +1
    end
end

function love.draw()                        -- ゲームの実行中限り、繰り返し実行されてる関数
    love.graphics.print("Position: (" .. rect.xPos .. "|" .. rect.yPos .. ").", 20, 20) -- 位置情報を書く
    rect:draw()
    rect2:draw()                              -- 長方形のインスタンスの関数を実行する
end

function love.keypressed(key, scancode)     -- キーボードが押されれば実行されてる関数
    if scancode ~= nil then
        if scancode == "up" then            -- scancodeはキーの名前（例えば：「a」、「space」、等）
            rect2:goUp()

        elseif scancode == "down" then
            rect2:goDown()

        elseif scancode == "right" then
            rect2:goRight()

        elseif scancode == "left" then
            rect2:goLeft()

        end
    end
end
