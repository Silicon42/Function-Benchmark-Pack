#keep a running total of the number of instances in the last 5 seconds for fast averages and use in later calculations
#the average is useful for approximating how many times the operation can be run within the target time (larger is better)
#this is done early so we can retrieve the value later and prevent some recursion overhead
execute store result score #lastInst BenchStats run data get storage benchmark: Instances[-1]
data remove storage benchmark: Instances[-1]
scoreboard players operation #instTotal BenchStats -= #lastInst BenchStats
#execute store can't create new indexes in an array, so we need to create one before storing
data modify storage benchmark: Instances prepend value 0
execute store result storage benchmark: Instances[0] int 1 run scoreboard players get #instances BenchStats
scoreboard players operation #instTotal BenchStats += #instances BenchStats
#calculate the average of the last 5 seconds
scoreboard players operation avgInstances BenchStats = #instTotal BenchStats
scoreboard players operation avgInstances BenchStats /= 100 const

#using moving world border to determine real world tick times in ms
#this is the bit that acts as the so called wall clock
worldborder set 60000000
worldborder set 59999000 1

#recursively calls instances of the function to be tested
function benchmark:instanceloop

#get the time the tick took to finish
execute store result score #borderSize BenchStats run worldborder get
scoreboard players set #tickTime BenchStats 60000000
scoreboard players operation #tickTime BenchStats -= #borderSize BenchStats

#keep a running total of the tick times in the last 5 seconds for use in later calculations
execute store result score #lastTime BenchStats run data get storage benchmark: TickTimes[-1]
data remove storage benchmark: TickTimes[-1]
scoreboard players operation #timeTotal BenchStats -= #lastTime BenchStats
#execute store can't create new indexes in an array, so we need to create one before storing
data modify storage benchmark: TickTimes prepend value 0
execute store result storage benchmark: TickTimes[0] int 1 run scoreboard players get #tickTime BenchStats
scoreboard players operation #timeTotal BenchStats += #tickTime BenchStats

#calculate 10ns/instance, needed to calculate the step size to speed up benchmarking
#attempting to use finer resolution, may overflow the scoreboard on multiplication
scoreboard players operation #10nsPerInst BenchStats = #timeTotal BenchStats
#scaled up to prevent too much precision loss since time/instance can be < 1ms and divide by 0 is bad
scoreboard players operation #10nsPerInst BenchStats *= 100000 const
scoreboard players operation #10nsPerInst BenchStats /= #instTotal BenchStats

#calculate and apply step size: #stepSize = (target-ticktime)/(2*time_per_instance)
scoreboard players operation #stepSize BenchStats = tickTarget BenchStats
scoreboard players operation #stepSize BenchStats -= #tickTime BenchStats
#scaled up because time/instance had to be scaled up (100000/2)
scoreboard players operation #stepSize BenchStats *= 50000 const
scoreboard players operation #stepSize BenchStats /= #10nsPerInst BenchStats
#restore instance number for comparison/math
execute store result score #instances BenchStats run data get storage benchmark: Instances[0]
scoreboard players operation #instances BenchStats += #stepSize BenchStats
#prevent #instances from going below the minimum value of 1
#this can happen in the case that the CPU was busy with another process and caused a spike in the time taken
execute if score #instances BenchStats matches ..0 run scoreboard players set #instances BenchStats 1

#keep a running total of nsPerInst in the last 5 seconds for fast averages
#the average is useful for approximating how long an operation took (lower is better)
execute store result score #last10nsPI BenchStats run data get storage benchmark: 10nsPerInst[-1]
data remove storage benchmark: 10nsPerInst[-1]
scoreboard players operation #10nsPITotal BenchStats -= #last10nsPI BenchStats
#execute store can't create new indexes in an array, so we need to create one before storing
data modify storage benchmark: 10nsPerInst prepend value 0
execute store result storage benchmark: 10nsPerInst[0] int 1 run scoreboard players get #10nsPerInst BenchStats
scoreboard players operation #10nsPITotal BenchStats += #10nsPerInst BenchStats
#calculate the average of the last 5 seconds
scoreboard players operation avgNsPerInst BenchStats = #10nsPITotal BenchStats
scoreboard players operation avgNsPerInst BenchStats /= 10 const

#calculate the trend of the time per instance of the past 5 seconds to display to the user
#trend is an average of the last 5s in the difference between how long an instance took this tick vs the previous tick
#this is useful for telling when the benchmark is stable/done (when it approaches 0)
scoreboard players operation #trendDiff BenchStats = #10nsPerInst BenchStats
scoreboard players operation #trendDiff BenchStats -= #prev10nsPI BenchStats
scoreboard players operation #prev10nsPI BenchStats = #10nsPerInst BenchStats
execute store result score #lastTrendDiff BenchStats run data get storage benchmark: TrendDiff[-1]
data remove storage benchmark: TrendDiff[-1]
scoreboard players operation #trendTotal BenchStats -= #lastTrendDiff BenchStats
data modify storage benchmark: TrendDiff prepend value 0
execute store result storage benchmark: TrendDiff[0] int 1 run scoreboard players get #trendDiff BenchStats
scoreboard players operation #trendTotal BenchStats += #trendDiff BenchStats
scoreboard players operation TPI_Trend BenchStats = #trendTotal BenchStats
scoreboard players operation TPI_Trend BenchStats /= 100 const