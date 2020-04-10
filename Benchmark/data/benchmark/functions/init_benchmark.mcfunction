scoreboard objectives remove BenchStats
scoreboard objectives add const dummy
scoreboard objectives add BenchStats dummy
scoreboard players set 10 const 10
scoreboard players set 100 const 100
scoreboard players set 50000 const 50000
scoreboard players set 100000 const 100000
#target should be < 50ms to prevent server from lagging and possibly crashing and > 0ms to allow the pack to work
#larger values will cause scores to be worse because of recursion loop overhead
#smaller values will be more noisy since less instances are being averaged over
#suggested range is 10ms to 40ms
#other programs running in the background may effect scores if they take up significant CPU time
#this typically shows up as significant fluctuations in the numbers
#can be set in game with a similar command as below
scoreboard players set tickTarget BenchStats 25

scoreboard objectives setdisplay sidebar BenchStats
function benchmark:reset