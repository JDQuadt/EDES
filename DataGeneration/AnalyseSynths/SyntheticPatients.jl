struct SyntheticPatient
    EDES::EDES
    ParameterValues::AbstractVector
    ID::Int
end

struct SyntheticProgression
    patient::SyntheticPatient
    long_time_points::AbstractVector{<:Real}
    parameter_names::AbstractVector{String}
    parameter_values::AbstractMatrix
    fasting_glucose::AbstractVector{<:Real}
    fasting_insulin::AbstractVector{<:Real}
end

function MakePatients(
    n_patients::Int,
    estimated_params::AbstractVector{String},
    params_ranges::AbstractDict{String, <:Tuple{Real, Real}},
    fasting_ranges::AbstractDict{String, <:Tuple{Real, Real}};
    G_dose::Real = 75000.0,
    BW::Real = 70.0,
    timespan::Tuple{Real,Real} = (0.0, 240.0),
    rng = Random.default_rng(),
)

    # check if there are any parameters in the ranges that are not in the estimated parameters
    for key in keys(params_ranges)
        if !(key in estimated_params)
            throw(ArgumentError("The parameter $key is not in the estimated parameters."))
        end
    end

    # sample from the ranges to get fasting glucose, insulin, TG and NEFA
    samples_characteristic = LHCoptim(n_patients, length(fasting_ranges), 100, rng = rng)[1] ./ n_patients
    
    lbx = [x[1] for x in values(fasting_ranges)].*(1+1e-9)
    ubx = [x[2] for x in values(fasting_ranges)].*(1-1e-9)
    characteristic_values = lbx .+ ((ubx .- lbx) .* samples_characteristic')
    # sample from params_ranges to get the parameters   
    samples_params = LHCoptim(n_patients, length(params_ranges), 100, rng = rng)[1] ./ n_patients
    lbx = [x[1] for x in values(params_ranges)].*(1+1e-9)
    ubx = [x[2] for x in values(params_ranges)].*(1-1e-9)
    parameter_values = lbx .+ ((ubx .- lbx) .* samples_params')

    # create the patients
    patients = [SyntheticPatient(
        EDES(
            characteristic_values[1,i],
            characteristic_values[2,i],
            G_dose,
            BW,
            estimated_params = estimated_params,
            timespan = timespan
        ),
        parameter_values[:,i],
        i,
    
    ) for i in 1:n_patients];

    return patients
end



"""
function that selects the glucose and insulin values at the selected time points from a patient with some added noise.

input:
- patient: SyntheticPatient
- time_points_G: time points to select glucose values
- time_points_I: time points to select insulin values
- variation_G
: variation in glucose values
- variation_I: variation in insulin values

output:
- glucose: glucose values at the selected time points
- insulin: insulin values at the selected time points

"""
function SelectTimePoints(
    patient::SyntheticPatient;
    time_points_G::AbstractVector{<:Real} = [0,15,30,60,120,180,240],
    time_points_I::AbstractVector{<:Real} = [0,15,30,60,120,180,240],
    variation_G::Real = 0.05,
    variation_I::Real = 0.1,
)
    # set time_points to correspond to indexes
    index_points_G = time_points_G .+ 1
    index_points_I = time_points_I .+ 1

    # get the parameter values
    parameter_values = patient.ParameterValues
    model = patient.EDES

    # make the full parameter vector
    full_parameter_vector = make_full_parameter_vector(model, parameter_values)

    # compute output
    outputs = output(model, full_parameter_vector)

    # select glucose, insulin, TG and NEFA at the selected time_points
    glucose = outputs.plasma_glucose[index_points_G]
    insulin = outputs.plasma_insulin[index_points_I]

    # add noise
    noise_glucose = rand() * (2 * variation_G
) + (1 - variation_G
)
    noise_insulin = rand() * (2 * variation_I) + (1 - variation_I)

    glucose = glucose .* noise_glucose
    insulin = insulin .* noise_insulin

    return [glucose, insulin]
end


function SelectTimePoints(
    patient::SyntheticPatient,
    parameter_values::AbstractVector,
    time_points::AbstractVector{<:Real};
    variation_G::Real = 0.05,
    variation_I::Real = 0.1,
)
    # set time_points to correspond to indexes
    index_points = time_points .+ 1

    # get the parameter values
    model = patient.EDES
    
    # make the full parameter vector
    full_parameter_vector = make_full_parameter_vector(model, parameter_values)

    # compute output
    outputs = output(model, full_parameter_vector)

    # select glucose, insulin, TG and NEFA at the selected time_points
    glucose = outputs.plasma_glucose[index_points]
    insulin = outputs.plasma_insulin[index_points]

    # add noise
    noise_glucose = rand() * (2 * variation_G) + (1 - variation_G)
    noise_insulin = rand() * (2 * variation_I) + (1 - variation_I)

    glucose = glucose .* noise_glucose
    insulin = insulin .* noise_insulin
    
    return [glucose, insulin]
end



function SelectTimePoints(
    model::EDES,
    parameter_values::AbstractVector;
    time_points_G::AbstractVector{<:Real} = [0,15,30,60,120,180,240],
    time_points_I::AbstractVector{<:Real} = [0,15,30,60,120,180,240],
    variation_G::Real = 0.05,
    variation_I::Real = 0.1,
)
    # set time_points to correspond to indexes
    index_points_G = time_points_G .+ 1
    index_points_I = time_points_I .+ 1

    # make the full parameter vector
    full_parameter_vector = make_full_parameter_vector(model, parameter_values)

    # compute output
    outputs = output(model, full_parameter_vector)

    # select glucose, insulin, TG and NEFA at the selected time_points
    glucose = outputs.plasma_glucose[index_points_G]
    insulin = outputs.plasma_insulin[index_points_I]

    # add noise
    noise_glucose = rand() * (2 * variation_G
) + (1 - variation_G
)
    noise_insulin = rand() * (2 * variation_I) + (1 - variation_I)

    glucose = glucose .* noise_glucose
    insulin = insulin .* noise_insulin
    

    return [glucose, insulin]
end

function SelectTimePoints(
    progression::SyntheticProgression,
    time_points_G::AbstractVector{<:Real} = [0,15,30,60,120,180,240],
    time_points_I::AbstractVector{<:Real} = [0,15,30,60,120,180,240];
    variation_G::Real = 0.05,
    variation_I::Real = 0.1,
)
    # set time_points to correspond to indexes
    index_points_G = time_points_G .+ 1
    index_points_I = time_points_I .+ 1

    # get the parameter values
    patient = progression.patient
    model = patient.EDES
    parameter_names = progression.parameter_names
    
    # make the full parameter vector
    full_parameter_vector = make_full_parameter_vector(model, progression.parameter_values)

    # compute output
    outputs = output(model, full_parameter_vector)

    # select glucose, insulin, TG and NEFA at the selected time_points
    glucose = outputs.plasma_glucose[index_points_G]
    insulin = outputs.plasma_insulin[index_points_I]

    # add noise
    noise_glucose = rand() * (2 * variation_G) + (1 - variation_G)
    noise_insulin = rand() * (2 * variation_I) + (1 - variation_I)

    glucose = glucose .* noise_glucose
    insulin = insulin .* noise_insulin

    return [glucose, insulin]

end