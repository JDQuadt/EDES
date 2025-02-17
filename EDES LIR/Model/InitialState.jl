"""
InitialState:
function to create the initial state vector for the EDES model.

input:
- fasting_glucose: fasting glucose in plasma (first time point of the data)
- fasting_insulin: fasting insulin in plasma

output:
- initial_state: vector of initial state values
"""
function InitialState(
  fasting_glucose::Real,
  fasting_insulin::Real,
  M_G_gut_0 = 0,
  G_pl_0 = fasting_glucose,
  G_int_0 = 0,
  I_pl_0 = fasting_insulin,
  I_d₁_0 = 0,
  )
  initial_state = [
    M_G_gut_0, G_pl_0, G_int_0, I_pl_0, I_d₁_0,
  ]
  return initial_state
end