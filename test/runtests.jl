using ExamFive
using Test

# Using this variable to make Triangles look more readable
m = missing

# this is the same as the Fictional_Data.xlsx "Things to Replicate" tab
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

excel_latest_diagonal = [23584.374, 29545.357, 21674.816, 35612.669, 23136.069,
                         14407.979, 19204.899, 8511.343, 9314.840, 8413.701]

excel_chainladder_results = [23584.374, 32096.387, 27934.462, 62039.612, 
        51145.223, 45168.086, 67234.917, 32689.289, 39826.728, 37766.747]

# So this includes a row of ms at the bottom so that the dimensions match
# the get_LDFs() function output (I may alter it later to preserve dimensions from original triangle)
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

# These are backwards from how I've organized them in Julia,
# so that's why I have the indexing thing at the end
excel_CDFs = [4.488720, 4.275621, 3.840673, 3.500925, 3.134936, 2.210627,
              1.742066, 1.288798, 1.086343, 1.000000][end:-1:1]

@testset "ExamFive.jl" begin
    @test get_latest_diagonal(test_triangle) == excel_latest_diagonal
    @test get_chainladder_ultimates(test_triangle) ≈ excel_chainladder_results rtol=1e-6
    
    # testing the get_LDFs() function
    # the lambda function is necessary because missing == missing results in missing, not true
    # this is too messy -- later, refactor the lambda function as
    # replace_missings_with_zeros() or something
    @test (x -> ismissing(x) ? 0. : x).(get_LDFs(test_triangle).data) ≈
          (x -> ismissing(x) ? 0. : x).(excel_LDFs) rtol = 1e-6

    @test get_CDFs(test_triangle) ≈ excel_CDFs rtol = 1e-6

    # later do @test get_YOYs but it's not important right now

end