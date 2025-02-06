"""
This file contains the functions to simulate the progression of MIR and LIR patients for the datasets in the MIRLIR pipeline.
"""

using Random

function LIR_progression(
    synthetic_patient::SyntheticPatient,
    long_time_points::AbstractVector{<:Real},
    k3_linear_rate::Real,
    k4_linear_rate::Real,
    G_liv_b_linear_rate::Real,
    noise_level::Real = 0.0,
)
    # set k3,k4 & g_liv_b as the standard values
    k3 = 6.07e-3
    k4 = 2.35e-4
    G_liv_b = 0.043
    k3s = fill(k3, length(long_time_points))
    k4s = fill(k4, length(long_time_points))
    G_liv_bs = fill(G_liv_b, length(long_time_points))



    # prescribe the progression of a LIR patient
    k3s = k3s.- (k3_linear_rate * long_time_points * k3) .+ (noise_level * randn(length(long_time_points)) * k3)
    k4s = k4s .- (k4_linear_rate * long_time_points * k4) .+ (noise_level * randn(length(long_time_points)) * k4)
    G_liv_bs = G_liv_bs .+ (G_liv_b_linear_rate * long_time_points * G_liv_b) .+ (noise_level * randn(length(long_time_points)) * G_liv_b)

    return k3s, k4s, G_liv_bs
end

function MIR_progression(
    synthetic_patient::SyntheticPatient,
    long_time_points::AbstractVector{<:Real},
    k5_linear_rate::Real,
    noise_level::Real = 0.0
)
    
    ParameterValues = synthetic_patient.ParameterValues

    # prescribe the progression of a MIR patient
    k5s = ParameterValues[2] .- (k5_linear_rate * long_time_points .* ParameterValues[2]) .+ (noise_level * randn(length(long_time_points)) .* ParameterValues[2])

    return k5s
end


function Healthy_progression(
    synthetic_patient::SyntheticPatient,
    long_time_points::AbstractVector{<:Real},
    noise_level::Real = 0.0
)
    # set k3,k4 & g_liv_b as the standard values
    k3 = 6.07e-3
    k4 = 2.35e-4
    G_liv_b = 0.043
    k3s = fill(k3, length(long_time_points))
    k4s = fill(k4, length(long_time_points))
    G_liv_bs = fill(G_liv_b, length(long_time_points))
    ParameterValues = synthetic_patient.ParameterValues

    # prescribe the progression of a healthy patient
    k3s = k3s .+ (noise_level * randn(length(long_time_points)) .* k3s)
    k4s = k4s .+ (noise_level * randn(length(long_time_points)) .* k4s)
    k5s = ParameterValues[2] .+ (noise_level * randn(length(long_time_points)) .* ParameterValues)
    G_liv_bs = G_liv_bs .+ (noise_level * randn(length(long_time_points)) .* G_liv_bs)

    return k3s, k4s, k5s, G_liv_bs


end