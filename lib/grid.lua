g = grid.connect() -- 'g' === grid

max_brightness = 8
function_type = 0
hold_grid = 0

function_down = false

function led_slider(data, top, bottom, left)
    if data >= 64 then
        g:led(left, top, math.ceil(map((data-64), 0, 64, 0, max_brightness)))
        g:led(left, bottom, max_brightness)
    else
        g:led(left, top, 0)
        g:led(left, bottom, math.ceil(map(data, 0, 64, 0, max_brightness)))
    end
end

function grid_redraw()
    g:all(0) -- turn off all the LEDs
    if function_down then
        for i = 1,(program_width) do
            for y = 1,6 do
                if i % 4 == 0 then
                    g:led(i, y, program_functions[i] >= 1 and 16 or 2) 
                else 
                    g:led(i, y, program_functions[i] >= 1 and 14 or 0) 
                end
            end
        end
    else
        for i = 1,(program_width) do
            --- A
            led_slider(program_data[i], 1, 2, i)
            --- B
            led_slider(program_data[i+max_program_width], 3, 4, i)
            --- C
            led_slider(program_data[i+(max_program_width*2)], 5, 6, i)
        end
    end

    for i = 1,(program_width) do
        g:led(i, 8,i == (active_column + 1) and 12 or 3) 
    end

    -- function keys
    g:led(15, 1, function_type == 1 and 5 or 3)
    g:led(16, 1, function_type == 2 and 5 or 3)
    
    g:led(15, 2, function_type == 3 and 5 or 3)
    -- g:led(16, 2, function_type == 4 and 5 or 3)

    g:led(15, 3, function_type == 5 and 5 or 3)
    g:led(16, 3, function_type == 6 and 5 or 3)
    
    g:led(15, 4, function_type == 7 and 5 or 3)
    g:led(16, 4, function_type == 8 and 5 or 3)

    g:led(15, 5, function_type == 9 and 5 or 3)
    g:led(16, 5, function_type == 10 and 5 or 3)

    g:led((edit_column + 1), 7, 4) 
    g:led(16, 8, is_playing and 8 or 4) 
    g:refresh() -- refresh the hardware to display the new LED selection
end


function g.key(x,y,z)
    print(z)
    if z == 1 then -- if a key is pressed...
        if function_down then
            if x <= program_width and y <= 6 then
                program_functions[x] = function_type
            end
        else
            if y == 1 and x <= program_width then
                screen_delay = 0
                last_edit = 0
                dial[x-1]:set_value_delta(1)  
                program_data[x-1] = dial[x-1].value
                show_edit = true
                screen_dirty = true

                hold_grid = 1
        
            elseif y == 2 and x <= program_width then
                screen_delay = 0
                last_edit = 0
                dial[x-1]:set_value_delta(-1)  
                program_data[x-1] = dial[x-1].value
                show_edit = true
                screen_dirty = true
            end
        end

        if y == 7 and x <= program_width then
            edit_column = x - 1

            print(edit_column)

        elseif y == 8 and x <= program_width then
            active_column = x - 1
            last_pressed_column = x - 1

            checkFunctionState()
        elseif x == 15 and y == 1 then
            function_down = true
            function_type = 1
        elseif x == 16 and y == 1 then
            function_down = true
            function_type = 2

        elseif x == 15 and y == 2 then
            function_down = true
            function_type = 3
        -- elseif x == 16 and y == 2 then
        --     function_down = true
        --     function_type = 4
        
        elseif x == 15 and y == 3 then
            function_down = true
            function_type = 5
        elseif x == 16 and y == 3 then
            function_down = true
            function_type = 6
        elseif x == 15 and y == 4 then
            function_down = true
            function_type = 7
        elseif x == 16 and y == 4 then
            function_down = true
            function_type = 8

        elseif x == 15 and y == 5 then
            function_down = true
            function_type = 9
        elseif x == 16 and y == 5 then
            function_down = true
            function_type = 10
        
        elseif y == 8 and x == 16 then
            playToggle()
        end
    
    elseif z == 0 then
        hold_grid = 0
        if x == 15 or 16 and y == 1 or 2 or 4 or 5 then
            function_down = false
            function_type = 0
        end
    end

    grid_redraw() -- redraw the grid
end