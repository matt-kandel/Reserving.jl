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

test_triangle2 = [40.170 56.430	73.737	83.806	94.848	82.996	92.761	104.297	93.264	94.668	86.520	97.085	109.653	99.454	101.901	113.609	114.211	103.068	93.669	106.683;
                  46.057 65.022	73.272	83.835	86.586	96.439	99.953	98.175	100.236	100.689	99.752	103.346	108.115	101.227	101.739	111.162	100.665	99.356	110.174	m;
                  44.949 62.053	77.085	77.523	90.577	95.948	104.057	95.347	102.356	99.069	105.462	103.913	102.034	105.222	119.014	101.638	102.308	102.076	m m;
                  47.137 72.135	90.499	88.111	92.212	101.041	101.479	88.597	94.775	105.252	115.801	106.375	105.859	109.957	104.325	110.813	115.344	m m m;
                  44.022 71.110	75.508	98.261	92.713	93.625	101.817	109.443	104.304	99.326	110.939	114.743	111.409	125.341	106.428	116.608	m m m m;
                  49.994 73.015	83.299	88.807	98.778	100.830	99.489	110.891	114.743	116.154	113.052	96.776	116.520	122.642	116.553	m m m m m;
                  49.018 78.119	89.387	95.860	101.268	116.603	108.650	110.388	120.631	119.471	119.121	114.330	118.976	122.187 m m m m m m;	
                  50.970 82.345	88.987	98.910	110.272	101.751	111.757	123.284	114.497	112.384	127.223	115.844	129.001 m m m m m m m;	
                  52.020 75.822	86.609	104.040	104.353	107.295	117.322	105.195	118.281	123.811	127.510	131.632 m m m m m m m m;		
                  57.692 80.326	92.004	112.229	119.813	121.774	115.622	118.731	118.022	128.848	127.745 m m m m m m m m m;		
                  62.201 87.996	101.222	100.145	120.461	131.392	127.178	114.423	130.389	122.671 m m m m m m m m m m;			
                  56.130 86.688	106.535	124.149	122.890	125.723	134.697	120.728	126.303 m m m m m m m m m m m;			
                  57.647 95.268	109.049	111.357	122.226	120.730	121.460	129.074 m m m m m m m m m m m m;				
                  59.025 92.052	108.371	126.289	131.198	146.148	135.972 m m m m m m m m m m m m m;				
                  64.677 92.192	106.184	123.520	135.866	129.165 m m m m m m m m m m m m m m;					
                  62.954 81.153	103.760	122.589	137.474 m m m m m m m m m m m m m m m;					
                  67.755 98.780	122.413	132.443 m m m m m m m m m m m m m m m m;						
                  75.814 99.926	118.991 m m m m m m m m m m m m m m m m m;						
                  74.403 102.834 m m m m m m m m m m m m m m m m m m;								
                  75.241 m m m m m m m m m m m m m m m m m m m]

excel_three_year_LDFs = [1.13893737, 1.13893737, 1.007004632, 0.960009725,
                         0.983633919, 0.997858125, 0.914414526, 1.067064309,
                         1.114844008, 0.967775159, 1.047758766, 1.023559734,
                         1.05886904, 0.950146687, 0.998797657, 1.017346656,
                         1.086304759, 1.138991348, 1.233347913, 1.383387304]

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

excel_premiums = [27510, 32285, 37395, 42300, 47040,
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
change_missing_to_zero(x::Union{Int64, Float64, Missing}) = ismissing(x) ? 0 : x

@testset "Reserving.jl" begin
    
    @test latest_diagonal(test_triangle) == excel_latest_diagonal

    # testing the LDFs() and YOYs() functions
    my_LDFs = LDFs(test_triangle)
    my_LDFs = change_missing_to_zero.(my_LDFs)
    @test my_LDFs ≈ change_missing_to_zero.(excel_LDFs) rtol = 1e-6
   
    my_YOYs = YOYs(test_triangle)
    my_YOYs = change_missing_to_zero.(my_YOYs)
    @test my_YOYs ≈ change_missing_to_zero.(excel_YOYs) rtol = 1e-6

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
 
    @test latest_three_year_LDFs(test_triangle2) ≈ excel_three_year_LDFs rtol = 1e-5

#    @test berquist_sherman_disposal
    
#    @test berquist_sherman_paid
    
#    my_berq_sherm_adj_case = berquist_sherman_case(excel_berq_sherm_unadj_case, .15)
#    my_berq_sherm_adj_case = change_missing_to_zero.(my_berq_sherm_adj_case)

#    @test my_berq_sherm_adj_case ≈ change_missing_to_zero.(excel_berq_sherm_adj_case) rtol = 1e-3
           
end