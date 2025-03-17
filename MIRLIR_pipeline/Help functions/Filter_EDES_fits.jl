using Statistics
using Plots
function check_oscillations(trajectory; threshold_sign_changes=8)
    """
    Identifies oscillatory behaviour in the simulated glucose and insulin trajectories.
    - `threshold_sign_changes`: The number of times the derivative's sign must change to detect oscillations.
    """
    time, glucose, insulin = trajectory.time, trajectory.plasma_glucose, trajectory.plasma_insulin
    
    # Function to detect oscillations based on derivative sign changes
    function detect_oscillations(data)
        # Calculate the derivative (difference between consecutive points)
        derivative = diff(data)
        # Count the number of sign changes in the derivative
        sign_changes = 0
        for i in 2:length(derivative)
            if sign(derivative[i-1]) != sign(derivative[i])
                sign_changes += 1
            end
        end
        
        # If the number of sign changes is above the threshold, it's oscillatory
        if sign_changes > threshold_sign_changes
            return true
        end
        
        return false
    end
    
    # Check oscillations for both glucose and insulin
    if detect_oscillations(glucose) || detect_oscillations(insulin)
        println("Oscillatory behaviour detected")
        # Plot the trajectory for visual inspection
        plt = plot(time, glucose, label="Glucose")
        plot!(time, insulin, label="Insulin")
        display(plt)
        return true
    end
    
    return false  # Fit is acceptable
end

function filter_edes_fits(results, OGTT_data; max_patients=100)
    """
    Filters EDES fits by checking for oscillations and unrealistic behaviour.
    - `max_patients`: Number of good fits to retain.
    """
    selected_patients = Set()  # Using a Set to track unique patient IDs
    
    # Group patients by Patient_ID
    for patient_id in unique(results.Patient_ID)
        # Filter rows for this patient
        patient_rows = filter(row -> row.Patient_ID == patient_id, eachrow(results))
        OGTT_rows = filter(row -> row.Patient_ID == patient_id, eachrow(OGTT_data))
        
        # Assume no oscillations detected for this patient initially
        has_oscillation = false
        
        # Check each row for oscillations
        for row in patient_rows
            long_time = row.Long_time_points
            k1, k5, k6 = row.k1, row.k5, row.k6
            params = [k1, k5, k6]
            
            # Find corresponding fasting glucose and insulin for the patient
            patient_OGTT_data = OGTT_rows[OGTT_rows.Long_Time .== long_time, :][1]
            fasting_glucose = patient_OGTT_data[3]  # Assuming the 3rd column is fasting glucose
            fasting_insulin = patient_OGTT_data[10]  # Assuming the 10th column is fasting insulin

            # Construct model
            model = EDES(fasting_glucose, fasting_insulin)
            full_parameter_vector = make_full_parameter_vector(model, params)
            
            # Simulate for the current long_time
            trajectory = output(model, full_parameter_vector)
            
            # Check for oscillations in the trajectory
            if check_oscillations(trajectory) 
                has_oscillation = true
                break  # No need to check further rows for this patient
            end
        end
        
        # If no oscillations were detected, add the patient ID to selected_patients
        if !has_oscillation
            push!(selected_patients, patient_id)
            
            # Stop if we have enough good fits
            if length(selected_patients) >= max_patients
                break
            end
        end
    end
    
    # Filter results for selected patients
    selected_rows = filter(row -> row.Patient_ID in selected_patients, eachrow(results))
    
    return DataFrame(selected_rows)
end


