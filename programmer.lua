-- Programmer
--        a love letter to serge
--
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
-- need help?
-- please visit:
-- l.llllllll.co/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
g = grid.connect() -- 'g' === grid


---------
program_width = 7
a_program = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
b_program = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
c_program = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

a_draw_offset = 1
b_draw_offset = 3
c_draw_offset = 5
active_draw_offset = 8
---------

function init()
    brightness = 14
    show = {x = 1, y = 1}
    grid_dirty = true -- initialize with a redraw
    clock.run(grid_redraw_clock) -- start the grid redraw clock
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

function g.key(x,y,z)
    if z==1 then
        show.x = x
        show.y = y
        grid_dirty = true
    end
end

function enc(n,d)
    if n==3 then
        brightness = util.clamp(brightness + d,0,15)
        grid_dirty = true 
    end
end
