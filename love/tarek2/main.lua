Rectangle = {} -- 長方形というクラス

function Rectangle:new(w, h, xPos, yPos)    -- クラスのインスタンスを作るための関数
   o = {}                                   -- 新しいインスタンスを作る
   setmetatable(o, {__index = Rectangle})   -- メタテーブル...分からなくてもいいよ ;)
   o.w = w                                  -- 幅
   o.h = h                                  -- 高さ
   o.xPos = xPos                            -- x位置
   o.yPos = yPos                            -- y位置
   return o                                 -- インスタンスを返す
end

function Rectangle:draw()                   -- クラスの関数、draw = （自分を）表す
    love.graphics.setColor(255, 255, 255)   -- 色を設定
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.w, self.h) -- 長方形を描く
end

function Rectangle:goUp()                   -- 上に動く
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
rect = Rectangle:new(20, 20, 100, 100)      -- 長方形のインスタンスを作る
-- ### /globals

-- ### callback functions

function love.load()                        -- ゲームを起動に一回実行されてる関数
    love.window.setTitle("オブジェクト指向　テスト")
    love.window.setMode(400, 300, {})
end

function love.draw()                        -- ゲームの実行中限り、繰り返し実行されてる関数
    love.graphics.print("Position: (" .. rect.xPos .. "|" .. rect.yPos .. ").", 20, 20) -- 位置情報を書く
    rect:draw()                             -- 長方形のインスタンスの関数を実行する
end

function love.keypressed(key, scancode)     -- キーボードが押されれば実行されてる関数
    if scancode ~= nil then
        if scancode == "up" then            -- scancodeはキーの名前（例えば：「a」、「space」、等）
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
