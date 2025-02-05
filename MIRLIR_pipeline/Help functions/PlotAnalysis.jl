"""
This function generates interactive plots for meal response data using GLMakie

# Arguments
- `parameters::DataFrame`: A DataFrame containing the estimated model parameters.
.....

# Returns
- `accepted::Array{Bool}`: An array indicating whether each plot is accepted or rejected.

"""

function Interactive_plots_EDES(
    parameters::DataFrame,
    glucose::AbstractMatrix,
    insulin::AbstractMatrix,
    BW::AbstractVector,
    time_G::AbstractVector,
    time_I::AbstractVector;
    G_dose::Real = 75000.0,



)
    
    # generate all the models for the data
    models = [EDES(
        glucose[i,1],
        insulin[i,1],
        G_dose,
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

    # plot the model fits
    lines!(ax_glucose, @lift(outputs[$i].plasma_glucose), color = @lift($accepted[$i] ? :lightgreen : :red))
    lines!(ax_insulin, @lift(outputs[$i].plasma_insulin), color = @lift($accepted[$i] ? :lightgreen : :red))

    # plot the data points
    GLMakie.scatter!(ax_glucose, time_G, @lift(glucose[$i, :]), color = :black)
    GLMakie.scatter!(ax_insulin, time_I, @lift(insulin[$i, :]), color = :black)

    # create a subgridlayout for the buttons
    subgl = GridLayout(f[2, 1:2], tellwidth = false)

    # create a previous button to go to the previous plot
    prevbutton = Button(subgl[1, 1], label = "Prev")
    on(prevbutton.clicks) do _
        i[] = mod1(i[] - 1, n)
        reset_limits!(ax_glucose)
        reset_limits!(ax_insulin)
    end

    # show which plot is currently being displayed
    Label(subgl[1, 2], @lift("Fit $($i)"))

    # create a next button to go to the next plot
    nextbutton = Button(subgl[1, 3], label = "Next")
    on(nextbutton.clicks) do _
        i[] = mod1(i[] + 1, n)
        reset_limits!(ax_glucose)
        reset_limits!(ax_insulin)
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
