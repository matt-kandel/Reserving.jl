using Reserving, DataFrames, Random, Distributions

# Using LogLogistic distribution
# see https://www.casact.org/sites/default/files/database/forum_03fforum_03ff041.pdf
simulate_LDF(θ, ω, x) = 1 + (θ / x)^ω

function simulate_trends(length::Int64)
    trend = rand(Normal(.05, .02))
    return (i -> (1 + trend)^i).(1:length)
end

function simulate_development_factors(length::Int64)
    θ = rand(Uniform(1, 1.5))
    ω = rand(Uniform(2, 3))  
    fake_LDFs = simulate_LDF.(θ, ω, 1:length)
    fake_CDFs = cumprod(fake_LDFs)[end:-1:1]

    # Normalize the CDFs so that the seed_value is unchanged
    return fake_CDFs ./ fake_CDFs[1]
end

function simulate_triangle(seed_value::Float64, trends::Vector{Float64}, 
                           development_factors::Vector{Float64})
    factors = trends * development_factors'

    # Need to change this line so that as development -> ultimate, noise -> zero
    noise = rand(Normal(1, .05), size(factors))
    simulated_triangle = seed_value .* factors .* noise
    reverse!(simulated_triangle, dims=2)
    return make_lower_right_missing(simulated_triangle)

end

function simulate_triangles(num_triangles::Number)
    fake_triangles = []
    for i in 1:num_triangles
        seed_value = rand(Uniform(100, 1000))
        trends = simulate_trends(30)
        development_factors = simulate_development_factors(30)
        triangle = simulate_triangle(seed_value, trends, development_factors)
        push!(fake_triangles, triangle)
    end

    return DataFrame(ID=1:num_triangles, triangle=fake_triangles)
end

# Simulates one million 30x30 triangles in 100 - 200 seconds
# (=900 million cells,
# or ~450 million non-missing cells)
# Around 2 million triangles, the program stops running fast
# So maybe you'd need to parallelize the code or host it on a DSVM
@time triangles = simulate_triangles(1e6)

# takes about 1 second to filter and sum every 13th triangle, subsequent is 330 ms
@time subset = filter(row -> mod(row.ID, 13) == 0, triangles)
@time sum(subset.triangle) # first run takes 8 seconds, subsequent are <1 second

# Demonstrating that a random triangle looks reasonable
using Plots
begin
    random_number = round(rand(Uniform(1, 1000000)), digits=0)
    random_triangle = filter(row -> row.ID == random_number, triangles)
    random_triangle = random_triangle.triangle[1]
    heatmap(random_triangle[end:-1:1, :])
end