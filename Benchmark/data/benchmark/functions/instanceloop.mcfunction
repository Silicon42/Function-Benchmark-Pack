#CALL FUNCTION/COMMAND TO BE BENCHMARKED HERE


#increments #depth and calls next iteration of loop if #depth < #instances
scoreboard players remove #instances BenchStats 1
execute if score #instances BenchStats matches 1.. run function benchmark:instanceloop