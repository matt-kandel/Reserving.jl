# Reserving.jl

[![Build Status](https://github.com/matt-kandel/Reserving.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/matt-kandel/Reserving.jl/actions/workflows/CI.yml?query=branch%3Amain)

Basic actuarial reserving based on the Casualty Actuarial Society (CAS) Exam 5 material, but can go beyond the 4x4 or 5x5 toy examples

> This project requires Julia 1.7 or later

Functions included and tested:
* Latest diagonal
* Year-on-year changes
* Loss development factors (using average columns)
* Chainladder
* Bornhuetter-Ferguson
* Cape Cod
* Berquist-Sherman case adjustment

All data in the test_data.xlsx file is simulated. Using an Excel workbook so the old-school actuaries can follow along. The runtests.jl script uses the same data.

### To do
* Test Berquist-Sherman disposal & paid functions
* Test latest_three_year_LDFs (I'm pretty confident about it, though)
* Write functions for claim emergence