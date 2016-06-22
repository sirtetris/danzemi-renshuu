Arcangle = {}

function Arcangle:new(w, h, xPos, yPos)
   o = {}
   setmetatable(o, {__index = Arcangle})
   o.w = w
   o.h = h
   o.xPos = xPos
   o.yPos = yPos
   o.xSpeed = 0;
   o.ySpeed = 0;
   o.maxSpeed = 10;
   return o
end

function Arcangle:draw()
	pacwidth = math.pi/6

    love.graphics.setColor(255, 255, 255)
    love.graphics.arc("fill", self.xPos, self.yPos,30,pacwidth,(math.pi * 2)-pacwidth )
end

function Arcangle:move()
	self.xPos = self.xPos + self.xSpeed
	self.yPos = self.yPos + self.ySpeed
end

--*
function Arcangle:masatu()
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
    self.xSpeed = self.xSpeed  - (0.5 * xFac)    
    self.ySpeed = self.ySpeed  - (0.5 * yFac)
end

function Arcangle:collide()    
    if self.xPos > 600 then
        self.xSpeed = 0
        self.xPos = 600
    end
    if self.xPos < 0 then
        self.xSpeed = 0
        self.xPos = 0
    end
    if self.yPos > 500 then
        self.ySpeed = 0
        self.yPos = 500
    end
    if self.yPos < 0 then
        self.ySpeed = 0
        self.yPos = 0
    end
end

--*
function Arcangle:goUp()     
    if math.abs(self.ySpeed) <= self.maxSpeed then
        self.ySpeed = self.ySpeed - 2
    end
end

function Arcangle:goDown()    
    if math.abs(self.ySpeed) <= self.maxSpeed then
        self.ySpeed = self.ySpeed + 2
    end
end

function Arcangle:goRight() 
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed + 2
    end
end

function Arcangle:goLeft()  
    if math.abs(self.xSpeed) <= self.maxSpeed then
        self.xSpeed = self.xSpeed - 2
    end
end

function Arcangle:supergo()
    self.xPos = self.xPos + 60
    self.yPos = self.yPos + 70

end
function Arcangle:superback()
	self.xPos = self.xPos - 60
    self.yPos = self.yPos - 70

end
function Arcangle:moving()

	 love.graphics.setColor(255, 0, 0)

	Mousex,Mousey = love.mouse.getPosition()
	self.xPos = Mousex
   self.yPos = Mousey

	love.graphics.arc("line", self.xPos,self.yPos,30,pacwidth,(math.pi * 2)-pacwidth )

end

-- ### globals
rect1 = Arcangle:new(30, 30, 150, 120)
rect2 = Arcangle:new(30, 30, 185, 120)
rect3 = Arcangle:new(10, 10, 300, 10)
rect4 = Arcangle:new(10,60,400,100)
keysPressed = {}
-- ### /globals

-- ### callback functions

function love.load()
    love.window.setTitle("オブジェクト指向　テスト")
    love.window.setMode(600, 500, {})
end


function love.update(dt)
	 rect3.yPos = (rect3.yPos + 1) % 300

    if love.keyboard.isDown("up") then
        rect1:goUp()
    end
    if love.keyboard.isDown( "down") then
        rect1:goDown()
    end
    if love.keyboard.isDown("right") then
        rect1:goRight()
    end
    if love.keyboard.isDown("left") then
        rect1:goLeft()
    end
    if love.keyboard.isDown("space") then
    	rect2:superback()
    end
    if love.keyboard.isDown("return") then
    	rect2:supergo()
    end

    rect1:collide()  
    rect1:move()     
    rect1:masatu() 

    rect2:collide() 
    rect2:move()    
    rect2:masatu() 

    -- rect3:move()    

end



function love.draw()
	love.graphics.setColor(255, 255, 255)

    love.graphics.print("Position Arc1: (" .. rect1.xPos .. "|" .. rect1.yPos .. ").", 20, 20)
    love.graphics.print("Position Arc2: (" .. rect2.xPos .. "|" .. rect2.yPos .. ").", 20, 40)
    love.graphics.print("Position Arc3: (" .. rect3.xPos .. "|" .. rect3.yPos .. ").", 20, 60)
    love.graphics.print("Position Arc4: (" .. rect4.xPos .. "|" .. rect4.yPos .. ").", 20, 80)

    rect1:draw()
    rect2:draw()
    rect3:draw()
    rect4:moving()


end

