"""
This file contains the rules for generating realistic synthetic meal responses. 
"""
# 1. Glucose should be back around fasting levels after 2 hours
# 2. 
function test_glucose_response(
    Glucose_response::AbstractVector{Real},
)
    # check that fasting value is under 5.5 mmol/L (ADA)
    if Glucose_response[1] > 5.5
        return false
    end

    # check that the peak value is under 8 mmol/L (ADA)
    if maximum(Glucose_response) > 11
        return false
    end

    # check that the value is back around fasting levels after 2 hours
    if Glucose_response[end] > 1.1*Glucose_response[1]
        return false
    end

    # check that values never go below 0
    if any(Glucose_response .< 0)
        return false
    end

    
end


function test_insulin_response(
    Insulin_response::AbstractVector{Real},
)


end

# TG is generally between 0.7 and 6.0 mmol/L
function test_TG_response(
    
)
end

#NEFA should not deviate drastic amounts from normal levels
function test_NEFA_response(
    
)
end


# peak detection is used to prevent oscillations, for glucose and insulin two peaks are allowed
function test_oscillation(
    
)
end




