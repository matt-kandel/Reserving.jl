# Reserving.jl

[![Build Status](https://github.com/matt-kandel/Reserving.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/matt-kandel/Reserving.jl/actions/workflows/CI.yml?query=branch%3Amaster)

This is a library to do basic actuarial reserving based on the Casualty Actuarial Society (CAS) Exam 5
material. I wanted to write code could scale beyond the 4x4 or 5x5 toy examples that are designed to
be solved under exam conditions.

Reserving methods included so far:
* Chainladder (included in tests)
* Bornhuetter-Ferguson (not tested yet)
* Cape Cod (not tested yet)
* Berquist Sherman case adjustment (not tested yet)
* Berquist Sherman disposal rate adjustment (not tested yet)

> Note that at the moment this project is only tested on Julia 1.7 or later
> (it relies on eachcol() and eachrow() functions that apparently aren't in Julia 1.0)

The only current dependency is Plots for the (still in-progress) heat mapping function

The test_data.xlsx file is an Excel spreadsheet of simulated data to show that this package can do the 
equivalent of a more traditional actuarial workflow. The tests used so far rely on the same simulated data.

### To do later
* functions for different weighted averages for LDFs and year-on-year changes (last three years, last five years, etc.)
* write tests for Berquist-Sherman functions
* functions for claim emergence