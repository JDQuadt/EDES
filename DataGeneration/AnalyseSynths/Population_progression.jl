"""
This file contains the algorithm that generates a progression to a realistic diabetic or healthy state. 
It tries to make a realistic progression for a synthetic patient population by varying the changes to k5 and k6. It tries to find a progression that 
works for at least the half of the population. If there is no such progression it will try to vary other sensitive parameters iteratively 20% from 
their population average value. 
"""

function generate_progression(
    synthetic_patient_population::AbstractVector{<:SyntheticPatient},
    health_status_vector::AbstractVector{<:Int}, # Vector of integeres, 0 for healthy, 1 for diabetic
    long_time_points::AbstractVector{<:Real} = [0,1,2,3,4,5], # time points for the long term progression, 0 should be included
    glucose_time_points::AbstractVector{<:Real} = [0,15,30,60,120,180,240], # time points for the glucose response
    insulin_time_points::AbstractVector{<:Real} = [0,15,30,60,120,180,240], # time points for the insulin response
    k5_linear_bounds::AbstractVector{<:Real} = [0.1, 0.5], # linear bounds for k5
    k6_linear_bounds::AbstractVector{<:Real} = [0.1, 0.5], # linear bounds for k6
    k6_quadratic_bounds::AbstractVector{<:Real} = [0.1, 0.5], # quadratic bounds for k6
    Sensitive_parameter_names = ["k1","k3", "k7", "k9", "k10"], 
    maxiter::Int = 1000, # maximum number of iterations
)
    # initialise progression
    IDs = zeros(length(synthetic_patient_population), length(long_time_points)) 
    acceptable_progression = false
    while acceptable_progression == false 
        for i in axes(synthetic_patient_population, 1)
            health_status = health_status_vector[i]
            synthetic_patient =  synthetic_patient_population[i]

            # change k5 and k6 values
            k5s, k6s, Gbs, I_pl_bs = DiabeticProgression(synthetic_patient,long_time_points,   )



        end
    end
end