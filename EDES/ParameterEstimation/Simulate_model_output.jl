function output(model::EDES, parameters::AbstractVector, timespan::Tuple{Real,Real} = (0.0, 240.0), saveat::Real = 1.0)
    #model.prob.tspan = timespan
    solution = solve(model.prob, Tsit5(), p=parameters,  saveat=saveat, verbose=false);

    generate_trajectories(solution, parameters)
end

function output(model::EDES, timespan::Tuple{Real,Real} = (0.0, 240.0) ,saveat::Real = 1.0)
    prob = model.prob
    solution = solve(prob, Tsit5(), saveat=saveat, verbose=false);
    generate_trajectories(solution, prob.p)
end
"""
function to generate the trajectories that are interesting to the user

input:
- solution: solution of the ODE problem
- parameters: vector of model parameters

output:
- dictionary with the following keys:
    - time: time points of the solution
    - glucose_gut_to_plasma_flux: flux of glucose from the gut to the plasma
    - hepatic_glucose_flux: hepatic glucose flux
    - glucose_tissue_uptake: glucose uptake into tissue
    - plasma_glucose: glucose concentration in plasma
    - plasma_insulin: insulin concentration in plasma
"""
function generate_trajectories(solution,parameters)

    states = Array(solution)
    
    # extract body weight
    BW = parameters[17]

    # check these factors match with the dimensions of input data
    fG = 0.005551 # conversion factor for glucose, from mg/l to mmol/l
    fI = 1.     # conversion factor for insulin, from uIU/ml to mmol/l
    VG = (260/sqrt(BW/70))/1000 # volume of distribution of glucose

     # glucose flux from the gut into the plasma
    glucose_plasma_flux = parameters[2] * (fG / (BW * VG)) .* states[1,:]

    # hepatic glucose flux
    hepatic_glucose_flux = parameters[15] .- (parameters[4] * fI) .* states[5, :] .- parameters[3] .* (states[2,:] .- parameters[13])

    # glucose uptake into tissue
    
    insulin_independent = parameters[15] .* ((parameters[12] .+ parameters[13]) .* states[2, :]) ./ (parameters[13] * (parameters[12] .+ states[2, :]))
    insulin_dependent = states[5,:] .* states[2, :] .* (parameters[5] ./ (parameters[12] .+ states[2, :]))

    glucose_uptake = insulin_dependent .+ insulin_independent


    return (
        time = solution.t,
        glucose_gut_to_plasma_flux = glucose_plasma_flux,
        hepatic_glucose_flux = hepatic_glucose_flux,
        glucose_tissue_uptake = glucose_uptake,
        plasma_glucose = states[2, :],
        plasma_insulin = states[4, :],
    )
end