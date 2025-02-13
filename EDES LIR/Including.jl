"""
This file includes all the necessary files for defining the model, simulating meal responses and fitting the model on individual data through parameter estimation.
"""
# model
include("Model/EDES.jl")
include("Model/Parameters.jl")
include("Model/ODEs.jl")
include("Model/InitialState.jl")

# simulation
include("ParameterEstimation/Simulate_model_output.jl")

# data
include("SampleData/SampleData.jl")

# parameter estimation
include("ParameterEstimation/Loss.jl")
include("ParameterEstimation/LHCSampling.jl")
include("ParameterEstimation/ParameterHandling.jl")
include("ParameterEstimation/Fitting.jl")

# plotting
include("Plotting/PlotMealResponse.jl")
