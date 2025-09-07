import HTTP
import StatsBase
import JSON
using Printf
using Dates
using Statistics

println("cheatstats.jl, running on $(Threads.nthreads()) threads")

function daystamp()
	q = now()
	day(q)-1 + 31*(month(q)-1 + 12*year(q))
end

function mkquery(typ, args...)
    return JSON.parse(String(HTTP.get("https://codeforces.com/api/$typ"; query=args).body))["result"]
end

function queryusr(handle)
    try
        return mkquery("user.info", "handles" => handle)[1]
    catch
        println("Oops! Call limit exceeded on thread $(Threads.threadid()). Wait a minute...")
        sleep(60)
        queryusr(handle)
    end
end

cheaters = string.(JSON.parse(String(HTTP.get("https://raw.githubusercontent.com/macaquedev/cf-cheater-highlighter/refs/heads/main/cheaters.json").body))["cheaters"])

active = mkquery("user.ratedList")
active_handles = [w["handle"] for w ∈ active if "country" ∈ keys(w)]
tally_ac = StatsBase.countmap([w["country"] for w ∈ active if "country" ∈ keys(w)])

ctry_data = readlines("ctry.txt")
ds = parse(Int, ctry_data[1])
dy = 1+ds%31
mh = 1+(ds÷31)%12
yr = ds÷372
cheat_ctrys = ctry_data[2:end]

print("Get fresh list of cheaters? (last retrieval: $(@sprintf("%04d-%02d-%02d", yr, mh, dy))) (y/n) ")
answer = readline()

if lowercase(answer[1]) == 'y'
    cheat_ctrys = []
    open("rate.txt", "w") do g
        open("ctry.txt", "w") do f
            println(f, daystamp())
            for (i, v) ∈ enumerate(cheaters)
                println("$(lpad(v, maximum(length.(cheaters)))) $(@sprintf("%6.2f", 100*i/length(cheaters)))")
                dat = queryusr(v)
                "country" ∈ keys(dat) && push!(cheat_ctrys, dat["country"])
                "country" ∈ keys(dat) && println(f, dat["country"])
                "rating" ∈ keys(dat) && println(g, dat["rating"])
                sleep(0.1)
            end
        end
    end
end
tally_cc = StatsBase.countmap(cheat_ctrys)

x = []
q = zeros(Int, 40)
open("rate.dat", "w") do f
    global x = parse.(Int, readlines("rate.txt"))
    for i ∈ x; q[(i+50)÷100] += 1; end
    for (i, v) ∈ enumerate(q); println(f, "$(100i) $v 100.0 $(100i)"); end
end

rat_ac = Dict(keys(tally_ac) .=> values(tally_ac) ./ sum(values(tally_ac)))
rat_cc = Dict(keys(tally_cc) .=> values(tally_cc) ./ sum(values(tally_cc)))

sat = [i => rat_cc[i] / rat_ac[i] for i ∈ keys(rat_cc) if tally_cc[i] ≥ 5]
sort!(sat; by=last, rev=true)

open("stats.txt", "w") do f
    maxc = maximum(length.(first.(sat)))
    maxd = maximum(ndigits.(values(tally_cc)))
    maxg = length(@sprintf("%.6f", maximum(last.(sat))))
    for (i, v) ∈ sat
        @printf(f, "%-*s | %*d: %6.2f%% | %6.2f%% | %*.6f\n", maxc, i, maxd, tally_cc[i], 100*rat_cc[i], 100*rat_ac[i], maxg, v)
    end

    println(f, "\nRelative to minimum rate: ")
    maxf = length(@sprintf("%.6f", maximum(last.(sat))/minimum(last.(sat))))
    for (i, v) ∈ sat
        @printf(f, "%-*s | %*d: %6.2f%% | %6.2f%% | %*.6f\n", maxc, i, maxd, tally_cc[i], 100*rat_cc[i], 100*rat_ac[i], maxf, v/minimum(last.(sat)))
    end
    println(f, "--- Table styled chart ---")
    for (i, v) ∈ sat
        @printf(f, "| %s | %d: %.2f%% | %.2f%% | %.6f |\n", i, tally_cc[i], 100*rat_cc[i], 100*rat_ac[i], v)
    end
    println(f)
    for (i, v) ∈ sat
        @printf(f, "| %s | %d: %.2f%% | %.2f%% | %.6f |\n", i, tally_cc[i], 100*rat_cc[i], 100*rat_ac[i], v/minimum(last.(sat)))
    end
    println(f, "--- Rating statistics ---")
    μ = mean(x); σ = std(x)
    println(f, "μ = $μ, σ = $σ ⇒ cv = $(100σ/μ)%")
    lo, hi = extrema(x)
    println(f, "data range is $lo ~ $hi: μ+[$((lo-μ)/σ), $((hi-μ)/σ)]σ")
    println(f, "median = $(median(x))")
end

open("ms.dat", "w") do f
    μ = mean(x); σ = std(x)
    println(f, "$μ $σ $(maximum(q))")
end
