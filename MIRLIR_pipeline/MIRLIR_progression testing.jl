"""
This file contains the functions to simulate the progression of MIR and LIR patients for the datasets in the MIRLIR pipeline.
"""

using Random
# LIR patients have a progression in k3, k4, G_liv_b with k5 having a flat progression with random noise
function LIR_progression(
    synthetic_patient::SyntheticPatient,
    long_time_points::AbstractVector{<:Real},
    k3_linear_rate::Real,
    k4_linear_rate::Real,
    G_liv_b_linear_rate::Real,
    fasting_glucose_linear_rate::Real,
    fasting_insulin_linear_rate::Real,
    noise_level::Real = 0.0,
    k3 = 6.07e-1,
    k4 = 2.35e-1,
    G_liv_b = 0.043,
)
    # get the fasting glucose and insulin values of the synthetic patient
    model = synthetic_patient.EDES
    fasting_glucose = model.prob.p[13]
    fasting_insulin = model.prob.p[14]

    # initialize the k3, k4,  G_liv_b values
    k3s = fill(k3, length(long_time_points))
    k4s = fill(k4, length(long_time_points))
    G_liv_bs = fill(G_liv_b, length(long_time_points))

    # get the parameter values of the synthetic patient
    ParameterValues = synthetic_patient.ParameterValues

    # prescribe the progression of a LIR patient (max. is used to ensure that the values are non-negative)
    k3s = max.(k3s.- (k3_linear_rate * long_time_points * k3) .+ (noise_level * randn(length(long_time_points)) * k3),0.0)
    k3s[6] = 6.07e-3
    k4s = max.(k4s .- (k4_linear_rate * long_time_points * k4) .+ (noise_level * randn(length(long_time_points)) * k4), 0.0)
    k4s[6] = 2.35e-4
    k5s = max.(ParameterValues[2] .+ (noise_level * randn(length(long_time_points)) * ParameterValues[2]), 0.0)
    G_liv_bs = max.(G_liv_bs .+ (G_liv_b_linear_rate * long_time_points * G_liv_b) .+ (noise_level * randn(length(long_time_points)) * G_liv_b), 0.0)
    fasting_glucose = max.(fasting_glucose .+ (fasting_glucose_linear_rate * long_time_points * fasting_glucose) .+ (noise_level * randn(length(long_time_points)) * fasting_glucose), 0.0)
    fasting_insulin = max.(fasting_insulin .+ (fasting_insulin_linear_rate * long_time_points * fasting_insulin) .+ (noise_level * randn(length(long_time_points)) * fasting_insulin), 0.0)

    return k3s, k4s, k5s, G_liv_bs, fasting_glucose, fasting_insulin
end

# MIR patients have a progression in k5 with k3, k4,G_liv_b having a flat progression with random noise
function MIR_progression(
    synthetic_patient::SyntheticPatient,
    long_time_points::AbstractVector{<:Real},
    k5_linear_rate::Real,
    fasting_glucose_linear_rate::Real,
    fasting_insulin_linear_rate::Real,
    noise_level::Real = 0.0, 
    k3 = 6.07e-1,
    k4 = 2.35e-1,
    G_liv_b = 0.043,
)
    # get the fasting glucose and insulin values of the synthetic patient
    model = synthetic_patient.EDES
    fasting_glucose = model.prob.p[13]
    fasting_insulin = model.prob.p[14]

    # initialize the k3, k4,  G_liv_b values
    k3s = fill(k3, length(long_time_points))
    k4s = fill(k4, length(long_time_points))
    G_liv_bs = fill(G_liv_b, length(long_time_points))

    # get the parameter values of the synthetic patient
    ParameterValues = synthetic_patient.ParameterValues

    # prescribe the progression of a MIR patient
    k3s = max.(k3s .+ (noise_level * randn(length(long_time_points)) .* k3s), 0.0)
    k4s = max.(k4s .+ (noise_level * randn(length(long_time_points)) .* k4s), 0.0)
    k5s = max.(ParameterValues[2] .- (k5_linear_rate * long_time_points .* ParameterValues[2]) .+ (noise_level * randn(length(long_time_points)) .* ParameterValues[2]), 0.0)
    G_liv_bs = max.(G_liv_bs .+ (noise_level * randn(length(long_time_points)) .* G_liv_bs), 0.0)
    fasting_glucose = max.(fasting_glucose .+ (fasting_glucose_linear_rate * long_time_points * fasting_glucose) .+ (noise_level * randn(length(long_time_points)) * fasting_glucose), 0.0)
    fasting_insulin = max.(fasting_insulin .+ (fasting_insulin_linear_rate * long_time_points * fasting_insulin) .+ (noise_level * randn(length(long_time_points)) * fasting_insulin), 0.0)


    return k3s, k4s, k5s, G_liv_bs, fasting_glucose, fasting_insulin
end

# Healthy patients have a flat progression in k3, k4, k5, G_liv_b with random noise
function Healthy_progression(
    synthetic_patient::SyntheticPatient,
    long_time_points::AbstractVector{<:Real},
    noise_level::Real = 0.0,
    k3 = 6.07e-1,
    k4 = 2.35e-1,
    G_liv_b = 0.043,
)
    # get the fasting glucose and insulin values of the synthetic patient
    model = synthetic_patient.EDES
    fasting_glucose = model.prob.p[13]
    fasting_insulin = model.prob.p[14]

    # initialize the k3, k4,  G_liv_b values
    k3s = fill(k3, length(long_time_points))
    k4s = fill(k4, length(long_time_points))
    G_liv_bs = fill(G_liv_b, length(long_time_points))
    ParameterValues = synthetic_patient.ParameterValues

    # prescribe the progression of a healthy patient
    k3s = max.(k3s .+ (noise_level * randn(length(long_time_points)) .* k3s), 0.0)
    k4s = max.(k4s .+ (noise_level * randn(length(long_time_points)) .* k4s), 0.0)
    k5s = max.(ParameterValues[2] .+ (noise_level * randn(length(long_time_points)) * ParameterValues[2]), 0.0)
    G_liv_bs = max.(G_liv_bs .+ (noise_level * randn(length(long_time_points)) .* G_liv_bs), 0.0)
    fasting_glucose = max.(fasting_glucose .+ (noise_level * randn(length(long_time_points)) * fasting_glucose), 0.0)
    fasting_insulin = max.(fasting_insulin .+ (noise_level * randn(length(long_time_points)) * fasting_insulin), 0.0)

    return k3s, k4s, k5s, G_liv_bs, fasting_glucose, fasting_insulin
end