function DiabeticProgression(
    long_time_points::AbstractVector{<:Real},
    synthetic_patient::SyntheticPatient,
    k5_linear_rate::Real,
    k6_parabolic_rate::Real =0,
    k6_linear_rate::Real =0,
    Health_bool::Bool = false,
    
)
    # extract model and parameter values
    model = synthetic_patient.EDES
    parameter_values = synthetic_patient.ParameterValues

    # if the patient is healthy, return the initial parameter values
    if Health_bool
        k5s = parameter_values[1] .* ones(length(long_time_points))
        k6s = parameter_values[2] .* ones(length(long_time_points))
        Gbs = model.prob.p[13] .* ones(length(long_time_points))
        I_pl_bs = model.prob.p[14] .* ones(length(long_time_points))
        return k5s, k6s, Gbs, I_pl_bs
    end

    # change the k5 value based on a linear decrease from its initial value

    k5s = parameter_values[1] .- (k5_linear_rate * long_time_points * parameter_values[1])

    # change the k6 value based on a parabolic increase and subsequent decrease from its initial value
    #k6s = -0.025*(long_time_points.-6).^2 .+ 2.5
    k6s = parameter_values[2] .+((- k6_parabolic_rate.* long_time_points.^2 * parameter_values[2]) .+ (k6_linear_rate .* long_time_points * parameter_values[2]))

    # let basal glucose rise slightly to simulate deterioration of the fasting glucose
    Gb = model.prob.p[13]
    Gbs = Gb .+ (0.03 * long_time_points * Gb)

    # let basal insulin rise slightly to simulate deterioration of the fasting insulin
    I_pl_b = model.prob.p[14]
    I_pl_bs = I_pl_b .+ (0.7 * long_time_points * I_pl_b) #0.04

    return k5s, k6s, Gbs, I_pl_bs
end
