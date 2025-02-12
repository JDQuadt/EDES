"""
function that relates the parameter names to the indices in the parameter vector

input:
* `estimated_params`: vector of the names of the parameters to be estimated

output:
* `indices`: vector of indices of the estimated parameters in the parameter vector
"""
function relate_names_to_indices(estimated_params::AbstractVector{String})
    parameters_to_find = length(estimated_params)
    indices = [i ∈ estimated_params for i in ["k1","k2","k3","k4","k5","k6","k7","k8","k9","k10","sigma","Km","G_b","I_pl_b","G_liv_b", "G_dose", "body_weight"]]
    if sum(indices) != parameters_to_find
        throw(ArgumentError("Not found all parameters in the model. Check the parameter names."))
    else
        return indices
    end
  end

"""
function that generates a full parameter vector by adding the estimated parameters and the fixed parameters

input:
* `estimated_parameters`: vector of the estimated parameters
* `model`: instance of the EDES model

output:
* `full_parameter_vector`: vector containg all numerical values of the parameters in the model
"""

function make_full_parameter_vector(model::EDES, estimated_parameter_values::AbstractVector)
    estimated_parameter_names = model.estimated_params
    fixed_parameters = model.prob.p
    estimated_parameter_indices = relate_names_to_indices(estimated_parameter_names)
    full_parameter_vector = fixed_parameters

    full_parameter_vector[estimated_parameter_indices] .= estimated_parameter_values

    return full_parameter_vector	
end

function make_full_parameter_vector(parameter_names::AbstractVector{String}, parameter_values::AbstractVector)
    estimated_parameter_indices = relate_names_to_indices(parameter_names)
    full_parameter_vector = model.prob.p
    full_parameter_vector[estimated_parameter_indices] .= parameter_values

    return full_parameter_vector	
end
