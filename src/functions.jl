Triangle = AbstractMatrix

latest_diagonal(◤::Triangle) = eachrow(◤) .|> skipmissing .|> collect .|> last

"""Year-on-Year changes will have one less row than the triangle you put in"""
YOYs(◤::Triangle) = ◤[2:end, :] ./ ◤[1:end-1, :]

"""LDFs will have one less column than the triangle you put in"""
LDFs(◤::Triangle) = ◤[:, 2:end] ./ ◤[:, 1:end-1]

function latest_three_year_LDFs(◤::Triangle)
    # Create first, second, and third LDFs, where you have <3 data points
    third = sum(◤[1:2, end-1:end-1]) / sum(◤[1:2, end-2:end-2])
    second = ◤[1, end] / ◤[1, end-1]
    first = second

    # Use matrix operations to get most of the LDFs
    three_year_sum = ◤[1:end-2, :] + ◤[2:end-1, :] + ◤[3:end, :]
    three_year_LDFs = LDFs(three_year_sum)

    # Remove last row (all missing)
    three_year_LDFs = three_year_LDFs[1:end-1, :]
    latest_three_year_LDFs = latest_diagonal(three_year_LDFs)
    return vcat(first, second, third, latest_three_year_LDFs)
end

# For the heat mapping function
function μ(x)
    x = x |> skipmissing |> collect
    return sum(x) / length(x)
end

function sample_variance(x)
    x = x |> skipmissing |> collect    
    return (sum((x .- μ(x)) .^ 2) / (length(x) - 1))
end
sample_standard_deviation(x) = x |> sample_variance |> sqrt 
Z_score_normalize(x) = (x .- μ(x)) / sample_standard_deviation(x)

function CDFs(◤::Triangle, tail_factor::Float64=1.0)
    average_ldfs = ◤ |> LDFs |> eachcol .|> μ
    push!(average_ldfs, tail_factor)
    cdfs = cumprod(reverse(average_ldfs))
    return cdfs
end

function chainladder_ultimates(◤::Triangle, tail_factor::Float64=1.0)
    return latest_diagonal(◤) .* CDFs(◤, tail_factor)
end

function three_year_chainladder_ultimates(◤::Triangle)
    ldfs = latest_three_year_LDFs(◤)
    cdfs = cumprod(reverse(ldfs))
    return latest_diagonal(◤) .* cdfs
end

function born_ferg_ultimates(◤::Triangle, earned_premiums::Vector{<:Number},
                             expected_claims_ratio::Float64, tail_factor::Float64=1.0)
    cdfs  = CDFs(◤, tail_factor)
    weights = 1 .- 1 ./ cdfs
    return latest_diagonal(◤) + earned_premiums .* expected_claims_ratio .* weights
end

function cape_cod_ultimates(◤::Triangle, on_level_earned_premiums::Vector{<:Number})
    used_up_premium = on_level_earned_premiums ./ CDFs(◤)
    expected_claims_ratio = sum(latest_diagonal(◤)) / sum(used_up_premium)
    return born_ferg_ultimates(◤, on_level_earned_premiums, expected_claims_ratio)
end

function make_lower_right_missing(◤::Triangle)
    m, n = size(◤)
    mask = (1:m) .+ (1:n)' .> n + 1
    return ifelse.(mask, missing, ◤)
end

function berquist_sherman_disposal(counts::Triangle, ultimates::Vector{<:Number})
    disposal_diagonal = latest_diagonal(counts) ./ ultimates
    adjusted_counts = ultimates * reverse(disposal_diagonal)'
    return make_lower_right_missing(adjusted_counts)
end

function berquist_sherman_paid(counts::Triangle, paid::Triangle, ultimates::Vector{<:Number})
    adjusted_counts = berquist_sherman_disposal(counts, ultimates)
    return paid .* adjusted_counts ./ counts
end

"""Takes in a ◤ of case reserves, takes the latest diagonal, and applies
severity trend backwards in time. Returns a ◤ of adjusted case reserves.
"""
function berquist_sherman_case(case::Triangle, severity_trend::Float64)
    m, n = size(case)
    if m != n
        error("Must use square matrices!")
    end
    exponents = (1:m) .- (n:-1:1)'
    severity_trends = (1 + severity_trend) .^ exponents
    adjusted_case = severity_trends .* reverse(latest_diagonal(case))'
    return make_lower_right_missing(adjusted_case)
end