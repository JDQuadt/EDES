"""
Struct containing both the ODE problem and the estimated parameters for the mixed meal model.
"""
mutable struct EDES
    prob::ODEProblem
    estimated_params::AbstractVector{String}
end


"""
EDES model for simulating glucose, insulin in plasma after a OGTT.

input:
- fasting_glucose: fasting glucose in plasma (first time point of the data) (in mmol/L)
- fasting_insulin: fasting insulin in plasma (in uIU/mL)
- G_dose: mass of glucose in the meal
- BW: body weight of the individual
- timespan: tuple of the start and end time of the simulation (default: (0.0, 480.0))
- estimated_params: vector of the names of the parameters to be estimated (default: ["k1","k5","k6","k11","k12","tau_LPL","k14","k16"])
or
- params: named tuple of the meal response data
or
- params: vector of the meal response data

output:
- * prob: ODE problem for the EDES model
- * estimated_params: vector of the names of the parameters to be estimated
"""
function EDES(
    fasting_glucose::Real = 5.5,
    fasting_insulin::Real = 18.,
    G_dose::Real = 75000.0,
    BW::Real = 70.0;
    estimated_params::AbstractVector{String} = ["k1","k5","k6"],
    timespan::Tuple{Real,Real} = (0.0, 240.0),
)
    # check if the estimated parameters are in the model
    sanity_check = relate_names_to_indices(estimated_params)

    # create the initial state and parameters
    initial_state::Vector{<:Real} = InitialState(fasting_glucose, fasting_insulin)
    parameters = Parameters(fasting_glucose, fasting_insulin, G_dose, BW)

    # create the ODE problem
    prob = ODEProblem(ODEs(), initial_state, timespan, parameters);
    
    return EDES(prob,estimated_params)
end

