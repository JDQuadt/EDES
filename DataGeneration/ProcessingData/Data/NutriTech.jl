"""
This function reads the NutriTech meal response data from a specified file and extracts relevant information.

## Arguments
- `file_path::String`: The path to the NutriTech meal response data file. Default value is "C:/Users/20192809/Documents/Data/NutriTech_Meal_Reponses.mat".
- `week::Int`: The week number for which the data is extracted. Default value is 1, NutriTech data contains measurements before and after the meal.

## Returns
A named tuple containing the following extracted data:
- `glucose`: Glucose data for the specified week.
- `insulin`: Insulin data for the specified week.
- `TG`: TG (Triglyceride) data for the specified week.
- `NEFA`: NEFA (Non-Esterified Fatty Acid) data for the specified week.
- `meal_TG`: TG (Triglyceride) data for the meal.
- `meal_G`: Glucose data for the meal.
- `BW`: Body weight data.
- `time_G`: Time data for glucose measurements.
- `time_I`: Time data for insulin measurements.
- `time_TG`: Time data for TG measurements.
- `time_NEFA`: Time data for NEFA measurements.
"""
function NutriTech_data(
    file_path::String = "C:/Users/20192809/Documents/Data/NutriTech_Meal_Reponses.mat",
    week::Int = 1,
)
    data = matread(file_path)
    MMT_data = data["MMT_week$week"]    

    # extracting meal responses
    glucose = MMT_data["glucose"]
    insulin = MMT_data["insulin"]
    TG = MMT_data["TG"]
    NEFA = MMT_data["NEFA"]

    # extracting meal composition
    meal_TG = MMT_data["meal"]["TG"][1]
    meal_G = MMT_data["meal"]["G"][1]

    # extracting BW
    BW = MMT_data["BW"]

    # extracting time
    time_G = vec(MMT_data["time_G"])
    time_I = vec(MMT_data["time_I"])
    time_TG = vec(MMT_data["time_TG"])
    time_NEFA = vec(MMT_data["time_NEFA"])

    # Combine all into a named tuple
    relevant_data = (
        glucose = glucose,
        insulin = insulin,
        TG = TG,
        NEFA = NEFA,
        meal_TG = meal_TG,
        meal_G = meal_G,
        BW = BW,
        time_G = time_G,
        time_I = time_I,
        time_TG = time_TG,
        time_NEFA = time_NEFA,
    )

    

    return relevant_data
end