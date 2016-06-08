-- # # # # # # #
-- 継承のテスト
-- # # # # # # #


-- スーパークラス「形」
--
Shape = {}

function Shape:new(xPos, yPos)
    local o = {}
    setmetatable(o, {__index = Shape})
    o.xPos = xPos
    o.yPos = yPos
    return o
end

function Shape:infoPos()
    print("[" .. self.xPos .. "|" .. self.yPos .. "]")
end

function Shape:infoAll()
    print("[" .. self.xPos .. "|" .. self.yPos .. "]")
end


-- サブクラス「円形」
--
Circle = {}
setmetatable(Circle, {__index = Shape})

function Circle:new(xPos, yPos, rad)
    local o = Shape:new(xPos, yPos)
    setmetatable(o, {__index = Circle})
    o.rad = rad
    return o
end

function Circle:infoAll()
    print("[" .. self.xPos .. "|" .. self.yPos .. "], radius: " .. self.rad)
end


-- サブクラス「長方形」
--
Rectangle = {}
setmetatable(Rectangle, {__index = Shape})

function Rectangle:new(xPos, yPos, width, height)
    local o = Shape:new(xPos, yPos)
    setmetatable(o, {__index = Rectangle})
    o.width = width
    o.height = height
    return o
end

function Rectangle:infoAll()
    print("[" .. self.xPos .. "|" .. self.yPos .. "], width:" .. self.width .. ", height: " .. self.height)
end


-- インスタンスを作って、継承を確認する
--
s = Shape:new(13, 37)
c = Circle:new(-2, 4, 3)
r1 = Rectangle:new(0, 0, 10, 20)
r2 = Rectangle:new(100, 100, 3, 4)

s:infoPos()
s:infoAll()
c:infoPos()
c:infoAll()
r1:infoPos()
r1:infoAll()
r2:infoPos()
r2:infoAll()
