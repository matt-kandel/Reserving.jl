using Reserving
using Test

# Shorthand to make the Triangles look more readable
m = missing

# From test_data.xlsx, "basic reserving" tab
test_triangle = [5354.59 5763.431 6320.691 6415.301 7462.344 10417.88 13804.126 18052.522 21709.881 23584.374;
                 6893.559 7583.799 8285.608 8494.81 10351.909 13511.972 18495.772 25249.579 29545.357 m;
                 6346.612 6653.083 7484.867 8211.589 8869.705 13248.745 15681.65 21674.816 m m;
                 14984.834 14899.344 18347.581 20116.573 21275.654 29717.902 35612.669 m m m;
                 11358.874 11835.454 12311.035 13953.818 15436.728 23136.069 m m m m;	
                 10960.304 10864.487 11119.425 13407.616 14407.979 m m m m m;	
                 14344.352 14344.352 17358.497 19204.899 m m m m m m;
                 7364.853 7833.587 8511.343 m m m m m m m;
                 8224.016 9314.84 m m m m m m m m;
                 8413.701 m m m m m m m m m]

excel_latest_diagonal = [23584.374, 29545.357, 21674.816, 35612.669, 23136.069,
                         14407.979, 19204.899, 8511.343, 9314.840, 8413.701]

excel_chainladder_ultimates = [23584.374, 32096.387, 27934.462, 62039.612, 
        51145.223, 45168.086, 67234.917, 32689.289, 39826.728, 37766.747]

# Includes a row of missings at the bottom so that the dimensions match
# the LDFs() function output (I may alter it later to preserve dimensions from original triangle)
excel_LDFs = [1.076353 1.096689 1.014968 1.163210 1.396060 1.325042 1.307763 1.202595 1.086343
              1.100128 1.092541 1.025249 1.218616 1.305264 1.368843 1.365154 1.170133	m
              1.048289 1.125022 1.097092 1.080145 1.493708 1.183633 1.382177 m m
              0.994295 1.231435 1.096416 1.057618 1.396803 1.198357 m m m
              1.041957 1.040183 1.133440 1.106273 1.498768 m m m m
              0.991258 1.023465 1.205783 1.074612 m m m m m
              1.000000 1.210128 1.106369 m m m m m m
              1.063645 1.086519 m m m m m m m
              1.132639 m m m m m m m m	
              m m m m m m m m m]

# again, extra column of missings so that dimensions align
excel_YOYs = [1.287411 1.315848 1.310871 1.324148 1.387219 1.296998 1.339873 1.398673 1.360918 m
              0.920658 0.877276 0.903358 0.966660 0.856818 0.980519 0.847851 0.858423 m m
              2.361076 2.239465 2.451290 2.449778 2.398688 2.243073 2.270977 m m m
              0.758025 0.794361 0.670990 0.693648 0.725558 0.778523 m m m m
              0.964911 0.917961 0.903208 0.960856 0.933357 m m m m m
              1.308755 1.320297 1.561097 1.432387 m m m m m m
              0.513432 0.546110 0.490327 m m m m m m m	  	  
              1.116657 1.189090 m m m m m m m m	  	  
              1.023065 m m m m m m m m m]

# These are backwards from how I've organized them in Julia,
# so that's why I have the indexing thing at the end
excel_CDFs = [4.488720, 4.275621, 3.840673, 3.500925, 3.134936, 2.210627,
              1.742066, 1.288798, 1.086343, 1.000000][end:-1:1]

excel_column_averages = [1.049840, 1.113248, 1.097045, 1.116746, 1.418120, 
                         1.268969, 1.351698, 1.186364, 1.086343, 1.000000][end:-1:1]

# For some reason, these need to be Floats, even though I
# defined my functions on Vector{Number} type
excel_premiums = [27510., 32285, 37395, 42300, 47040,
                  52095, 57165, 62020, 67010, 72205]

excel_born_ferg_ultimates = [23584.374, 31341.572, 27540.532, 48225.607, 41168.749,
                            39242.183, 47790.421, 40621.596, 45251.037, 47697.086]

excel_cape_cod_ultimates = [23584.374, 31879.079, 29295.815, 51999.960, 46564.929,
                            46673.682, 56344.482, 50230.414, 56004.747, 59452.424]

excel_berq_sherm_unadj_case = [3701	5660 9262 10151 11745 16627 19238 21423
                               7250 10625 12960	14221 17067	23411 24551 m	
                               5877 8122 10613 14373 21706 29044 m m	
                               8234 11433 15499 25040 28019 m m m			
                               10124 13785 30233 33266 m m m m	
                               8261 22477 34402	m m m m m	
                               11176 32160 m m m m m m
                               13028 m m m m m m m]

excel_berq_sherm_adj_case = [4897.708 13903.655 17103.874 19019.943 18422.947 21961.437 21348.696 21423.000
                             5632.364 15989.204 19669.455 21872.935 21186.389 25255.652 24551.000 m
                             6477.219 18387.584 22619.873 25153.875 24364.348 29044.000 m m
                             7448.801 21145.722 26012.854 28926.957 28019.000 m m m
                             8566.121 24317.580 29914.783 33266.000 m m m m
                             9851.040 27965.217 34402.000 m m m m m
                             11328.696 32160.000 m m m m m m		
                             13028.000 m m m m m m m]

# Because missing == missing evaluates to missing
# this function replaces missing with zero
fix_missing(x::Union{Number, Missing}) = ismissing(x) ? 0 : x
fix_missings(data) = fix_missing.(data)

@testset "Reserving.jl" begin
    
    @test latest_diagonal(test_triangle) == excel_latest_diagonal

    # testing the LDFs() and YOYs() functions
    my_LDFs = LDFs(test_triangle).data
    my_LDFs = fix_missings(my_LDFs)
    @test my_LDFs ≈ fix_missings(excel_LDFs) rtol = 1e-6
   
    my_YOYs = YOYs(test_triangle).data
    my_YOYs = fix_missings(my_YOYs)
    @test my_YOYs ≈ fix_missings(excel_YOYs) rtol = 1e-6

    @test CDFs(test_triangle) ≈ excel_CDFs rtol = 1e-6

    # column_averages are average Loss Development Factors
    # need to add 1.0 entry at the end and reverse to align with Excel results
    my_column_averages = column_averages(excel_LDFs)
    push!(my_column_averages, 1.0)
    my_column_averages = my_column_averages[end:-1:1]
    @test my_column_averages ≈ excel_column_averages rtol = 1e-6
    @test chainladder_ultimates(test_triangle) ≈ excel_chainladder_ultimates rtol = 1e-6
    
#    @test make_lower_right_missing
    @test born_ferg_ultimates(test_triangle, excel_premiums, .7) ≈ excel_born_ferg_ultimates rtol = 1e-6
 
    # For this example, I'll say that my (made up) Premiums are On Level Premiums
    @test cape_cod_ultimates(test_triangle, excel_premiums) ≈ excel_cape_cod_ultimates rtol = 1e-6
 
#    I don't know how to test a plotting function yet
#    @test make_heatmap,

#    @test berquist_sherman_disposal
    
#    @test berquist_sherman_paid
    
    my_berq_sherm_adj_case = berquist_sherman_case(excel_berq_sherm_unadj_case, .15)
    my_berq_sherm_adj_case = fix_missings(my_berq_sherm_adj_case)

#    @test my_berq_sherm_adj_case ≈ fix_missings(excel_berq_sherm_adj_case) rtol = 1e-3
           
end