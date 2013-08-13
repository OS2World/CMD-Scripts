/* Master Of Magic city spy by cygnus, 2:463/62.32 */
/* Tested with MOM v2.3 */

parse arg game
game = strip(game)
if game = '' then game = 'save1.gam'
if charin(game, 4) = '10'x then do
    offs=x2d(8aac)+1
    i = 0
    do while city <> '00'x
        city = Charin(game, offs, 14)
        city = substr(city, 1, pos(x2c(00), city))
        call charout , '0d0a0d0a'x city
        pop = c2d(charin(game, offs+20))
        race = c2d(charin(game, offs+14))
        if race <> '' & city <> '00'x then do
            call charout ,'    '||'09'x pop
            select
                when race = 0 then say '09'x'Barbarian'
                when race = 1 then say '09'x'Beastmen'
                when race = 2 then say '09'x'Dark Elf'
                when race = 3 then say '09'x'Draconian'
                when race = 4 then say '09'x'Dwarven'
                when race = 5 then say '09'x'Gnoll'
                when race = 6 then say '09'x'Halfling'
                when race = 7 then say '09'x'High Elf'
                when race = 8 then say '09'x'High Men'
                when race = 9 then say '09'x'Klackon'
                when race = 10 then say '09'x'Lizardman'
                when race = 11 then say '09'x'Nomad'
                when race = 12 then say '09'x'Orc'
                when race = 13 then say '09'x'Troll'
                otherwise say 'Incorrect index'
            end
            call charout ,'Has: '
            if charin(game, offs+34) = '01'x then call charout ,'Barracks; '
            if charin(game, offs+35) = '01'x then call charout ,'Armory; '
            if charin(game, offs+36) = '01'x then call charout ,'Fighters guild; '
            if charin(game, offs+37) = '01'x then call charout ,'Armorers Guild; '
            if charin(game, offs+38) = '01'x then call charout ,'War College; '
            if charin(game, offs+39) = '01'x then call charout ,'Smithy; '
            if charin(game, offs+40) = '01'x then call charout ,'Stables; '
            if charin(game, offs+41) = '01'x then call charout ,'Animist Guild; '
            if charin(game, offs+42) = '01'x then call charout ,'Fantastic Stable; '
            if charin(game, offs+43) = '01'x then call charout ,'Ship Wrights Guild; '
            if charin(game, offs+44) = '01'x then call charout ,'Ship Yard; '
            if charin(game, offs+45) = '01'x then call charout ,'Maritime Guild; '
            if charin(game, offs+46) = '01'x then call charout ,'Sawmill; '
            if charin(game, offs+47) = '01'x then call charout ,'Library; '
            if charin(game, offs+48) = '01'x then call charout ,'Sages Guild; '
            if charin(game, offs+49) = '01'x then call charout ,'Oracle; '
            if charin(game, offs+50) = '01'x then call charout ,'Alchemist Guild; '
            if charin(game, offs+51) = '01'x then call charout ,'University; '
            if charin(game, offs+52) = '01'x then call charout ,'Wizards Guild; '
            if charin(game, offs+53) = '01'x then call charout ,'Shrine; '
            if charin(game, offs+54) = '01'x then call charout ,'Temple; '
            if charin(game, offs+55) = '01'x then call charout ,'Parthenon; '
            if charin(game, offs+56) = '01'x then call charout ,'Cathedral; '
            if charin(game, offs+57) = '01'x then call charout ,'Marketplace; '
            if charin(game, offs+58) = '01'x then call charout ,'Bank; '
            if charin(game, offs+59) = '01'x then call charout ,'Merchants Guild; '
            if charin(game, offs+60) = '01'x then call charout ,'Granary; '
            if charin(game, offs+61) = '01'x then call charout ,'Farmers Market; '
            if charin(game, offs+62) = '01'x then call charout ,'Foresters Guild; '
            if charin(game, offs+63) = '01'x then call charout ,'Builders Hall; '
            if charin(game, offs+64) = '01'x then call charout ,'Mershants Guild; '
            if charin(game, offs+65) = '01'x then call charout ,'Miners Guild; '
            if charin(game, offs+66) = '01'x then call charout ,'City Wall; '
        end
        offs = offs + 114
        i = i + 1
    end
    say
    say i-1 'cities found'
end
else say 'Incorrect save game'
exit
