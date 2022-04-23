-- Serge programmer
--                   1973 <> 2022
-- v0.1
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
-- Need: Grid
-- Advice: Crow or Midi
-- Docs: l.llllllll.co/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UI = require("ui")
include("lib/utils")
include("lib/screen")
include("lib/grid")

---------
-- global
i = 0
shift = false
is_playing = false
random = false

last_edit = 0
direction = 1
program_width = 13
max_program_width = program_width
-- program_data = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
program_data = {math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), math.random(0, 127), 0}

-- program_data = {127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,0}
program_functions = {0,0,0,0,4,0,0,0,3,0,0,0,0,0,0}
function_types = {'P', 'R', 'S', '.', '>', '<', 'X', '?', '+', '-'}

edit_column = 0
edit_column_array = 0
active_column = 0
last_pressed_column = active_column

-- Sliders
while( i < program_width )
    do
        x_sum = x_sum + 7
        if i%4 == 0 then
            x_sum = x_sum + 1 --- add a extra space for each 4
        end
        --- x, y, width, height, value, min_value, max_value, markers, direction
        dial[i] = UI.Slider.new(x_sum,10,dial_width,18,program_data[(i+1)],0,127,{})
        dial[(i+max_program_width)] = UI.Slider.new(x_sum,29,dial_width,17,program_data[((i+1)+max_program_width)],0,127,{})
        dial[(i+(max_program_width*2))] = UI.Slider.new(x_sum,47,dial_width,17,program_data[((i+1)+(max_program_width*2))],0,127,{})
        i = i+1
end

-- Playback icon
-- 1 is play, 2 is reverse play, 3 is pause, 4 is stop.
playicon = UI.PlaybackIcon.new(120,55,4,play_index)

function r() 
  norns.script.load(norns.state.script)
end

function init()
    brightness = 14
    show = {x = 1, y = 1}
    grid_dirty = true -- initialize with a redraw

    screen.aa(1)
    screen.line_width(1)

    set_active_dials()
    screen_redraw()

    general_clock = clock.run(
      function()
        while true do
          clock.sleep(1/30) -- 30 fps
          if screen_dirty == true then
            screen_redraw()
            grid_redraw()
            screen_dirty = false
          end

          if screen_delay < 50 then
            screen_delay = screen_delay + 1
          elseif screen_delay >= 50 then
            screen_redraw()
          end

          -- if hold_grid >= 1 then
          --   print(hold_grid)
          --   hold_grid = hold_grid + 1


          -- end
        end
      end
    )
    
    step = 0
    screen_dirty = true
end


function key(n,z)
  -- manipulating slider states + values:
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
  screen_dirty = true
end

function enc(n,d)
    -- adjusting slider + marker values:
    if shift then
      if n == 1 then
        -- change column function
        program_functions[edit_column+1] = program_functions[edit_column+1] + d
        if program_functions[edit_column+1] > 10 then
          program_functions[edit_column+1] = 10
        elseif program_functions[edit_column+1] < 0 then
          program_functions[edit_column+1] = 0
        end
      end

      if n == 3 then
        program_width = program_width + d
        if program_width < 1 then
          program_width = 1
        elseif program_width >= max_program_width then
          program_width = max_program_width
        end

        if edit_column >= program_width then
          edit_column = edit_column - 1
        end
      end
    else   
      if n == 1 then
        target = edit_column
      elseif n == 2 then
        target = edit_column + max_program_width
      elseif n == 3 then
        target = edit_column + (max_program_width*2)
      end
      
      screen_delay = 0
      last_edit = (n-1)
      dial[target]:set_value_delta(d)  
      program_data[(target+1)] = dial[target].value
      show_edit = true
    end

    screen_dirty = true
end

function set_active_dials() 
  i = 1
  while( i < max_program_width )
    do
      if i == active_column then
        dial[i].active = true
        dial[(i+max_program_width)].active = true
        dial[(i+(max_program_width*2))].active = true
      else
        dial[i].active = false
        dial[(i+max_program_width)].active = false
        dial[(i+(max_program_width*2))].active = false
      end
      i = i+1
  end
end

-- define what should happen when the transport starts
function clock.transport.start()
  step = 0
  play_index = 1

  my_sequencer = clock.run(sequence)
  is_playing = true

  screen_dirty = true
end

-- define what should happen when the transport stops
function clock.transport.stop()
  clock.cancel(my_sequencer)
  play_index = 3
  is_playing = false
end

-- this function loops until canceled by clock.transport.stop()
-- it advances the sequencer by one step every 1/16th note
function sequence()
  if params:string("clock_source") ~= "midi" then
    clock.sync(1) -- wait until the "1" of a 4/4 count
  end
  while true do
    step = util.wrap(step + 1,1,16)
    if step == 1 then print(clock.get_beats()) end

      -- function_types = {'S','R','<','>','*','+','-'}
      -- P R S . > < X * + -

    if program_functions[active_column + 1] == 2 then
      active_column = last_pressed_column
    else
      if random then 
        active_column = math.random(0, program_width)
      else
        active_column = active_column + direction
      end
      
      if active_column > program_width then
        active_column = last_pressed_column
      elseif active_column < 0 then
        active_column = program_width
      end
    end

    checkFunctionState()
    set_active_dials()

    screen_dirty = true
    clock.sync(1/4) -- in 4/4, 1 beat is a quarter note, so sixteenths = 1/4 of a beat
  end
end
