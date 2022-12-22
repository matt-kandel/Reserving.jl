using Plots

# Triangle struct
struct Triangle
    data::Matrix{Union{Number, Missing}}
end

# Functions
function latest_diagonal(triangle::Triangle)
    
    function find_latest_loss(row::SubArray{Union{Number, Missing}})
        # go from right to left and stop when you find a non-missing loss
        i = length(row)
        loss = missing

        while ismissing(loss)
            loss = row[i]
            i -= 1

            if i == 0 # if you hit the end of an all-zero row, return loss = missing
                break
            end

        end

        return loss
    end

    # return a vector of the latest losses
    return [find_latest_loss(row) for row in eachrow(triangle.data)]
end

function LDFs(triangle::Triangle)
    # Returns a Triangle of Loss Development Factors
    # with one less column than original data
    ldfs = triangle.data[:, 2:end] ./ triangle.data[:, 1:end-1]
    return Triangle(ldfs)
end

function YOYs(triangle::Triangle)
    # Returns a Triangle of Year-on-Year Changes 
    # with one less row than original data 
    yoys = triangle.data[2:end, :] ./ triangle.data[1:end-1, :]
    return Triangle(yoys)
end

function column_averages(data)
    # Returns a vector of average ldfs by taking averages across columns

    col_sum(col) = sum(x for x in col if !ismissing(x))
    col_count(col) = sum(1 for x in col if !ismissing(x))
    return [col_sum(col) ./ col_count(col) for col in eachcol(data)]
end

# Convenience function for Triangle objects
column_averages(triangle::Triangle) = column_averages(triangle.data)

function CDFs(triangle::Triangle, tail_factor::Number=1.0)

    # start with LDFs
    ldfs = LDFs(triangle)
    
    # then take average LDF for all columns
    average_ldfs = column_averages(ldfs)
    
    # add the tail factor as the last entry to average_ldfs vector
    push!(average_ldfs, tail_factor)

    # build a cumulative product and reverse the order to line up with original data
    cdfs = cumprod(average_ldfs[end:-1:1])
    return cdfs
end

# When you just put in losses, calculate everything from scratch
function chainladder_ultimates(triangle::Triangle, tail_factor::Number=1.0)
    cdfs  = CDFs(triangle, tail_factor)
    latest_diagonal = latest_diagonal(triangle)
    return latest_diagonal .* cdfs
end

function born_ferg_ultimates(triangle::Triangle,
                                 premiums::Vector{Number},
                                 expected_claims_ratio::Number,
                                 tail_factor::Number=1.0)
    cdfs  = CDFs(triangle, tail_factor)
    latest_diagonal = latest_diagonal(triangle)
    return latest_diagonal + premiums .* expected_claims_ratio .* (1 .- 1 ./ cdfs)
end

function cape_cod_ultimates(triangle::Triangle, on_level_earned_premiums::Vector{Number})
    cdfs = CDFs(triangle)
    latest_diagonal = latest_diagonal(triangle)
    used_up_premium = on_level_earned_premiums ./ cdfs
    expected_claims_ratio = sum(latest_diagonal) / sum(used_up_premium)
    
    return born_ferg_ultimates(triangle, on_level_earned_premiums, expected_claims_ratio)
end

function make_lower_right_missing(matrix)
    height, width = size(matrix)
    lower_right_missing_matrix = [x <= y ? 1 : missing for x ∈ 1:height, y ∈ width:-1:1]
    return matrix .* lower_right_missing_matrix
end

function make_heatmap(triangle::Triangle)

    # Check this out -- It would be nice to add text
    # https://discourse.julialang.org/t/annotations-and-line-widths-in-plots-jl-heatmaps/4259
    # Then maybe I could rename this to display() or something like that

    col_maxs = [maximum(x for x in col if !ismissing(x)) for col in eachcol(triangle.data)]
    col_mins = [minimum(x for x in col if !ismissing(x)) for col in eachcol(triangle.data)]

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

    normalized_triangle = rescale.(triangle.data, transpose(col_maxs), transpose(col_mins))
    
    return Plots.heatmap(normalized_triangle[end:-1:1, 1:end],
                         c=cgrad([:red, :yellow, :green], [0.5]),
                         legend=false, xticks=false, yticks=false, border=:none)
end

function berquist_sherman_adjust_disposal(counts::Triangle, 
                                          ultimates::Vector{Number})

    # get latest diagonal of disposal rates
    # it's also backwards from how I usually calculate it, so also need to reverse it
    disposal_diagonal = (latest_diagonal(counts) ./ ultimates)[end:-1:1]

    counts = make_lower_right_missing(counts)

    # create adjusted counts
    adjusted_counts = ultimates * disposal_diagonal'
    adjusted_counts = make_lower_right_missing(adjusted_counts)

    return adjusted_counts
end

function berquist_sherman_adjust_paid(counts::Triangle,
                                      paid::Triangle,
                                      ultimates::Vector{Number})

    adjusted_counts = berquist_sherman_adjust_disposal(counts, ultimates)

    return paid .* adjusted_counts ./ counts
end

function berquist_sherman_case(case::Matrix{Union{Number, Missing}}, severity_trend)
    """Takes in a triangle of case reserves, takes the latest diagonal, and applies severity trend backwards in time
    Returns the adjusted case reserves triangle
    """

    # I could probably extend this to rectangles later, but that won't be necessary for the exam
    # I could always add a row of missings at the bottom to resize things,
    # and there's no point in adding it until I need it
    height, width = size(case)
    if height != width
        error("must be square!")
    end

    latest_diagonal = latest_diagonal(case)
    severity_trends = [(1 + severity_trend) ^ (height + 1 - (x + y)) for x ∈ 1:height, y ∈ 1:height]
    adjusted_case = latest_diagonal .* severity_trends
    return make_lower_right_missing(adjusted_case)
end