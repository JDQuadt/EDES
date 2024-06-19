"""
This function generates interactive plots for meal response data using GLMakie

# Arguments
- `parameters::DataFrame`: A DataFrame containing the estimated model parameters.
- `response_data::NamedTuple`: A NamedTuple containing the meal response data.

# Returns
- `accepted::Array{Bool}`: An array indicating whether each plot is accepted or rejected.

"""
function Interactive_plots_NutriTech(
    parameters::DataFrame,
    response_data::NamedTuple,
)
    # extract the meal response data
    glucose_points = response_data.glucose
    time_G = response_data.time_G
    insulin_points = response_data.insulin
    time_I = response_data.time_I
    TG_points = response_data.TG
    time_TG = response_data.time_TG
    NEFA_points = response_data.NEFA
    time_NEFA = response_data.time_NEFA
    G_dose = response_data.meal_G
    TG_dose = response_data.meal_TG
    BW = response_data.BW
    
    # generate all the models for the data
    models = [MixedMealModel(
        glucose_points[i,1],
        insulin_points[i,1],
        TG_points[i,1],
        NEFA_points[i,1],
        G_dose,
        TG_dose,
        BW[i],
        estimated_params = String.(names(parameters)),
    ) for i in 1:nrow(parameters)]

    # generate the full model parameters
    full_parameter_vectors = [make_full_parameter_vector(models[i], Vector(parameters[i, :])) for i in 1:nrow(parameters)]

    outputs = [output(models[i], full_parameter_vectors[i]) for i in 1:nrow(parameters)]

    # determine how many plots we need and set up the accepted observable
    n = nrow(parameters)
    #fits = [Fit(cumsum(randn(n))) for _ in 1:n]
    accepted = Observable(zeros(Bool, n))
    
    # set up the figure and an observable for moving between plots (patients)
    f = Figure(size = (800, 800))
    i = Observable(1)
    
    # Create the axes
    ax_glucose = Axis(f[1, 1], title = "Glucose" , ylabel = "concentration (mmol/L)")
    ax_insulin = Axis(f[1, 2], title = "Insulin" )
    ax_TG = Axis(f[2, 1], title = "TG", xlabel ="time (min)", ylabel = "concentration (mmol/L)")
    ax_NEFA = Axis(f[2, 2], title = "NEFA", xlabel ="time (min)")

    # plot the model fits
    lines!(ax_glucose, @lift(outputs[$i].plasma_glucose), color = @lift($accepted[$i] ? :lightgreen : :red))
    lines!(ax_insulin, @lift(outputs[$i].plasma_insulin), color = @lift($accepted[$i] ? :lightgreen : :red))
    lines!(ax_TG, @lift(outputs[$i].plasma_TG), color = @lift($accepted[$i] ? :lightgreen : :red))
    lines!(ax_NEFA, @lift(outputs[$i].plasma_NEFA), color = @lift($accepted[$i] ? :lightgreen : :red))

    # plot the data points
    scatter!(ax_glucose, time_G, @lift(glucose_points[$i, :]), color = :black)
    scatter!(ax_insulin, time_I, @lift(insulin_points[$i, :]), color = :black)
    scatter!(ax_TG, time_TG, @lift(TG_points[$i, :]), color = :black)
    scatter!(ax_NEFA, time_NEFA, @lift(NEFA_points[$i, :]), color = :black)

    # create a subgridlayout for the buttons
    subgl = GridLayout(f[3, 1:2], tellwidth = false)

    # create a previous button to go to the previous plot
    prevbutton = Button(subgl[1, 1], label = "Prev")
    on(prevbutton.clicks) do _
        i[] = mod1(i[] - 1, n)
        reset_limits!(ax_glucose)
        reset_limits!(ax_insulin)
        reset_limits!(ax_TG)
        reset_limits!(ax_NEFA)
    end

    # show which plot is currently being displayed
    Label(subgl[1, 2], @lift("Fit $($i)"))

    # create a next button to go to the next plot
    nextbutton = Button(subgl[1, 3], label = "Next")
    on(nextbutton.clicks) do _
        i[] = mod1(i[] + 1, n)
        reset_limits!(ax_glucose)
        reset_limits!(ax_insulin)
        reset_limits!(ax_TG)
        reset_limits!(ax_NEFA)
    end
    
    # create a button to accept/reject the current plot
    togglebutton = Button(subgl[1, 4], label = @lift($accepted[$i] ? "Reject" : "Accept"))
    on(togglebutton.clicks) do _
        accepted.val[i[]] =! accepted.val[i[]]
        notify(accepted)
    end

    # display the figure
    display(f)
    

    return to_value(accepted)

end

"""
This function generates interactive plots for meal response data using GLMakie for the PREDICT study

# Arguments
- `parameters::DataFrame`: A DataFrame containing the estimated model parameters.
- `response_data::DataFrame`: A DataFrame containing the meal response data.
- `G_dose::Real`: The glucose dose in mg.
- `TG_dose::Real`: The TG dose in mg.
- `BW::Real`: The body weight in kg (population average).
- `time_G::Vector`: The time points for the glucose data.
- `time_I::Vector`: The time points for the insulin data.
- `time_TG::Vector`: The time points for the TG data.

# Returns
- `accepted::Array{Bool}`: An array indicating whether each plot is accepted or rejected.

"""

function Interactive_plots_PREDICT(
    parameters::DataFrame,
    response_data::DataFrame;
    G_dose::Real = 86000.0,
    TG_dose::Real = 53000.0,
    BW::Real = 72.88,
    time_G::AbstractVector = [0, 15, 30, 60 , 120, 180, 240],
    time_I::AbstractVector = [0, 15, 30, 60 , 120, 240],
    time_TG::AbstractVector = [0, 60 , 120, 180, 240],
)
    # extract the meal response data
    glucose_points = response_data[:, 2:8]
    insulin_points = response_data[:, 9:14]
    TG_points =response_data[:, 15:19]
    
    # generate all the models for the data
    models = [MixedMealModel(
        fasting_glucose = glucose_points[i,1],
        fasting_insulin = insulin_points[i,1],
        fasting_TG = TG_points[i,1],
        G_dose = G_dose,
        TG_dose = TG_dose,
        BW = BW,
        estimated_params = String.(names(parameters)),
    ) for i in 1:nrow(parameters)]

    # generate the full model parameters
    full_parameter_vectors = [make_full_parameter_vector(models[i], Vector(parameters[i, :])) for i in 1:nrow(parameters)]

    outputs = [output(models[i], full_parameter_vectors[i]) for i in 1:nrow(parameters)]

    # determine how many plots we need and set up the accepted observable
    n = nrow(parameters)
    #fits = [Fit(cumsum(randn(n))) for _ in 1:n]
    accepted = Observable(zeros(Bool, n))
    
    # set up the figure and an observable for moving between plots (patients)
    f = Figure(size = (800, 800))
    i = Observable(1)
    
    # Create the axes
    ax_glucose = Axis(f[1, 1], title = "Glucose" , ylabel = "concentration (mmol/L)")
    ax_insulin = Axis(f[1, 2], title = "Insulin" )
    ax_TG = Axis(f[2, 1], title = "TG", xlabel ="time (min)", ylabel = "concentration (mmol/L)")
    ax_NEFA = Axis(f[2, 2], title = "NEFA", xlabel ="time (min)")

    # plot the model fits
    lines!(ax_glucose, @lift(outputs[$i].plasma_glucose), color = @lift($accepted[$i] ? :lightgreen : :red))
    lines!(ax_insulin, @lift(outputs[$i].plasma_insulin), color = @lift($accepted[$i] ? :lightgreen : :red))
    lines!(ax_TG, @lift(outputs[$i].plasma_TG), color = @lift($accepted[$i] ? :lightgreen : :red))
    lines!(ax_NEFA, @lift(outputs[$i].plasma_NEFA), color = @lift($accepted[$i] ? :lightgreen : :red))

    # plot the data points
    scatter!(ax_glucose, time_G, @lift(Vector{Float64}(glucose_points[$i, :])), color = :black)
    scatter!(ax_insulin, time_I, @lift(Vector{Float64}(insulin_points[$i, :])), color = :black)
    scatter!(ax_TG, time_TG, @lift(Vector{Float64}(TG_points[$i, :])), color = :black)

    # create a subgridlayout for the buttons
    subgl = GridLayout(f[3, 1:2], tellwidth = false)

    # create a previous button to go to the previous plot
    prevbutton = Button(subgl[1, 1], label = "Prev")
    on(prevbutton.clicks) do _
        i[] = mod1(i[] - 1, n)
        reset_limits!(ax_glucose)
        reset_limits!(ax_insulin)
        reset_limits!(ax_TG)
        reset_limits!(ax_NEFA)
    end

    # show which plot is currently being displayed
    Label(subgl[1, 2], @lift("Fit $($i)"))

    # create a next button to go to the next plot
    nextbutton = Button(subgl[1, 3], label = "Next")
    on(nextbutton.clicks) do _
        i[] = mod1(i[] + 1, n)
        reset_limits!(ax_glucose)
        reset_limits!(ax_insulin)
        reset_limits!(ax_TG)
        reset_limits!(ax_NEFA)
    end
    
    # create a button to accept/reject the current plot
    togglebutton = Button(subgl[1, 4], label = @lift($accepted[$i] ? "Reject" : "Accept"))
    on(togglebutton.clicks) do _
        accepted.val[i[]] =! accepted.val[i[]]
        notify(accepted)
    end

    # display the figure
    display(f)
    

    return to_value(accepted)

end