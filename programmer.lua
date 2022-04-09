-- Serge programmer
--                   1973 <> 2022
-- v0.1
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
-- Need: Grid
-- Advice: Crow or Midi
-- Docs: l.llllllll.co/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UI = require("ui")
g = grid.connect() -- 'g' === grid

---------
-- global
i = 0
shift = false
is_playing = false

last_edit = 0
program_width = 15
program_data = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,40,0,20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
program_functions = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
function_types = {'S','R','<','>','*','+','-'}

--ideas
-- forward
-- backwards
-- random
play_direction = 'forward'

edit_column = 0
active_column = 0

--grid
active_draw_offset = 8

-- Screen vars
dial_width = 5
x_sum = 3
dial = {}
show_edit = false
---------

while( i < program_width )
    do
        x_sum = x_sum + 6
        if i%4 == 0 then
            x_sum = x_sum + 1 --- add a extra space for each 4
        end
        --- x, y, width, height, value, min_value, max_value, markers, direction
        dial[i] = UI.Slider.new(x_sum,10,dial_width,18,program_data[i],0,127,{})
        dial[(i+program_width)] = UI.Slider.new(x_sum,29,dial_width,17,program_data[(i+program_width)],0,127,{})
        dial[(i+(program_width*2))] = UI.Slider.new(x_sum,47,dial_width,17,program_data[(i+(program_width*2))],0,127,{})
        i = i+1
end

function r() 
  norns.script.load(norns.state.script)
end

function init()
    brightness = 14
    show = {x = 1, y = 1}
    grid_dirty = true -- initialize with a redraw
    clock.run(grid_redraw_clock) -- start the grid redraw clock

    screen.aa(1)
    screen.line_width(1)

    set_active_dials()
    screen_redraw()

    -- clock.run doesn't always need to be pointed to external functions!
    -- here, we define a screen redraw coroutine inside of our clock.run:
    screen_redraw_clock = clock.run(
      function()
        while true do
          clock.sleep(1/30) -- 30 fps
          if screen_dirty == true then
            screen_redraw()
            screen_dirty = false
          end
        end
      end
    )
    
    step = 0
    screen_dirty = true
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

    lineSum = 10 + (6 * edit_column) + math.floor(edit_column / 4)
    screen.rect(lineSum, 28, 5, 1)
    screen.rect(lineSum, 46, 5, 1)
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
    x_sum=4
    screen.font_face(2)
    screen.font_size(8)
    while( i < program_width )
    do
        x_sum = x_sum + 6
        if i%4 == 0 then
            x_sum = x_sum + 1 --- add a extra space for each 4
        end

        if program_functions[i+1] > 0 then
          screen.move(x_sum,8)
          screen.text(getFunction(i, true))
        end
        
        i = i+1
    end

    if show_edit == true then
      screen.font_face(5)
      screen.font_size(20)
      screen.text_center_rotate(110,30, get_correct_value(edit_column, last_edit), 90)
    end

    if params:string("clock_source") == "internal" or params:string("clock_source") == "crow" then
      screen.font_size(10)
      screen.move(100,50)
      screen.level(15)
      screen.text(is_playing and "Start" or "Stop")
    end

    screen.update()
end

function getFunction(column, text)
  if program_functions[column+1] > 0 then
    if text then
      return tostring(function_types[program_functions[column+1]])
    else
      return program_functions[column+1]
    end
  end
end

function get_correct_value(column, row, text, type)
  typestring = ''
  if type == 'volt1' then
    typestring = 'V'
    value = dial[(column+(program_width*row))].value * 7.87401574803
  elseif type == 'volt5' then
    typestring = 'V'
    value = dial[(column+(program_width*row))].value * 39.3700787402
  elseif type == 'cc' then
    typestring = 'cc'
    value = dial[(column+(program_width*row))].value
  else
    value = dial[(column+(program_width*row))].value
  end
  
  if text == true then 
    return typestring .. tostring(value)
  else 
    return dial[(column+(program_width*row))].value
  end
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
    edit_column = edit_column + 1
    if edit_column >= program_width then 
      edit_column = 0
    end
  end
  
  if n == 2 and z == 1 then
    edit_column = edit_column - 1
    if edit_column < 0 then 
      edit_column = (program_width - 1)
    end
  end

  if n == 1 then
    if z == 1 then
      shift = true
    else 
      shift = false
    end
  end

  set_active_dials()
  screen_redraw()
end

function enc(n,d)
    -- adjusting slider + marker values:
    if shift then
      if n == 1 then
        -- change column function
        program_functions[edit_column+1] = program_functions[edit_column+1] + d
        if program_functions[edit_column+1] > 7 then
          program_functions[edit_column+1] = 7
        elseif program_functions[edit_column+1] < 0 then
          program_functions[edit_column+1] = 0
        end
      end
      if n == 2 then
        if is_playing then
          clock.transport.stop()
        else
          clock.transport.start()
        end
        screen_dirty = true
      end
    else   
      if n == 1 then
        target = edit_column
      elseif n == 2 then
        target = edit_column + program_width
      elseif n == 3 then
        target = edit_column + (program_width*2)
      end

      last_edit = (n-1)
      dial[target]:set_value_delta(d)  
      program_data[target] = dial[target].value
      show_edit = true
    end

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
      i = i+1
  end
end

-- define what should happen when the transport starts
function clock.transport.start()
  step = 0

  -- assign a variable to a coroutine allows it to be canceled later
  my_sequencer = clock.run(sequence)
  -- keep track of the transport state:
  is_playing = true

  screen_dirty = true
end

-- define what should happen when the transport stops
function clock.transport.stop()
  clock.cancel(my_sequencer)
  is_playing = false
end

-- this function loops until canceled by clock.transport.stop()
-- it advances the sequencer by one step every 1/16th note
function sequence()
  if params:string("clock_source") ~= "midi" then
    clock.sync(4) -- wait until the "1" of a 4/4 count
  end
  while true do
    step = util.wrap(step + 1,1,16)
    if step == 1 then print(clock.get_beats()) end
    active_column = active_column + 1

    if active_column > program_width then
      active_column = 0
    end
    set_active_dials()

    screen_dirty = true
    clock.sync(1/4) -- in 4/4, 1 beat is a quarter note, so sixteenths = 1/4 of a beat
  end
end
