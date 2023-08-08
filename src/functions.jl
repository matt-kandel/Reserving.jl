using Plots

# I would rather do: Triangle = Matrix{Union{Missing, Number}} but it doesn't work
# for the same strange reason that the line below returns false
# Matrix{Union{Missing, Float64}} <: Matrix{Union{Missing, Number}}
Triangle = Union{Matrix{Union{Int64, Missing}}, Matrix{Union{Float64, Missing}}}

function latest_diagonal(triangle::Triangle)
    # Copied from https://github.com/JuliaActuary/ChainLadder.jl/blob/master/src/utils.jl
    return [row[findlast(x -> !ismissing(x), row)] for row in eachrow(triangle)]
end

function LDFs(triangle::Triangle)
    # Returns a Triangle of Loss Development Factors
    # with one less column than original data
    return triangle[:, 2:end] ./ triangle[:, 1:end-1]
end

function get_latest_three_year_LDFs(triangle::Triangle)

    # Create first, second, and third LDFs, where you have <3 data points
    third = sum(triangle[1:2, end-1:end-1]) / sum(triangle[1:2, end-2:end-2])
    second = triangle[1, end] / triangle[1, end-1]
    first = second

    three_year_sum = triangle[1:end-2, :] .+ triangle[2:end-1, :] .+ triangle[3:end, :]
    three_year_LDFs = LDFs(three_year_sum)

    # Remove last row (all missing values)
    three_year_LDFs = three_year_LDFs[1:end-1, :]

    latest_three_year_LDFs = latest_diagonal(three_year_LDFs)

    return vcat(first, second, third, latest_three_year_LDFs)

end

function YOYs(triangle::Triangle)
    # Returns a Triangle of Year-on-Year Changes 
    # with one less row than original data 
    return triangle[2:end, :] ./ triangle[1:end-1, :]
end

function column_averages(triangle::Triangle)
    col_sum(col) = sum(x for x in col if !ismissing(x))
    col_count(col) = sum(1 for x in col if !ismissing(x))
    return [col_sum(col) ./ col_count(col) for col in eachcol(triangle)]
end

function CDFs(triangle::Triangle, tail_factor::Number=1.0)
    ldfs = LDFs(triangle)
    average_ldfs = column_averages(ldfs)
    
    # including a tail factor will ensure that cdfs will have the right length
    push!(average_ldfs, tail_factor)

    # reverse the order to appropriately match the losses later
    cdfs = cumprod(average_ldfs[end:-1:1])
    return cdfs
end

function chainladder_ultimates(triangle::Triangle, tail_factor::Number=1.0)
    cdfs  = CDFs(triangle, tail_factor)
    diagonal = latest_diagonal(triangle)
    return diagonal .* cdfs
end

function born_ferg_ultimates(triangle::Triangle, premiums::Vector{Float64},
                             expected_claims_ratio::Number, tail_factor::Number=1.0)

    cdfs  = CDFs(triangle, tail_factor)
    diagonal = latest_diagonal(triangle)
    return diagonal + premiums .* expected_claims_ratio .* (1 .- 1 ./ cdfs)
end

function cape_cod_ultimates(triangle::Triangle, on_level_earned_premiums::Vector{Float64})
    cdfs = CDFs(triangle)
    diagonal = latest_diagonal(triangle)
    used_up_premium = on_level_earned_premiums ./ cdfs
    expected_claims_ratio = sum(diagonal) / sum(used_up_premium)
    return born_ferg_ultimates(triangle, on_level_earned_premiums, expected_claims_ratio)
end

 # Temporarily removed type annotation ::Triangle below
 # because Matrix{Float64} is not a subtype of Matrix{Union{Float64, Missing}}
function make_lower_right_missing(triangle)
    height, width = size(triangle)
    lower_right_missing_matrix = [x <= y ? 1 : missing for x ∈ 1:height, y ∈ width:-1:1]
    return triangle .* lower_right_missing_matrix
end

function make_heatmap(triangle::Triangle)

    # Check this out -- It would be nice to add text
    # https://discourse.julialang.org/t/annotations-and-line-widths-in-plots-jl-heatmaps/4259
    # Then maybe I could rename this to display() or something like that

    col_maxs = [maximum(x for x in col if !ismissing(x)) for col in eachcol(triangle)]
    col_mins = [minimum(x for x in col if !ismissing(x)) for col in eachcol(triangle)]

    # https://en.wikipedia.org/wiki/Feature_scaling#Rescaling_(min-max_normalization)
    # It's probably better to use a Normal distribution
    # But I stuck with min-max normalization for now because that's the default in Excel
    function rescale(x, max, min)
        # If there's a column with only one entry, just set it at the midpoint
        if !ismissing(x) && max == min
            return 0.5
        else
            return (x - min) / (max - min)
        end
    end

    normalized_triangle = rescale.(triangle, transpose(col_maxs), transpose(col_mins))
    
    return Plots.heatmap(normalized_triangle[end:-1:1, :],
                         c=cgrad([:red, :yellow, :green], [0.5]),
                         legend=false, xticks=false, yticks=false, border=:none)
end

function berquist_sherman_disposal(counts::Triangle, ultimates::Vector{Float64})

    # the disposal diagonal needs to be in reverse order
    disposal_diagonal = (latest_diagonal(counts) ./ ultimates)[end:-1:1]
    counts = make_lower_right_missing(counts)
    adjusted_counts = ultimates * disposal_diagonal'
    return make_lower_right_missing(adjusted_counts)
end

function berquist_sherman_paid(counts::Triangle, paid::Triangle,
                               ultimates::Vector{Float64})

    adjusted_counts = berquist_sherman_disposal(counts, ultimates)
    return paid .* adjusted_counts ./ counts
end

"""Takes in a triangle of case reserves, takes the latest diagonal, and applies
severity trend backwards in time. Returns the adjusted case reserves triangle.
"""
function berquist_sherman_case(case::Triangle, severity_trend::Float64)

    height, width = size(case)
    if height != width
        error("Must use square matrices!")
    end

    diagonal = latest_diagonal(case)
    severity_trends = [(1 + severity_trend) ^ (height + 1 - (x + y)) for x ∈ 1:height, y ∈ 1:height]
    adjusted_case = diagonal .* severity_trends
    return make_lower_right_missing(adjusted_case)
end