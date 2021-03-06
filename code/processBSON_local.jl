using BSON  
using DataFrames
using DrWatson
using CSV
using StatsBase
using NLsolve 

datdir = joinpath("..", "data", "rawDat")
resdir = joinpath("..", "results")
# datdir = joinpath("..", "data")
# resdir = joinpath("..", "results")

files  = readdir(datdir)

function mortFun(n, x, y, B, multX, multY)
    calc = B*2.718^(-1 * (n)*((x*(n-1) + x)/n)) + multX*x^2 + multY*y^2
    return calc
end

rows=[]
fullDat = DataFrame(Dict(:ID => 0))
for i in 1:length(files)[1]
    testDat = 0
    try
        testDat = load(joinpath(datdir, files[i]))
    catch 
        println("failed to load ", files[i])
    end
    normF = testDat[:tF][:, 2:end]./sum(testDat[:tF][:, 2:end])
    nArray = repeat([i for i in 1:(testDat[:n]-1)]', testDat[:q])
    testDat[:avgR] = mean(testDat[:tR][:, 3:end])
    testDat[:tXr] = testDat[:tX][:, 2:end]
    testDat[:tYr] = testDat[:tY][:, 2:end]
    testDat[:tXw] = testDat[:tX][:, 2:end] .* normF
    testDat[:tYw] = testDat[:tY][:, 2:end] .* normF
    testDat[:tXi] = (testDat[:tX][:, 2:end] .* normF .*  nArray)./ sum(normF .* nArray)
    testDat[:tYi] = (testDat[:tY][:, 2:end] .* normF .*  nArray)./ sum(normF .* nArray)
    testDat[:groupAvgX] = sum(testDat[:tXw])
    testDat[:indAvgX] = sum(testDat[:tXi])
    testDat[:groupAvgY] = sum(testDat[:tYw])
    testDat[:indAvgY] = sum(testDat[:tYi])

    AnArray = nArray[:, 1]
    testDat[:AtXw] = testDat[:tXw][:, 1:1]
    testDat[:AtYw] = testDat[:tYw][:, 1:1]
    testDat[:AgroupAvgX] = sum(testDat[:AtXw])
    testDat[:AindAvgX] = sum(testDat[:AtXw] .*  AnArray)/ sum(normF .* nArray)
    testDat[:AgroupAvgY] = sum(testDat[:AtYw])
    testDat[:AindAvgY] = sum(testDat[:AtYw] .*  AnArray)/ sum(normF .* nArray)

    SnArray = nArray[:, 2:end]
    testDat[:StXw] = testDat[:tX][:, 3:end] .* normF[:, 2:end]
    testDat[:StYw] = testDat[:tY][:, 3:end] .* normF[:, 2:end]
    testDat[:SgroupAvgX] = sum(testDat[:StXw])
    testDat[:SindAvgX] = sum(testDat[:StXw] .*  SnArray)/ sum(normF .* nArray)
    testDat[:SgroupAvgY] = sum(testDat[:StYw])
    testDat[:SindAvgY] = sum(testDat[:StYw] .*  SnArray)/ sum(normF .* nArray)

    testDat[:avgMort] = mean(mortFun.(nArray, testDat[:tX][:,2:end], testDat[:tY][:,2:end], testDat[:basem], testDat[:multX], testDat[:multY]))
    testDat[:relW] = testDat[:tW]./mean(testDat[:tW])
    testDat[:rWi] = (testDat[:relW][:, 2:end] .* normF .*  nArray)./ sum(normF .* nArray)
    testDat[:mWi] = mean(testDat[:rWi])
    testDat[:meanFit] = mean(testDat[:relW][:, 2:end])
    testDat[:fit1] = mean(testDat[:relW][:, 2])
    testDat[:fit2] = mean(testDat[:relW][:, 3])
    testDat[:qVal] = mean(mapslices(diff, testDat[:relW], dims=1))
    testDat[:qVar] = StatsBase.var(mapslices(sum, testDat[:tF], dims=2))
    testDat[:totFreq] = sum(testDat[:tF])
    testDat[:occupancy] = sum(testDat[:tF][:, 2:end])
    testDat[:popSize] = sum(testDat[:tF][:, 2:end].*nArray)
    testDat[:collapsed] = isapprox(sum(testDat[:tF][:, 1]), 1; atol=1E-6) 
    testDat[:fixed] = string(testDat[:fixed]...) 
    testDat[:fightNum] = sum(testDat[:epsilon].*kron(testDat[:tF], testDat[:tF]))
    tempDict = Dict{Symbol, Any}(:ID=>i)
    for (key, val) in testDat
        # println(key)
        if !isa(val, Array)
            tempDict[key] = val 
        else 
            for q in 1:size(val)[1]
                for n in 1:size(val)[2]
                    tempDict[Symbol(key, q, n)] = val[q, n]
                    tempDict[:tn] = n 
                    tempDict[:tq] = q
                end
            end
        end
    end
    save(joinpath(resdir, string(tempDict[:ID], ".bson")), tempDict)
        # rowDat = DataFrame(;tempDict...)
    # global fullDat = outerjoin(fullDat, rowDat, on = names(rowDat))
    # append!(fullDat, rowDat)
    # push!(rows, rowDat)
end

# make CSV 
df = collect_results(resdir)
CSV.write(joinpath(resdir, ARGS[1]), df)
