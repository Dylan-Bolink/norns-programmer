-- Programmer
--        a love letter to serge
-- v0.1
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
-- need help?
-- please visit:
-- l.llllllll.co/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UI = require("ui")
g = grid.connect() -- 'g' === grid

---------
i=0
x_sum=2
dial_width = 5

program_width = 15
program_data = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,40,0,20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}


dial = {}
active_column = 0

a_draw_offset = 1
b_draw_offset = 3
c_draw_offset = 5
active_draw_offset = 8


-- Screen vars
screen.aa(1) -- provides smoother screen drawing
---------

while( i < program_width )
    do
        x_sum = x_sum + 6
        if i%4 == 0 then
            x_sum = x_sum + 1 --- add a extra space for each 4
        end
        --- x, y, width, height, value, min_value, max_value, markers, direction
        dial[i] = UI.Slider.new(x_sum,1,dial_width,20,program_data[i],0,127,{})
        dial[(i+program_width)] = UI.Slider.new(x_sum,22,dial_width,20,program_data[(i+program_width)],0,127,{})
        dial[(i+(program_width*2))] = UI.Slider.new(x_sum,43,dial_width,20,program_data[(i+(program_width*2))],0,127,{})
        i = i+1
end

function init()
    brightness = 14
    show = {x = 1, y = 1}
    grid_dirty = true -- initialize with a redraw
    screen_redraw()
    clock.run(grid_redraw_clock) -- start the grid redraw clock
    set_active_dials()
end

function grid_redraw_clock()
    while true do
        clock.sleep(1/30) -- refresh at 30fps.
        show.x = math.random(8)
        show.y = math.random(8)
        grid_redraw() -- redraw...
        if grid_dirty then -- if a redraw is needed...
            grid_redraw()
            grid_dirty = false -- then redraw is no longer needed.
        end
    end
end

function grid_redraw()
    g:all(0) -- turn off all the LEDs
    i = 1
    while( i < program_width )
        do
        g:led(a, active_draw_offset, brightness) -- light this coordinate at indicated brightness
        i = i+1
    end
    g:refresh() -- refresh the hardware to display the new LED selection
end

function screen_redraw()
    screen.clear()
    screen.fill()
    -- dials need to be redrawn to display:
    for i = 0,((program_width*3)-1) do
      dial[i]:redraw()
    end
    
    screen.level(15)

    screen.font_face(2)
    screen.font_size(6)
    
    screen.move(4,11)
    screen.text("A")

    screen.move(4,34)
    screen.text("B")

    screen.move(4,54)
    screen.text("C")
    
    screen.font_size(7)
    
    screen.move(0,17)
    screen.text("1v")

    screen.move(0,40)
    screen.text("5v")

    screen.move(0,60)
    screen.text("Cc")
    
    -- screen.move(0,50)
    -- screen.text(tostring(active_column))
  
    screen.move(107,14)
    screen.text(dial[active_column].value)
    
    screen.move(107,35)
    screen.text(dial[(active_column+program_width)].value)
    
    screen.move(107,56)
    screen.text(dial[(active_column+(program_width*2))].value)
  
    screen.update()
end

function g.key(x,y,z)
    if z==1 then
        show.x = x
        show.y = y
        grid_dirty = true
    end
end

function key(n,z)
  -- manipulating slider states + values:
  print(n)
  if n == 3 and z == 1 then
    active_column = active_column + 1
    if active_column >= program_width then 
      active_column = 0
    end
  end
  
  if n == 2 and z == 1 then
    active_column = active_column - 1
    if active_column < 0 then 
      active_column = (program_width - 1)
    end
  end

  set_active_dials()
  screen_redraw()
end

function enc(n,d)
    -- adjusting slider + marker values:
    if n == 1 then
      target = active_column
    elseif n == 2 then
      target = active_column + program_width
    elseif n == 3 then
      target = active_column + (program_width*2)
    end
    
    dial[target]:set_value_delta(d)  
    program_data[target] = dial[target].value

    screen_redraw()
end

function set_active_dials() 
  i = 0
  while( i < program_width )
    do
      if i == active_column then
        dial[i].active = true
        dial[(i+program_width)].active = true
        dial[(i+(program_width*2))].active = true
      else
        dial[i].active = false
        dial[(i+program_width)].active = false
        dial[(i+(program_width*2))].active = false
      end
       print(i)
        i = i+1
  end
end
