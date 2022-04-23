-- Screen vars
screen_delay = 45
dial_width = 6
x_sum = 3
dial = {}
show_edit = false
play_index = 4


function screen_redraw()
    screen.clear()
    screen.fill()
    -- dials need to be redrawn to display:
    for i = 0,(program_width-1) do
      dial[i]:redraw()
      dial[(i+max_program_width)]:redraw()
      dial[(i+(max_program_width*2))]:redraw()
    end
    
    screen.level(15)

    lineSum = 11 + (7 * edit_column) + math.floor(edit_column / 4)
    screen.rect(lineSum, 28, 6, 1)
    screen.rect(lineSum, 46, 6, 1)
    screen.fill()

    screen.font_face(2)
    screen.font_size(6)
    
    screen.move(4,16)
    screen.text("A")

    screen.move(4,34)
    screen.text("B")

    screen.move(4,54)
    screen.text("C")
    
    screen.font_size(7)
    
    screen.move(0,22)
    screen.text("1v")

    screen.move(0,40)
    screen.text("5v")

    screen.move(0,60)
    screen.text("Cc")
    
    -- print functions
    i=0
    x_sum=5
    screen.font_face(2)
    screen.font_size(8)
    while( i < program_width )
    do
        x_sum = x_sum + 7
        if i%4 == 0 then
            x_sum = x_sum + 1 --- add a extra space for each 4
        end

        if program_functions[i+1] > 0 then
          screen.move(x_sum,7)
          screen.text(getFunction(i, true))
        end
        
        i = i+1
    end

    if screen_delay < 50 then
      screen.font_face(5)
      screen.font_size(20)
      screen.text_center_rotate(110,30, get_correct_value(edit_column, last_edit), 90)

    else
      screen.font_size(9)

      screen.move(110,8)
      screen.text("P")
      screen.move(120,8)
      screen.text("R")

      screen.move(110,18)
      screen.text("S")
      screen.move(120,18)
      screen.text(".")

      screen.move(110,26)
      screen.text(">")
      screen.move(120,26)
      screen.text("<")

      screen.move(110,36)
      screen.font_size(8)
      screen.text("X")
      screen.move(120,40)
      screen.font_size(9)
      screen.text("?")
    
      screen.move(110,45)
      screen.text("+")
      screen.move(120,48)
      screen.font_size(15)
      screen.text("-")

      playicon:redraw()
    end


    screen.update()
end
