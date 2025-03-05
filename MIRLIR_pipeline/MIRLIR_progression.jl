"""
This file contains the functions to simulate the progression of MIR and LIR patients for the datasets in the MIRLIR pipeline.
"""

using Random
function LIR_progression(
    synthetic_patient::SyntheticPatient,
    long_time_points::AbstractVector{<:Real},
    lambda_k3::Real,
    lambda_k4::Real,
    k5_linear_rate::Real,
    G_liv_b_linear_rate::Real,
    fasting_glucose_linear_rate::Real,
    fasting_insulin_linear_rate::Real,
    noise_dynamic::Real = 0.0,
    k3 = 6.07e-1,
    k4 = 2.35e-1,
    G_liv_b = 0.043,
)
    model = synthetic_patient.EDES
    fasting_glucose = model.prob.p[13]
    fasting_insulin = model.prob.p[14]

    ParameterValues = synthetic_patient.ParameterValues

    # Noisy progression rates
    noisy_lambda_k3 = lambda_k3 + (noise_dynamic * randn() * lambda_k3)
    noisy_lambda_k4 = lambda_k4 + (noise_dynamic * randn() * lambda_k4)
    noisy_k5_linear_rate = k5_linear_rate .+ (noise_dynamic * randn() * k5_linear_rate)
    noisy_G_liv_b_linear_rate = G_liv_b_linear_rate .+ (noise_dynamic * randn() * G_liv_b_linear_rate)
    noisy_fasting_glucose_linear_rate = fasting_glucose_linear_rate .+ (noise_dynamic * randn() * fasting_glucose_linear_rate)
    noisy_fasting_insulin_linear_rate = fasting_insulin_linear_rate .+ (noise_dynamic * randn() * fasting_insulin_linear_rate)

    # Progression of the patient
    k3s = max.(k3 .* exp.(-noisy_lambda_k3 .* long_time_points), 0.0)
    k4s = max.(k4 .* exp.(-noisy_lambda_k4 .* long_time_points), 0.0)
    k5s = max.(ParameterValues[2] .- (noisy_k5_linear_rate * long_time_points * ParameterValues[2]), 0.0)
    G_liv_bs = max.(G_liv_b .+ (noisy_G_liv_b_linear_rate * long_time_points * G_liv_b), 0.0)
    fasting_glucose = max.(fasting_glucose .+ (noisy_fasting_glucose_linear_rate * long_time_points * fasting_glucose), 0.0)
    fasting_insulin = max.(fasting_insulin .+ (noisy_fasting_insulin_linear_rate * long_time_points * fasting_insulin), 0.0)

    return k3s, k4s, k5s, G_liv_bs, fasting_glucose, fasting_insulin
end

function MIR_progression(
    synthetic_patient::SyntheticPatient,
    long_time_points::AbstractVector{<:Real},
    lambda_k5::Real,
    fasting_glucose_linear_rate::Real,
    fasting_insulin_linear_rate::Real,
    noise_dynamic::Real = 0.0,
    noise_flat::Real = 0.0,
    k3 = 6.07e-3,
    k4 = 2.35e-4,
    G_liv_b = 0.043,
)
    model = synthetic_patient.EDES
    fasting_glucose = model.prob.p[13]
    fasting_insulin = model.prob.p[14]

    ParameterValues = synthetic_patient.ParameterValues

    # Noisy progression rate for k5
    noisy_lambda_k5 = lambda_k5 .+ (noise_dynamic * randn() * lambda_k5)
    noisy_fasting_glucose_linear_rate = fasting_glucose_linear_rate .+ (noise_dynamic * randn() * fasting_glucose_linear_rate)
    noisy_fasting_insulin_linear_rate = fasting_insulin_linear_rate .+ (noise_dynamic * randn() * fasting_insulin_linear_rate)
    
    k3s = max.(k3 .+ (noise_flat * randn(length(long_time_points)) .* k3), 0.0)
    k4s = max.(k4 .+ (noise_flat * randn(length(long_time_points)) .* k4), 0.0)
    k5s = max.(ParameterValues[2] .* exp.(-noisy_lambda_k5 .* long_time_points), 0.0)
    G_liv_bs = max.(G_liv_b .+ (noise_flat * randn(length(long_time_points)) .* G_liv_b), 0.0)
    fasting_glucose = max.(fasting_glucose .+ (noisy_fasting_glucose_linear_rate * long_time_points * fasting_glucose), 0.0)
    fasting_insulin = max.(fasting_insulin .+ (noisy_fasting_insulin_linear_rate * long_time_points * fasting_insulin), 0.0)

    return k3s, k4s, k5s, G_liv_bs, fasting_glucose, fasting_insulin
end

# Healthy patients have a flat progression in k3, k4, k5, G_liv_b with random noise
function Healthy_progression(
    synthetic_patient::SyntheticPatient,
    long_time_points::AbstractVector{<:Real},
    noise_level::Real = 0.0,
    k3 = 6.07e-3,  
    k4 = 2.35e-4, 
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