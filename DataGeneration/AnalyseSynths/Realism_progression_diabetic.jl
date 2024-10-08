"""
This script is used to analyse a single individual's progression towards a diabetic state. 
"""

function ensure_realism_diabetic(
    glucose_responses::AbstractMatrix{<:Real},
    insulin_responses::AbstractMatrix{<:Real},
    long_time_points::AbstractVector{<:Real}
)
    # Glucose peak must be higher every measurement
    if any(diff(maximum(glucose_responses, dims=2), dims=1) .< 0)
        println("Glucose peak must be higher every measurement")
        return false
    end
    # Total of the glucose response summed must be increasing

    if any(diff(sum(glucose_responses, dims=2), dims=1) .< 0)
        println("Total of the glucose response summed must be increasing")
        return false
    end

    # Insulin peak has to come later every measurement
    if any(diff(maximum(insulin_responses, dims=2), dims=1) .< 0)
        println("Insulin peak has to come later every measurement")
        return false
    end




    return true 
end