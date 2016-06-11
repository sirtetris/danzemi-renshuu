jaFont = nil
stdFont = nil

function love.load()
    love.window.setTitle("テストだ")
    love.window.setMode(400, 300, {})
    stdFont = love.graphics.getFont()
    jaFont = love.graphics.newFont("assets/ipaexg.ttf", 20);
end

function love.update(dt)
end

function love.draw()
    love.graphics.setFont(stdFont);
    love.graphics.print("普通のフォントでダメだ。", 20, 20)
    love.graphics.print("ブブー…", 20, 40)
    love.graphics.setFont(jaFont);
    love.graphics.print("これで日本語も表示できる。", 20, 60)
    love.graphics.print("イエーイ…", 20, 80)
end
