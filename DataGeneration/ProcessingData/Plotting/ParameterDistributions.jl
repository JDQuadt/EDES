


function plot_parameter_distributions(
    parameter_data::DataFrame,
    )

    parameter_names = names(parameter_data)
    n = length(parameter_names)


    # plot the parameter distributions
    GLMakie.scatter!(parameter_data[:,2],parameter_data[:,3], title= "Parameter Distributions", xlabel=parameter_names[2], ylabel=parameter_names[3], label="Parameter Distributions", legend=:topleft, markersize=2, color=:blue, alpha=0.5, grid=false, size=(800,800))

end