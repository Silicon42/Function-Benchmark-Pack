scoreboard players add #depth BenchStats 1
data modify storage benchmark: TickTimes prepend value 0
execute store result storage benchmark: TickTimes[0] int 1 run scoreboard players get tickTarget BenchStats
execute if score #depth BenchStats matches ..99 run function benchmark:ticktime_init