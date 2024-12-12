function PlotMealResponse(
    model::EDES,
    estimated_params::AbstractVector{<:Real},
    timespan::Tuple{Real,Real} = (0.0, 240.0)
)
    # make the full parameter vector

    full_parameter_vector = make_full_parameter_vector(model, estimated_params)
    BW = full_parameter_vector[end]
    # compute output
    outputs = output(model, full_parameter_vector, timespan)

    glucose_plot = plot(outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)")

    insulin_plot = plot(outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)")

    Glucose_from_gut_plot = plot(outputs.time, outputs.glucose_gut_to_plasma_flux, label = "glucose from gut", xlabel = "time (min)", ylabel = "glucose flux (mmol/min)")
    f_G = 0.005551 # conversion factor for glucose, from mg/l to mmol/l
    V_G = (260/sqrt(BW/70))/1000 # volume of distribution of glucose
    Auc_from_gut = ((V_G*BW)/f_G)*trapz(outputs.time, outputs.glucose_gut_to_plasma_flux)*0.001
    #println(Auc_from_gut)
    plot(glucose_plot, insulin_plot, layout = (1, 2),legend=false)
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

function PlotMealResponse(
    estimated_params_names::AbstractVector{},
    estimated_params_values::AbstractVector{<:Real},
    fasting_glucose::Real = 5.5,
    fasting_insulin::Real = 18.,
)
    # make the model 
    model = EDES(fasting_glucose, fasting_insulin, estimated_params = estimated_params_names, )
    
    # make the full parameter vector
    full_params = make_full_parameter_vector(model, estimated_params_values)
    BW = full_params[end]
    # compute output
    outputs = output(model, full_params)

    glucose_plot = plot(outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)")
    
    insulin_plot = plot(outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)")
    
    Glucose_from_gut_plot = plot(outputs.time, outputs.glucose_gut_to_plasma_flux, label = "glucose from gut", xlabel = "time (min)", ylabel = "glucose flux (mmol/min)")
    f_G = 0.005551 # conversion factor for glucose, from mg/l to mmol/l
    V_G = (260/sqrt(BW/70))/1000 # volume of distribution of glucose
    Auc_from_gut = ((V_G*BW)/f_G)*trapz(outputs.time, outputs.glucose_gut_to_plasma_flux)*0.001
    println(Auc_from_gut)
    plot(glucose_plot, insulin_plot, Glucose_from_gut_plot, layout = (1, 3),legend=false)
end