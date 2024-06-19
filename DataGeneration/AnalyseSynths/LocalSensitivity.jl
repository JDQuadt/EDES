function LocalSensitivityAnalysis(
    patient::SyntheticPatient,
    parameter_names::AbstractVector{String} = ["k1", "k2", "k3", "k4", "k5", "k6", "k7", "k8", "k9", "k10", "sigma", "Km", "G_b", "I_pl_b", "G_liv_b"],
    parameter_indices::AbstractVector{Int} = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
    spread::Real = 0.8, # 50%
    n_points::Int = 30,
)
    # extract the model and parameter values
    model = deepcopy(patient.EDES)
    estimated_params = copy(patient.ParameterValues)

    original_parameter_values = make_full_parameter_vector(model, estimated_params)

    # loop over selected parameters
    for (x,i) in enumerate(parameter_indices)
        # set the parameter value
        parameter_value = deepcopy(original_parameter_values[i])

        # set the range of the parameter
        range_value = parameter_value * spread

        # set lowerbound and upperbound
        lowerbound = parameter_value - range_value
        upperbound = parameter_value + range_value

        # make a matrix of parameter values and assign the new parameter values
        parameter_matrix = repeat(original_parameter_values, 1, n_points)
        parameter_matrix[i,:] = range(lowerbound, upperbound, length = n_points)
        # set up figure 
        combined_plot = plot(layout=(1,2), legend=false, size=(800,800))
        # define a color gradient from blue to yellow
        color_gradient = cgrad([:yellow, :black], n_points)

        # loop over the parameter values
        for j in 1:n_points
            # set the parameter values
            parameter_values_now = parameter_matrix[:,j]
            
            # set a copied model
            model_copy = deepcopy(model)
            # set the parameters
            model_copy.prob.p .= parameter_values_now
            
            # compute model output & plot
            outputs = output(model_copy, parameter_values_now)

            # plot glucose with color gradient
            if j == n_points ÷ 2
                plot!(combined_plot[1,1], outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)", linecolor = :green)
                plot!(combined_plot[1,2], outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)", linecolor = :green)
            else
                plot!(combined_plot[1,1], outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)", linecolor = color_gradient[j])
                plot!(combined_plot[1,2], outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)", linecolor = color_gradient[j])
            end
        end
        savefig(combined_plot, "./Storage/LocalSensitivityAnalysis_$(parameter_names[x]).png")
    end
end




function LocalSensitivityAnalysis(
    og_model::EDES,
    og_estimated_params::AbstractVector{<:Real},
    parameter_names::AbstractVector{String} = ["k1", "k2", "k3", "k4", "k5", "k6", "k7", "k8", "k9", "k10", "sigma", "Km", "G_b", "I_pl_b", "G_liv_b"],
    parameter_indices::AbstractVector{Int} = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
    spread::Real = 0.5, # 50%
    n_points::Int = 30,
)
    # extract the model and parameter values
    model = deepcopy(og_model)
    estimated_params = copy(og_estimated_params)

    original_parameter_values = make_full_parameter_vector(model, estimated_params)

    # loop over selected parameters
    for (x,i) in enumerate(parameter_indices)
        # set the parameter value
        parameter_value = deepcopy(original_parameter_values[i])

        # set the range of the parameter
        range_value = parameter_value * spread

        # set lowerbound and upperbound
        lowerbound = parameter_value - range_value
        upperbound = parameter_value + range_value

        # make a matrix of parameter values and assign the new parameter values
        parameter_matrix = repeat(original_parameter_values, 1, n_points)
        parameter_matrix[i,:] = range(lowerbound, upperbound, length = n_points)
        # set up figure 
        combined_plot = plot(layout=(1,2), legend=false, size=(800,800))
        # define a color gradient from blue to yellow
        color_gradient = cgrad([:yellow, :black], n_points)

        # loop over the parameter values
        for j in 1:n_points
            # set the parameter values
            parameter_values_now = parameter_matrix[:,j]
            
            # set a copied model
            model_copy = deepcopy(model)
            # set the parameters
            model_copy.prob.p .= parameter_values_now
            
            # compute model output & plot
            outputs = output(model_copy, parameter_values_now)

            # plot glucose with color gradient
            if j == n_points ÷ 2
                plot!(combined_plot[1,1], outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)", linecolor = :green)
                plot!(combined_plot[1,2], outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)", linecolor = :green)
            else
                plot!(combined_plot[1,1], outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)", linecolor = color_gradient[j])
                plot!(combined_plot[1,2], outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)", linecolor = color_gradient[j])
            end
        end
        savefig(combined_plot, "./Storage/LocalSensitivityAnalysis_$(parameter_names[x]).png")
    end
end