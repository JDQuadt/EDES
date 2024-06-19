function PlotMealResponse(
    model::EDES,
    estimated_params::AbstractVector{<:Real},
    timespan::Tuple{Real,Real} = (0.0, 240.0)
)
    # make the full parameter vector

    full_parameter_vector = make_full_parameter_vector(model, estimated_params)

    # compute output
    outputs = output(model, full_parameter_vector, timespan)

    glucose_plot = plot(outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)")

    insulin_plot = plot(outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)")

    plot(glucose_plot, insulin_plot, layout = (1, 2),legend=false, overwrite_figure = false)
end

function PlotMealResponse(
    model::EDES,
    estimated_params::AbstractVector{<:Real},
    data::NamedTuple
)

    # make the full parameter vector
    full_parameter_vector = make_full_parameter_vector(model, estimated_params)
    # compute output
    outputs = output(model, full_parameter_vector)

    glucose_plot = plot(outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)")
    scatter!(data.time, data.glc, label = "glucose_data")
    
    insulin_plot = plot(outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)")
    scatter!(data.time, data.ins, label = "insulin_data")

    
    plot(glucose_plot, insulin_plot, layout = (1, 2),legend=false)
end



function PlotMealResponse(
    model::EDES;
    full_params::AbstractVector{<:Real},
)
    # compute output
    outputs = output(model, full_params)

    glucose_plot = plot(outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)")
    
    insulin_plot = plot(outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)")
    
    plot(glucose_plot, insulin_plot, layout = (1, 2),legend=false)
end