function ParameterEstimation(
    glucose::AbstractArray,
    insulin::AbstractArray,
    BW::Real,
    meal_G::Real,
    time_G::AbstractVector,
    time_I::AbstractVector;
    estimated_params::AbstractVector{String} = ["k1","k5","k6", "k8"], 
    ub::AbstractVector = [0.5, 1.5, 10., 20.],
    lb::AbstractVector =  [0.0005, 0, 0, 0.], 
    save_boolean::Bool = false,
    file_name::String = "parameter_set.csv",
    )
    # make MixedMeal model
    model  = EDES(glucose[1], insulin[1], meal_G, BW, estimated_params = estimated_params)
    # make loss function
    loss = make_LossFunction(model, glucose, time_G, insulin, time_I)

    # create preselected samples
    initial_parameter_sets = Preselection_LHS(loss, model, 100, lb, ub)

    # create optimizer
    optimizer = LBFGS(linesearch = BackTracking(order=3)) # cubic interpolation

    objectives = []
    parameters = []
    # run the optimization for each initial parameter set
    for it in axes(initial_parameter_sets,2)
        try 
            # run the optimization
            optf = OptimizationFunction((x,p)-> loss(x), Optimization.AutoForwardDiff())
            starting_parameters = initial_parameter_sets[:,it]
            optprob = OptimizationProblem(optf, starting_parameters, lb = lb, ub = ub)
            sol = Optimization.solve(optprob, optimizer);
            # save the results
            push!(parameters, sol.u)
            push!(objectives, sol.objective)
            
        catch e
            println(e)
            println("Optimization FAILED for this initial set, continuing...")
        end
    end

    if isempty(objectives)
        println("Optimization failed for all initial parameter sets. No parameters were estimated.")
        return
    end
    # find the best solution and select the parameters
    println("Optimization successful for this initial set, continuing...")
    best_index = argmin(objectives)
    best_parameters = parameters[best_index]

    if save_boolean
        df_parameters = DataFrame(best_parameters_every_individual, :auto)
        rename!(df_parameters, Symbol.(estimated_params))
        CSV.write(file_name, df_parameters)
    end
    println("Parameter estimation done!")

    return best_parameters


end
