"""
Jesse Quadt, 1416367
Rozendaal 2018 version of the EDES model describing the glucose-Insulin system in humans after an OGTT.

Inputs:
* `constants`: NamedTuple, containing the model constants with the following fields:
    * `f_G: Real`, the fraction of glucose that is absorbed from the gut
    * `f_TG: Real`, the fraction of triglyceride that is absorbed from the gut
    * `f_I: Real`, the fraction of insulin that is absorbed from the gut
    * `V_G: Real`, the volume of distribution of glucose
    * `V_TG: Real`, the volume of distribution of triglyceride
    * `τ_i: Real`, the time constant of insulin action
    * `τ_d: Real`, the time constant of glucose action
    * `G_threshold_pl: Real`, the threshold plasma glucose concentration
    * `t_int: Real`, the time of insulin action
    * `c1: Real`, the renal extraction of plasma glucose

* `meal_data`: NamedTuple, containing the meal data with the following fields:
    * `G_dose: Real`, the glucose dose of the meal
    * `TG_dose: Real`, the triglyceride dose of the meal

* `body_weight`: Real, the body weight of the individual

Outputs:
* `system!`: function, the ODE system of the model
    * Signature: `system!(D, u, p, t)`
        - `D`: Derivatives
        - `u`: State variables
        - `p`: Parameters
        - `t`: Time
"""

# Define global model constants
const f_G = 0.005551
const f_I = 1.0
const τ_i = 31.0
const τ_d = 3.0
const G_threshold_pl = 9.0
const c1 = 0.1

# Define the ODE system
function system!(D, u, p, t)
    # Define model state variables
    M_G_gut, G_pl, G_int, I_pl, I_d₁ = u

    # Model parameters
    k1, k2, k3, k4, k5, k6, k7, k8, k9, k10, σ, Km, G_b, I_pl_b, G_liv_b, G_dose, BW  = p

    V_G = (260 / sqrt(BW / 70)) / 1000
    V_TG = (70 / sqrt(BW / 70)) / 1000

    ## Define model equations

    """
    Glucose model equations
    """
    # Appearance of glucose from meal
    G_meal = σ * (k1^σ) * t^(σ - 1) * exp(-1 * (k1 * t)^σ) * G_dose

    # Glucose mass in gut
    D[1] = G_meal - k2 * M_G_gut
    # Net glucose flux across liver
    G_liv = G_liv_b - k4 * f_I * I_d₁ - k3 * (G_pl - G_b)
    # Glucose concentration in gut
    G_con_gut = k2 * (f_G / (V_G * BW)) * M_G_gut
    # Insulin-independent glucose utilisation by tissues (brain)
    G_util_ii = G_liv_b * ((Km + G_b) / G_b) * (G_pl / (Km + G_pl))
    # Insulin-dependent glucose utilisation (liver, muscle, adipose)
    G_util_id = k5 * f_I * I_d₁ * (G_pl / (Km + G_pl))
    # Renal extraction of plasma glucose
    G_util_ren = (c1 / (V_G * BW) * (G_pl - G_threshold_pl)) * (G_pl > G_threshold_pl)
    # Rate of change of plasma glucose
    D[2] = G_liv + G_con_gut - G_util_id - G_util_ren - G_util_ii

    """
    Insulin model equations
    """
    # Integrator term
    D[3] = G_pl - G_b
    # Pancreatic insulin secretion
    I_pnc = (f_I^(-1)) * (k6 * (G_pl - G_b) + (k7 / τ_i) * (G_int + G_b) + (k8 * τ_d) * D[2])
    # Liver insulin 
    I_liv = k7 * (G_b / (f_I * τ_i * I_pl_b)) * I_pl
    # Insulin concentration in remote compartment
    D[5] = k9 * (I_pl - I_pl_b) - k10 * I_d₁
    # Transport insulin from plasma to remote compartment
    I_rem = k9 * (I_pl - I_pl_b)
    # Rate of change of plasma insulin
    D[4] = I_pnc - I_liv - I_rem
end

# Function to return the ODE system (optional, but useful for structured access)
function ODEs()

    return system!
end
