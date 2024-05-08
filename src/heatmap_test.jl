using Plots
Triangle = AbstractArray
include("./functions.jl")

m = missing
# test triangle
◤ = [5354 5763 6320 6415 7462 10417 13804 18052 21709 23584;
    6893 7583 8285 8494 10351 13511 18495 25249 29545 m;
    6346 6653 7484 8211 8869 13248 15681 21674 m m;
    14984 14899 18347 20116 21275 29717 35612 m m m;
    11358 11835 12311 13953 15436 23136 m m m m;	
    10960 10864 11119 13407 14407 m m m m m;	
    14344 14344 17358 19204 m m m m m m;
    7364 7833 8511 m m m m m m m;
    8224 9314 m m m m m m m m;
    8413 m m m m m m m m m]
    
function annotations(x)
    if sample_standard_deviation(x) < 10
        annotations = round.(x, digits = 3)
    else
        annotations = (y -> ismissing(y) ? missing : Int(round(y, digits=0))).(x)
    end
    annotations = (y -> ismissing(y) ? "." : y).(annotations)
    return text.(annotations, :black, :center)
end

"""
This is close to what I want, but there are a couple of things left to improve:
* Add an argument so you can flip the color scheme
* Format numbers > 1000 with commas
* Make the plot size a function of the longest annotation, instead of hard-coded
"""
function make_heatmap(triangle::Triangle)
    # The heatmap is upside down from what I'd expect
    ◤ = reverse(triangle, dims=1)
    Z_scores = hcat(Z_score_normalize.(eachcol(◤))...)

    Plots.heatmap(
        Z_scores,
        c=cgrad([:red, :yellow, :green], [0.5]),
        legend=false,
        xticks=false,
        yticks=false,
        border=:none,
    )

    # I don't know why you have to add each annotation one at a time
    m, n = size(◤)
    for i in 1:m
        for j in 1:n
            annotate!(j, i, annotations(◤)[i, j])
        end
    end
    title!("Sample Heat-Mapped Triangle")
    
    plot!(size=(800, 400))
end

make_heatmap(◤)