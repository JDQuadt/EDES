"""
This file contains the functions to simulate the progression of MIR and LIR patients.
"""

function LIR_progression(
    synthetic_patient::SyntheticPatient,
    long_time_points::AbstractVector{<:Real},
    k3_linear_rate::Real,
    k4_linear_rate::Real,
    G_liv_b_linear_rate::Real,
)
    parameter_values = synthetic_patient.ParameterValues

    # check the changed parameters are actually k3, k4 and G_liv_b
    if synthetic_patient.EDES.estimated_params != ["k3", "k4", "G_liv_b"]
        error("The estimated parameters are not k3, k4 and G_liv_b, this progression function is not suitable for this model.")
    end
    # prescribe the progression of a MIR patient
    k3s = parameter_values[1] .- (k3_linear_rate * long_time_points * parameter_values[1])
    k4s = parameter_values[2] .- (k4_linear_rate * long_time_points * parameter_values[2])
    G_liv_bs = parameter_values[3] .- (G_liv_b_linear_rate * long_time_points * parameter_values[3])

    return k3s, k4s, G_liv_bs
end


function MIR_progression(
    synthetic_patient::SyntheticPatient,
    long_time_points::AbstractVector{<:Real},
    k5_linear_rate::Real,
)
    parameter_values = synthetic_patient.ParameterValues

    # prescribe the progression of a LIR patient
    k5s = parameter_values[1] .- (k5_linear_rate * long_time_points * parameter_values[1])

    return k5s
end