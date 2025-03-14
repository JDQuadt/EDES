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

    glucose_plot = Plots.plot(outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)")

    insulin_plot = Plots.plot(outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)")

    Glucose_from_gut_plot = Plots.plot(outputs.time, outputs.glucose_gut_to_plasma_flux, label = "glucose from gut", xlabel = "time (min)", ylabel = "glucose flux (mmol/min)")
    f_G = 0.005551 # conversion factor for glucose, from mg/l to mmol/l
    V_G = (260/sqrt(BW/70))/1000 # volume of distribution of glucose
    Auc_from_gut = ((V_G*BW)/f_G)*trapz(outputs.time, outputs.glucose_gut_to_plasma_flux)*0.001
    #println(Auc_from_gut)
    Plots.plot(glucose_plot, insulin_plot, layout = (1, 2),legend=false)
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

    glucose_plot =Plots.plot(outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)")
    scatter!(data.time, data.glc, label = "glucose_data")
    
    insulin_plot =Plots.plot(outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)")
    scatter!(data.time, data.ins, label = "insulin_data")

    
   Plots.plot(glucose_plot, insulin_plot, layout = (1, 2),legend=false)
end



function PlotMealResponse(
    model::EDES;
    full_params::AbstractVector{<:Real},
)

    # compute output
    outputs = output(model, full_params)

    glucose_plot =Plots.plot(outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)")
    
    insulin_plot =Plots.plot(outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)")
    
   Plots.plot(glucose_plot, insulin_plot, layout = (1, 2),legend=false)
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

    glucose_plot =Plots.plot(outputs.time, outputs.plasma_glucose, label = "glucose", xlabel = "time (min)", ylabel = "glucose (mmol/L)")
    
    insulin_plot =Plots.plot(outputs.time, outputs.plasma_insulin, label = "insulin", xlabel = "time (min)", ylabel = "insulin (uIU/mL)")
    
    Glucose_from_gut_plot =Plots.plot(outputs.time, outputs.glucose_gut_to_plasma_flux, label = "glucose from gut", xlabel = "time (min)", ylabel = "glucose flux (mmol/min)")
    f_G = 0.005551 # conversion factor for glucose, from mg/l to mmol/l
    V_G = (260/sqrt(BW/70))/1000 # volume of distribution of glucose
    Auc_from_gut = ((V_G*BW)/f_G)*trapz(outputs.time, outputs.glucose_gut_to_plasma_flux)*0.001

    Plots.plot(glucose_plot, insulin_plot, Glucose_from_gut_plot, layout = (1, 3),legend=false)
end

function PlotMealResponse(
    models::Vector{EDES},
    estimated_params_list::Vector{<:AbstractVector{<:Real}},
    timespan::Tuple{Real,Real} = (0.0, 240.0)
)

    # Create emptyPlots.plots
    glucose_plot =Plots.plot(xlabel = "time (min)", ylabel = "glucose (mmol/L)", title = "Glucose Response")
    insulin_plot =Plots.plot(xlabel = "time (min)", ylabel = "insulin (uIU/mL)", title = "Insulin Response")

    # Iterate over each model and parameter set
    for (i, (model, estimated_params)) in enumerate(zip(models, estimated_params_list))
        # Make the full parameter vector
        model
        full_parameter_vector = make_full_parameter_vector(model, estimated_params)
        # println(full_parameter_vector)

        # Compute outputs
        outputs = output(model, full_parameter_vector, timespan)

        # Add glucose and insulinPlots.plots for this model
       Plots.plot!(glucose_plot, outputs.time, outputs.plasma_glucose, label = "Patient $i")
       Plots.plot!(insulin_plot, outputs.time, outputs.plasma_insulin, label = "Patient $i")
    end

    # CombinePlots.plots into a single layout
    Plots.plot(glucose_plot, insulin_plot, layout = (1, 2), legend = false)
end


function PlotMealResponseProgression(
    model::EDES,
    parameter_names::AbstractVector{String},
    parameter_values::AbstractMatrix{<:Real},
    fasting_glucose::AbstractVector{<:Real},
    fasting_insulin::AbstractVector{<:Real},
    timespan::Tuple{Real,Real} = (0.0, 240.0),
)
    # Create empty plots
    glucose_plot =Plots.plot(xlabel = "time (min)", ylabel = "glucose (mmol/L)", title = "Glucose Response")
    insulin_plot =Plots.plot(xlabel = "time (min)", ylabel = "insulin (uIU/mL)", title = "Insulin Response")

       # Iterate over eachparameter set
       for (i, estimated_params) in enumerate(eachcol(parameter_values))
        # Make the full parameter vector
        full_parameter_vector = make_full_parameter_vector(model, parameter_names, estimated_params)

        # Update model.prob and the initial_state
        model.prob.p[13] = fasting_glucose[i]
        model.prob.p[14] = fasting_insulin[i]
        model.prob.u0= InitialState(fasting_glucose[i], fasting_insulin[i])
        # Compute outputs
        outputs = output(model, full_parameter_vector, timespan)

        # Add glucose and insulin plots for this model
       Plots.plot!(glucose_plot, outputs.time, outputs.plasma_glucose, label = "Measurement $i")
       Plots.plot!(insulin_plot, outputs.time, outputs.plasma_insulin, label = "Measurement $i")
    end

    # Combine plots into a single layout
    Plots.plot(glucose_plot, insulin_plot, layout = (1, 2), legend = true)
end