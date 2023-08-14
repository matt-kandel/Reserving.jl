using Plots

function latest_diagonal(◤::AbstractArray)
    # Copied from https://github.com/JuliaActuary/ChainLadder.jl/blob/master/src/utils.jl
    return [row[findlast(x -> !ismissing(x), row)] for row in eachrow(◤)]
end

"""LDFs will have one less column than the triangle you put in"""
LDFs(◤::AbstractArray) = ◤[:, 2:end] ./ ◤[:, 1:end-1]

function latest_three_year_LDFs(◤::AbstractArray)

    # Create first, second, and third LDFs, where you have <3 data points
    third = sum(◤[1:2, end-1:end-1]) / sum(◤[1:2, end-2:end-2])
    second = ◤[1, end] / ◤[1, end-1]
    first = second

    three_year_sum = ◤[1:end-2, :] + ◤[2:end-1, :] + ◤[3:end, :]
    three_year_LDFs = LDFs(three_year_sum)

    # Remove last row (all missing values)
    three_year_LDFs = three_year_LDFs[1:end-1, :]

    latest_three_year_LDFs = latest_diagonal(three_year_LDFs)

    return vcat(first, second, third, latest_three_year_LDFs)

end

"""YOYs will have one less row than the triangle you put in"""
YOYs(◤::AbstractArray) = ◤[2:end, :] ./ ◤[1:end-1, :]

function column_averages(◤::AbstractArray)
    col_sum(col) = sum(x for x in col if !ismissing(x))
    col_count(col) = sum(1 for x in col if !ismissing(x))
    return [col_sum(col) ./ col_count(col) for col in eachcol(◤)]
end

function CDFs(◤::AbstractArray, tail_factor::Float64)
    ldfs = LDFs(◤)
    average_ldfs = column_averages(ldfs)
    push!(average_ldfs, tail_factor)

    # reverse the order to appropriately match the losses later
    cdfs = cumprod(average_ldfs[end:-1:1])
    return cdfs
end

CDFs(◤::AbstractArray) = CDFs(◤, 1.0)

function chainladder_ultimates(◤::AbstractArray, tail_factor::Float64)
    return latest_diagonal(◤) .* CDFs(◤, tail_factor)
end

chainladder_ultimates(◤::AbstractArray) = latest_diagonal(◤) .* CDFs(◤)

function three_year_chainladder_ultimates(◤::AbstractArray)
    ldfs = latest_three_year_LDFs(◤)
    cdfs = cumprod(ldfs[end:-1:1])
    return latest_diagonal(◤) .* cdfs
end

function born_ferg_ultimates(◤::AbstractArray,
                             earned_premiums::Vector{<:Number},
                             expected_claims_ratio::Float64,
                             tail_factor::Float64)

    cdfs  = CDFs(◤, tail_factor)
    diagonal = latest_diagonal(◤)
    return diagonal + earned_premiums .* expected_claims_ratio .* (1 .- 1 ./ cdfs)
end

function born_ferg_ultimates(◤::AbstractArray,
                             earned_premiums::Vector{<:Number},
                             expected_claims_ratio::Float64)

    return latest_diagonal(◤) + earned_premiums .* expected_claims_ratio .* (1 .- 1 ./ CDFs(◤))
end

function cape_cod_ultimates(◤::AbstractArray, on_level_earned_premiums::Vector{<:Number})
    cdfs = CDFs(◤)
    diagonal = latest_diagonal(◤)
    used_up_premium = on_level_earned_premiums ./ cdfs
    expected_claims_ratio = sum(diagonal) / sum(used_up_premium)
    return born_ferg_ultimates(◤, on_level_earned_premiums, expected_claims_ratio)
end

function make_lower_right_missing(◤::AbstractArray)
    height, width = size(◤)
    lower_right_missing_matrix = [x <= y ? 1 : missing for x ∈ 1:height, y ∈ width:-1:1]
    return lower_right_missing_matrix .* ◤
end

function make_heatmap(◤::AbstractArray)

    # Check this out -- It would be nice to add text
    # https://discourse.julialang.org/t/annotations-and-line-widths-in-plots-jl-heatmaps/4259
    # Then maybe I could rename this to display() or something like that

    col_maxs = [maximum(x for x in col if !ismissing(x)) for col in eachcol(◤)]
    col_mins = [minimum(x for x in col if !ismissing(x)) for col in eachcol(◤)]

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

    normalized_triangle = rescale.(◤, transpose(col_maxs), transpose(col_mins))
    
    return Plots.heatmap(normalized_triangle[end:-1:1, :],
                         c=cgrad([:red, :yellow, :green], [0.5]),
                         legend=false, xticks=false, yticks=false, border=:none)
end

function berquist_sherman_disposal(counts::AbstractArray, ultimates::Vector{<:Number})

    # the disposal diagonal needs to be in reverse order
    disposal_diagonal = (latest_diagonal(counts) ./ ultimates)[end:-1:1]
    counts = make_lower_right_missing(counts)
    adjusted_counts = ultimates * disposal_diagonal'
    return make_lower_right_missing(adjusted_counts)
end

function berquist_sherman_paid(counts::AbstractArray, paid::AbstractArray, 
                               ultimates::Vector{<:Number})

    adjusted_counts = berquist_sherman_disposal(counts, ultimates)
    return paid .* adjusted_counts ./ counts
end

"""Takes in a ◤ of case reserves, takes the latest diagonal, and applies
severity trend backwards in time. Returns a ◤ of adjusted case reserves."
"""
function berquist_sherman_case(case::AbstractArray, severity_trend::Float64)

    height, width = size(case)
    if height != width
        error("Must use square matrices!")
    end

    diagonal = latest_diagonal(case)
    severity_trends = [(1 + severity_trend) ^ (height + 1 - (x + y)) for x ∈ 1:height, y ∈ 1:height]
    adjusted_case = diagonal .* severity_trends
    return make_lower_right_missing(adjusted_case)
end