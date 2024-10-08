function KML_cluster(
    df_fits::DataFrame,
    cluster_parameter::Symbol,
    n_clusters::Int64,
    elbow_plot::Bool=false,


)
    # Rename the columns to be used in unstack
    df_k5s = rename(df_fits,  Symbol("Meal Test") => :parameter, cluster_parameter => :value)
    # Get the unique IDs and Health status
    df_health_status = unique(df_fits[:, [:ID, Symbol("Health status")]])

    # Unstack the DataFrame
    df_unstacked = unstack(df_k5s, :ID,  :parameter, :value)
    # Join the "Health status" DataFrame with the unstacked DataFrame
    df_unstacked = rightjoin(df_unstacked, df_health_status, on = :ID)

    # Get the cluster data
    cluster_data = df_unstacked[:, 2:end-1]
    cluster_data = Matrix{Float64}(cluster_data)

    # Perform the KMeans clustering
    kmeans_model = kmeans(cluster_data, n_clusters)

    # Get the cluster labels
    cluster_labels = kmeans_model.assignments
    cluster_sizes = kmeans_model.counts


    return cluster_labels, cluster_sizes

end