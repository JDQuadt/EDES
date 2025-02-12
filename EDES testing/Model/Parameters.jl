"""
Parameters:
function that generates the initial parameters of the model, set to population average values.

input:
- fasting_glucose: fasting glucose in plasma
- fasting_insulin: fasting insulin in plasma
- meal_glucose_mass: mass of glucose in the meal
- meal_TG_mass: mass of triglycerides in the meal
- body_weight: body weight of the individual
- All other parameters are the model parameters
output:
- parameters: vector of model parameters
"""	
function Parameters(
    fasting_glucose::Real, 
    fasting_insulin::Real,
    G_dose::Real = 75.0,
    body_weight::Real = 70.0; 
    k1 = 0.0105,  # k1 rate constant for glucose stomach emptying (fast)[1/min]
    k2 = 0.28,     # k2 rate constant for glucose appearence from gut [1/min]
    k3 = 6.07e-3,  # k3 rate constant for suppression of hepatic glucose release by change of plasma glucose [1/min]
    k4 = 2.35e-4,  # k4 rate constant for suppression of hepatic glucose release by delayed (remote) insulin [1/min]
    k5 = 0.0424,   # k5 rate constant for delayed insulin dependent uptake of glucose [1/min]
    k6 = 2.2975,   # k6 rate constant for stimulation of insulin production by the change of plasma glucose concentration (beta cell funtion) [1/min]
    k7 =  1.15,     # k7 rate constant for integral of glucose on insulin production (beta cell function) [1/min]
    k8 = 7.27,    # k8 rate constant for the simulation of insulin production by the rate of change in plasma glucose concentration (beta cell function) [1/min]
    k9 = 3.83e-2,  # k9 rate constant for outflow of insulin from plasma to interstitial space [1/min]
    k10 = 2.84e-1, # k10 rate constant for degredation of insulin in remote compartment [1/min]
    sigma = 1.4,   # sigma shape factor (appearance of meal)
    Km = 13.2,     # Km michaelis-menten coefficient for glucose uptake
    G_b = fasting_glucose, # G_b basal plasma glucose [mmol/l]
    I_pl_b = fasting_insulin, # I_PL/_b basal plasma insulin [microU/ml]
    G_liv_b = 0.043,    # basal hepatic glucose release [mmol/l/min]
)
  parameters = [
    k1, k2, k3, k4, k5, k6, k7, k8, k9, k10, sigma, Km, G_b, I_pl_b, G_liv_b, G_dose, body_weight,
  ]
  
  return parameters
end
