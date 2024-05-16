required.packages <- c("data.table","jsonlite", "rstudioapi")
lapply(required.packages, require, character.only=T)
setwd(dirname(dirname(getActiveDocumentContext()$path)))

source("https://raw.githubusercontent.com/devinit/gha_automation/main/IHA/fts_curated_flows.R")

fts <- fts_curated_flows(2017:2022, dataset_path = "project_data")

###Sectors

#FTS global cluster
fts[, global_cluster_relevant := F]
fts[destinationObjects_GlobalCluster.name == "Food Security", global_cluster_relevant := T]

#DI-mapped cluster
fts[, mapped_cluster_relevant := F]
fts[destination_globalcluster == "Food Security", mapped_cluster_relevant := T]

###FAO/WFP

#WFP
wfp_exclude <- paste0(c("Logistics", "Emergency Telecommunications", "Coordination and support services", "Air services"), collapse = "|")

fts[, wfp_relevant := F]
fts[(destinationObjects_Organization.name == "World Food Programme" | destinationObjects_Organization.name == "Food & Agriculture Organization of the United Nations; World Food Programme" | destinationObjects_Organization.name == "World Food Programme; Food & Agriculture Organization of the United Nations") & !grepl(wfp_exclude, paste0(destinationObjects_GlobalCluster.name, description), ignore.case = T)
    , wfp_relevant := T]

fts[, wfp_nutrition_relevant := F]
fts[destinationObjects_Organization.name == "World Food Programme" & destinationObjects_GlobalCluster.name %in% c("Education", "Health", "Nutrition")
    , wfp_nutrition_relevant := T]

#FAO
fao_exclude <- paste0(c("Logistics", "Emergency Telecommunications", "Coordination and support services", "Agriculture", "Nutrition"), collapse = "|")

fts[, fao_relevant := F]
fts[(destinationObjects_Organization.name == "Food & Agriculture Organization of the United Nations" | destinationObjects_Organization.name == "Food & Agriculture Organization of the United Nations; World Food Programme" | destinationObjects_Organization.name == "World Food Programme; Food & Agriculture Organization of the United Nations") & !grepl(fao_exclude, paste0(destinationObjects_GlobalCluster.name, description), ignore.case = T)
    , fao_relevant := T]

remove <- c("sourceObjects_Location.organizationTypes",
            "sourceObjects_Location.organizationSubTypes",
            "sourceObjects_UsageYear.organizationTypes",
            "sourceObjects_UsageYear.organizationSubTypes",
            "sourceObjects_Plan.organizationTypes",
            "sourceObjects_Plan.organizationSubTypes",
            "sourceObjects_Emergency.behavior",
            "sourceObjects_Emergency.organizationTypes",
            "sourceObjects_Emergency.organizationSubTypes",
            "sourceObjects_GlobalCluster.behavior",
            "sourceObjects_GlobalCluster.organizationTypes",
            "sourceObjects_Cluster.behavior",
            "sourceObjects_Cluster.organizationTypes",
            "sourceObjects_Cluster.organizationSubTypes",
            "sourceObjects_GlobalCluster.organizationSubTypes",
            "sourceObjects_Location.code",
            "sourceObjects_Organization.code",
            "sourceObjects_Plan.code",
            "sourceObjects_Project.behavior",
            "sourceObjects_Project.organizationTypes",
            "sourceObjects_UsageYear.code",
            "sourceObjects_GlobalCluster.code",
            "destinationObjects_GlobalCluster.organizationTypes",
            "destinationObjects_Location.organizationTypes",
            "destinationObjects_UsageYear.organizationTypes",
            "destinationObjects_Location.organizationSubTypes",
            "destinationObjects_UsageYear.organizationSubTypes",
            "destinationObjects_GlobalCluster.organizationSubTypes",
            "destinationObjects_Cluster.organizationTypes",
            "destinationObjects_Cluster.code",
            "destinationObjects_Location.code",
            "destinationObjects_Organization.code",
            "destinationObjects_Plan.organizationTypes",
            "destinationObjects_Plan.code",
            "destinationObjects_Project.organizationTypes",
            "destinationObjects_Emergency.behavior",
            "destinationObjects_Emergency.organizationTypes",
            "destinationObjects_Emergency.code",
            "destinationObjects_Plan.organizationSubTypes",
            "destinationObjects_Project.organizationSubTypes",
            "sourceObjects_Cluster.code",
            "sourceObjects_Project.organizationSubTypes",
            "destinationObjects_GlobalCluster.code",
            "destinationObjects_Cluster.organizationSubTypes",
            "sourceObjects_Emergency.code",
            "destinationObjects_Emergency.organizationSubTypes")

fwrite(fts[,-..remove], "fts_food_clusters_wfp_fao_relevance.csv")
