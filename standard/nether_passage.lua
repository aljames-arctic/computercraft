-- floor and ceiling
turtle = dofile("/apis/turtle")

length = 0

for i = 1, length, 1 do 
    turtle.move("forward", true)
    turtle.dig("down")
    turtle.place("down")
    turtle.move("up", true)
    turtle.dig("up")
    turtle.place("up")
    turtle.move("down", true)
end