"""
function that returns the loss function for the parameter estimation

input:
* `model`: instance of the MixedMealModel
* `G_measurements`: vector of glucose measurements
* `G_timepoints`: vector of timepoints of the glucose measurements
* `I_measurements`: vector of insulin measurements
* `I_timepoints`: vector of timepoints of the insulin measurements
* `save_timestep`: time step for saving the model output (default: 1.0)

output:
* `LossFunction`: function that calculates the loss for the given parameters

"""
function make_LossFunction(
        model::EDES,
        G_measurements::AbstractVector, 
        G_timepoints::AbstractVector,
        I_measurements::AbstractVector,
        I_timepoints::AbstractVector ,
        save_timestep::Real = 1.0,
) 
    error_function = make_ErrorFunction(model, G_measurements, G_timepoints, I_measurements, I_timepoints, save_timestep)
    
    fixed_parameter_filter = .!relate_names_to_indices(model.estimated_params)
    fixed_parameters = model.prob.p[fixed_parameter_filter]
    fixed_parameters_indices = findall(fixed_parameter_filter)
    estimated_parameters_indices = findall(.!fixed_parameter_filter)
    order = sortperm([fixed_parameters_indices; estimated_parameters_indices])

    function LossFunction(estimated_parameters::AbstractVector)
        full_parameter_vector =  [fixed_parameters; estimated_parameters][order]
        model_output = output(model, full_parameter_vector, model.prob.tspan, save_timestep)

        error = error_function(model_output, full_parameter_vector)
        return error
    end
    return LossFunction
end 
"""

function that returns the error function for the parameter estimation

input:
* `model`: instance of the EDES model
* `G_measurements`: vector of glucose measurements
* `G_timepoints`: vector of timepoints of the glucose measurements
* `I_measurements`: vector of insulin measurements
* `I_timepoints`: vector of timepoints of the insulin measurements
* `save_timestep`: time step for saving the model output (default: 1.0)

output:
* `ErrorFunction`: function that calculates the error for the given parameters

"""
            
function make_ErrorFunction(model::EDES, G_measurements::AbstractVector, G_timepoints::AbstractVector, I_measurements::AbstractVector, I_timepoints::AbstractVector, save_timestep::Real = 1.0)
    # times
    times = model.prob.tspan[1]:save_timestep:model.prob.tspan[end]
    
    # extract indices of timepoints in the meal 
    indices_timepoints = [
        findall(x -> x in G_timepoints, times),
        findall(x -> x in I_timepoints, times),
    ]
    

    # timepoints
    G_dynamic_times = times[times .<= 240]
            
    function ErrorFunction(output,parameters)
        # define normalized loss for all four measurements
        glucose_loss = (output.plasma_glucose[indices_timepoints[1]] .- G_measurements) / maximum(G_measurements)
        insulin_loss = (output.plasma_insulin[indices_timepoints[2]] .- I_measurements) / maximum(I_measurements)
        
        # scaling term (ask Max for explanation of this term)
        scaling_term = maximum(G_measurements)
        fit_error = scaling_term .* [glucose_loss; insulin_loss] 
        

        # regularisation terms 
        BW = parameters[17]
        VG = (260/sqrt(BW/70))/1000
        f_G = 0.005551

        # AUC of the glucose in the gut should be very similar to the glucose dose
        AUC_norm_G_gut = ((BW*VG)/f_G) * trapz(G_dynamic_times, output.glucose_gut_to_plasma_flux[times .<= 240])
        error_AUC_G = abs((AUC_norm_G_gut - parameters[16])./10000)                                
        
        # Steady state of the plasma glucose should after some time (240 min) return to the fasting glucose
        error_steady_state_G = (parameters[13] - output.plasma_glucose[times .== 240][1])

        # combine regularisation terms
        regularisation_error = [error_AUC_G; error_steady_state_G]
        
        # calculate sum of squared errors
        
        total_error = sum(abs2,fit_error) + sum(abs2,regularisation_error)
        return total_error
    
    end
    return ErrorFunction
end