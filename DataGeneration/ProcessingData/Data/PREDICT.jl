"""
    PREDICT_data(file_path::String = "C:/Users/20192809/Documents/Data/PREDICT_data.xlsx")

This function reads data from an Excel file located at `file_path` and performs data processing operations on the selected worksheets. It returns a joined DataFrame with the processed data.

## Arguments
- `file_path::String`: The path to the Excel file containing the data. Default value is "C:/Users/20192809/Documents/Data/PREDICT_data.xlsx".

## Returns
A DataFrame with the processed data.

## Example

"""
function PREDICT_data(
    file_path::String = "C:/Users/20192809/Documents/Data/PREDICT_data.xlsx",
)
    # Load the data
    data = XLSX.readxlsx(file_path)
    
    # select worksheets
    glucose_data = DataFrame(XLSX.eachtablerow(data["Fig2a(2)"]))
    insulin_data = DataFrame(XLSX.eachtablerow(data["Fig2a(3)"]))
    TG_data = DataFrame(XLSX.eachtablerow(data["Fig2a(1)"]))


    # drop the last three columns as these are measurements after a second meal is consumed
    select!(glucose_data, Not([:person_affinity_pglu_270, :person_affinity_pglu_300, :person_affinity_pglu_360]))
    select!(insulin_data, Not([:person_affinity_ins_270, :person_affinity_ins_300, :person_affinity_ins_360]))
    select!(TG_data, Not([:person_affinity_trig_270, :person_affinity_trig_300, :person_affinity_trig_360]))

    # Add a ID column to the data
    insertcols!(glucose_data, 1,  :ID => 1:nrow(glucose_data))
    insertcols!(insulin_data, 1,  :ID => 1:nrow(insulin_data))
    insertcols!(TG_data, 1,  :ID => 1:nrow(TG_data))

    # join the data
    data_joined  = rightjoin(glucose_data, insulin_data, on = :ID)
    data_joined = rightjoin(data_joined, TG_data, on = :ID)

    # drop rowws that have missing values
    dropmissing!(data_joined)


    return data_joined
end