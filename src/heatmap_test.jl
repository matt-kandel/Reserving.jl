using Reserving, Plots

m = missing
test_triangle = Triangle([5354.59 5763.431 6320.691 6415.301 7462.344 10417.88 13804.126 18052.522 21709.881 23584.374;
             6893.559 7583.799 8285.608 8494.81 10351.909 13511.972 18495.772 25249.579 29545.357 m;
             6346.612 6653.083 7484.867 8211.589 8869.705 13248.745 15681.65 21674.816 m m;
             14984.834 14899.344 18347.581 20116.573 21275.654 29717.902 35612.669 m m m;
             11358.874 11835.454 12311.035 13953.818 15436.728 23136.069 m m m m;	
             10960.304 10864.487 11119.425 13407.616 14407.979 m m m m m;	
             14344.352 14344.352 17358.497 19204.899 m m m m m m;
             7364.853 7833.587 8511.343 m m m m m m m;
             8224.016 9314.84 m m m m m m m m;
             8413.701 m m m m m m m m m])

# annotations reference: https://goropikari.github.io/PlotsGallery.jl/src/heatmap.html

function make_heatmap(triangle::Triangle, annotations=true)

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

    Plots.heatmap(normalized_triangle[end:-1:1, :], c=cgrad([:red, :yellow, :green], [0.5]),
    aspect_ratio=:equal, legend=false, xticks=false, yticks=false, border=:none)

    fontsize = 10
    nrow, ncol = size(triangle.data)
#   This version works but it displays "Missings"
#    ann = [(j,i, text(round(triangle.data[end:-1:1, :][i,j] / 1000, digits=1), fontsize, :black, :center))
#                for i in nrow:-1:1 for j in 1:ncol]

    if annotations
        # This is a really hackish way of getting rid of the missings
        ann = [ismissing(triangle.data[end:-1:1, :][i,j]) ?
                (j,i, text(".", fontsize, :black, :center)) :
                (j,i, text(round(triangle.data[end:-1:1, :][i,j], digits=1), fontsize, :black, :center))
                for i in nrow:-1:1 for j in 1:ncol]

        annotate!(ann, linecolor=:black)
    end
    title!("Sample (fictitious) Heat-Mapped Triangle")

end

make_heatmap(test_triangle)

◤ = rand(10, 10)
make_heatmap(Triangle(◤ .* [x for x in 4.:4.:40.]'))


