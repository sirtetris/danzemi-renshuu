HitBox = {}

function HitBox:new(x, y, w, h)
    local o = {}
    setmetatable(o, {__index = HitBox})
    o.x = x     -- x座標
    o.y = y     -- y座標
    o.w = w     -- 幅
    o.h = h     -- 高さ
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

function HitBox:touches(other)
    if self:getLower() == other:getUpper() then
        return "lo"
    elseif self:getUpper() == other:getLower() then
        return "up"
    elseif self:getRightmost() == other:getLeftmost() then
        return "ri"
    elseif self:getLeftmost() == other:getRightmost() then
        return "le"
    else
        return "-"
    end
end

function HitBox:draw()
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

-- ### globals
hb1 = HitBox:new(50, 50, 50, 70)
hb2 = HitBox:new(250, 250, 150, 50)
touches = ""
-- ### /globals

-- ### callback functions

function love.load()
    love.window.setTitle("衝突判定")
    love.window.setMode(800, 600, {})
end

function love.draw()
    txt = "no"
    if hb1:collidesWith(hb2) then
        txt = "yes"
    end
    lu = "no"
    ul = "no"
    rl = "no"
    lr = "no"
    if hb1:getLower() >= hb2:getUpper() then
        lu = "yes"
    end
    if hb1:getUpper() <= hb2:getLower() then
        ul = "yes"
    end
    if hb1:getRightmost() >= hb2:getLeftmost() then
        rl = "yes"
    end
    if hb1:getLeftmost() <= hb2:getRightmost() then
        lr = "yes"
    end
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Collision: " .. txt, 20, 20)
    love.graphics.print("1lo >= 2up: " .. lu, 20, 40)
    love.graphics.print("1up <= 2lo: " .. ul, 20, 60)
    love.graphics.print("1ri >= 2le: " .. rl, 20, 80)
    love.graphics.print("1le <= 2ri: " .. lr, 20, 100)
    love.graphics.print("touch: 1" .. touches, 20, 140)
    hb1:draw()
    hb2:draw()
end

function love.update(dt)
    hb1.x = love.mouse.getX()
    hb1.y = love.mouse.getY()
    touches = hb1:touches(hb2)
end
