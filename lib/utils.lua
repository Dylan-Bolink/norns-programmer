-- Maps a number from one range to another:
-- [in_min, in_max] -> [out_min, out_max]
function map(x, in_min, in_max, out_min, out_max)
	return out_min + (x - in_min)*(out_max - out_min)/(in_max - in_min)
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

function playToggle()
    if is_playing then
        clock.transport.stop()
    else
        clock.transport.start()
    end
end

function checkFunctionState()
    if program_functions[active_column + 1] == 1 then
        playToggle()
    elseif program_functions[active_column + 1] == 6 then
        direction = -1
        random = false
    elseif program_functions[active_column + 1] == 5 then
        direction = 1
        random = false
    elseif program_functions[active_column + 1] == 7 then
        if  direction == 1 then
            direction = -1
        else 
            direction = 1
        end
        random = false
    elseif program_functions[active_column + 1] == 8 then
        random = true
    end
end