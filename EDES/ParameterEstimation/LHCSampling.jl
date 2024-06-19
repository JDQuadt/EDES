"""
Function that samples parameter sets using Latin Hypercube Sampling.

# Arguments
- `loss::Function`: The loss function to evaluate the parameter sets.
- `model::MixedMealModel`: The model used for parameter estimation.
- `n_points`: The number of LHC points to sample.
- `lb::AbstractVector{<:Real}`: The lower bounds for each parameter.
- `ub::AbstractVector{<:Real}`: The upper bounds for each parameter.
- `selection_ratio::Real`: The ratio of best sets to select (default is 0.1).

# Returns
- `best_parameter_sets`: The selected best parameter sets.
"""
function Preselection_LHS(
    loss::Function,
    model::EDES,
    n_points::Int,
    lb::AbstractVector{<:Real}, 
    ub::AbstractVector{<:Real}, 
    selection_ratio::Real = 0.1,
) 
    # Check if lower bounds vector has the same length as upper bounds vector
    if length(lb) != length(ub) || length(lb) != length(model.estimated_params)
        throw(ArgumentError("Lower bounds vector and upper bounds vector must have the same length and that length has to be the same as the number of parameters."))
    end

    # Generate LHS samples between the lb and ub 
    parameter_samples = QuasiMonteCarlo.sample(n_points, lb, ub, LatinHypercubeSample())

    initial_losses = []
    for i in axes(parameter_samples,2)
        try 
            loss_instance = loss(parameter_samples[:,i])
            push!(initial_losses, loss_instance)
        catch e
            push!(initial_losses, Inf)
        end
    end

    # define the number of best sets to select
    n_best_sets = floor(Int,n_points * selection_ratio)
    
    # select the best sets
    best_sets_indices = partialsortperm(initial_losses,1:n_best_sets)
    best_parameter_sets = parameter_samples[:,best_sets_indices]

    return best_parameter_sets
end
