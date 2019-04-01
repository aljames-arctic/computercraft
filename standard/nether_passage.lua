-- floor and ceiling
pmemory = dofile("/apis/pmemory")
turtle = dofile("/apis/turtle")

length = 0
slot = 1
turtle.initialize()

for i = 1, length, 1 do 
    turtle.move("forward", true)
    turtle.dig("down")
    succ, cnt = turtle.place("down")
    if cnt == 0 then
        slot = slot + 1
        turtle.select(slot)
    end
    turtle.move("up", true)
    turtle.dig("up")
    succ, cnt = turtle.place("up")
    if cnt == 0 then
        slot = slot + 1
        turtle.select(slot)
    end
    turtle.move("down", true)
end

turtle.to({"x:0","y:0","z:0"})