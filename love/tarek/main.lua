-- ### globals
keyPressed = nil
mouseButtonPressed = nil
fpsCount = 0
fps = 0
dtSum = 0
catImg = nil
-- ### /globals

-- ### callback functions

-- automatically gets called once at startup
function love.load()
    love.window.setTitle("テストだ")
    love.window.setMode(400, 300, {})
    catImg = love.graphics.newImage('assets/cat.jpg')
end

-- tick function, called continuously, do math here, dt is delta time
function love.update(dt)
    dtSum = dtSum + dt
    if dtSum >= 1 then
        fps = fpsCount
        fpsCount = 0
        dtSum = 0
    end
    fpsCount = fpsCount + 1
end

-- called continuously, place calls to love.graphics.draw here
function love.draw()
    local x = love.mouse.getX()
    local y = love.mouse.getY()
    local k = "<none>"
    local mb = "<none>"
    if keyPressed ~= nil then
        k = keyPressed
    end
    if mouseButtonPressed ~= nil then
        if mouseButtonPressed == 1 then
            mb = "left"
        elseif mouseButtonPressed == 2 then
            mb = "right"
        elseif mouseButtonPressed == 3 then
            mb = "middle"
        end
    end
    love.graphics.print("Cursor: (" .. x .. "|" .. y .. ").", 20, 20)
    love.graphics.print("Key: " .. k, 20, 40)
    love.graphics.print("Mouse: " .. mb, 20, 60)
    love.graphics.print(fps .. " fps", 340, 20)

    love.graphics.draw(catImg, 100, 120)
end

function love.mousepressed(x, y, button)
    mouseButtonPressed = button
end

function love.mousereleased(x, y, button)
    mouseButtonPressed = nil
end

function love.keypressed(key, scancode)
    keyPressed = scancode
end

function love.keyreleased(key, scancode)
    keyPressed = nil
end

-- called whenever focus changes
function love.focus(f)
    if not f then
        --
    else
        --
    end
end

-- called before exit
function love.quit()
    --
end

-- ###/ callback functions
