# Reserving.jl

[![Build Status](https://github.com/matt-kandel/Reserving.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/matt-kandel/Reserving.jl/actions/workflows/CI.yml?query=branch%3Amain)

This is a library to do basic actuarial reserving based on the Casualty Actuarial Society (CAS) Exam 5
material. I wanted to write code that could scale beyond the 4x4 or 5x5 toy examples that are designed to
be solved under exam conditions.

Reserving methods included and tested:
* Chainladder
* Bornhuetter-Ferguson
* Cape Cod

Things that are included, but not yet tested
* Berquist Sherman case adjustment
* Berquist Sherman disposal rate adjustment

> Note that at the moment this project is only tested on Julia 1.7 or later
> (it relies on eachcol() and eachrow() functions that apparently aren't in Julia 1.0)

The only current dependency is Plots for the (still in-progress) heat mapping function

The test_data.xlsx file is an Excel spreadsheet of simulated data to show that this package can do the 
equivalent of a more traditional actuarial workflow. The tests used so far rely on the same simulated data.

### To do
* Test Berquist-Sherman adjustments
* Write doc strings for all functions
* Write functions for different weighted averages for LDFs and year-on-year changes (last three years, last five years, etc.)
* Write functions for claim emergence

### Larger questions I'll need help with:
How to deal with multiple triangle. Can I use DataFrames.jl? Or maybe a 3 dimensional structure?
Or maybe just give each triangle an ID_dict, that would contain all the metadata that we'd filter on?
