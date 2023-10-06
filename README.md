# Reserving.jl

[![Build Status](https://github.com/matt-kandel/Reserving.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/matt-kandel/Reserving.jl/actions/workflows/CI.yml?query=branch%3Amain)

Basic actuarial reserving based on the Casualty Actuarial Society (CAS) Exam 5 material, but can go beyond the 4x4 or 5x5 toy examples

Reserving methods included and tested:
* Chainladder
* Bornhuetter-Ferguson
* Cape Cod

Things that are included, but not yet tested
* Berquist Sherman case adjustment
* Berquist Sherman disposal rate adjustment

> This project requires Julia 1.7 or later

The test_data.xlsx file is an Excel spreadsheet of simulated data to show that this package can do the 
equivalent of a more traditional actuarial workflow. The tests used so far rely on the same simulated data.

### To do
* Test Berquist-Sherman adjustments
* Write functions for claim emergence