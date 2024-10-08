"""
This file contains the rules for generating realistic synthetic meal responses. 
"""
function ensure_realism_initial(
    patient::SyntheticPatient
)
    # get the parameter values & model
    model = patient.EDES
    estimated_parameter_values = patient.ParameterValues

    # make the full parameter vector
    full_parameter_vector = make_full_parameter_vector(model, estimated_parameter_values)

    # compute output
    outputs = output(model, full_parameter_vector)

    # select glucose, insulin, TG and NEFA at the selected time_points
    glucose_response = outputs.plasma_glucose
    insulin_response = outputs.plasma_insulin

    # Glucose value must be increasing in the first half hour after meal
    if any(diff(glucose_response[1:30]) .< 0)
        println("Glucose value must be increasing in the first half hour after meal")
        return false
    end


    # check that the value is back around fasting levels after 4 hours
    if glucose_response[241] > 1.1*glucose_response[1]
        println("check that the value is back around fasting levels after 4 hours")
        return false
    end

    # Glucose dip should not get too low (not more than 20% below fasting value)
    if any(glucose_response .< 0.8*glucose_response[1])
        println("Glucose dip should not get too low (not more than 20% below fasting value)")
        return false
    end

    # Insulin must increase for halfhour after meal 
    if any(diff(insulin_response[1:30]) .< 0)
        println("Insulin must increase for halfhour after meal")
        return false
    end

    # insulin must be decreasing after 3 hours
    if any(diff(insulin_response[181:240]) .> 0)
        println("insulin must be decreasing after 3 hours")
        return false
    end

    return true
end

function ensure_realism_initial(
    glucose_response::AbstractVector{<:Real},
    insulin_response::AbstractVector{<:Real},
)

    # Glucose value must be increasing in the first half hour after meal
    if any(diff(glucose_response[1:30]) .< 0)
        println("Glucose value must be increasing in the first half hour after meal")
        return false
    end


    # check that the value is back around fasting levels after 4 hours
    if glucose_response[241] > 1.1*glucose_response[1]
        println("check that the value is back around fasting levels after 4 hours")
        return false
    end

    # Glucose dip should not get too low (not more than 20% below fasting value)
    if any(glucose_response .< 0.8*glucose_response[1])
        println("Glucose dip should not get too low (not more than 20% below fasting value)")
        return false
    end

    # Insulin must increase for first halfhour after meal 
    if any(diff(insulin_response[1:30]) .< 0)
        println("Insulin must increase for halfhour after meal")
        return false
    end

    # insulin must be decreasing after 3 hours
    if any(diff(insulin_response[181:240]) .> 0)
        println("insulin must be decreasing after 3 hours")
        return false
    end

    return true
end


function ensure_realism_initial(
    EDES_model::EDES,
    estimated_params::AbstractVector{<:Real},
)

    # make the full parameter vector
    full_parameter_vector = make_full_parameter_vector(EDES_model, estimated_params)

    # compute output
    outputs = output(EDES_model, full_parameter_vector)

    # select glucose & insulin
    glucose_response = outputs.plasma_glucose
    insulin_response = outputs.plasma_insulin
    # Glucose value must be increasing in the first half hour after meal
    if any(diff(glucose_response[1:30]) .< 0)
        println("Glucose value must be increasing in the first half hour after meal")
        return false
    end


    # check that the value is back around fasting levels after 4 hours
    if glucose_response[241] > 1.1*glucose_response[1]
        println("check that the value is back around fasting levels after 4 hours")
        return false
    end

    # Glucose dip should not get too low (not more than 20% below fasting value)
    if any(glucose_response .< 0.8*glucose_response[1])
        println("Glucose dip should not get too low (not more than 20% below fasting value)")
        return false
    end

    # Insulin must increase for first halfhour after meal 
    if any(diff(insulin_response[1:30]) .< 0)
        println("Insulin must increase for halfhour after meal")
        return false
    end

    # insulin must be decreasing after 3 hours
    if any(diff(insulin_response[181:240]) .> 0)
        println("insulin must be decreasing after 3 hours")
        return false
    end

    return true
end





