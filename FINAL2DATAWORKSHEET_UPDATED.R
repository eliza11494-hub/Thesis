# THESIS DATA ANALYSIS - UPDATED WITH DIRECT ICPSR & GITHUB DOWNLOADS
# Automatically downloads all required datasets
# Author: Elizabeth Sedran
# Last Updated: January 2026

# =============================================================================
# SETUP & LIBRARY LOADING
# =============================================================================

library(dplyr)
library(tidyverse)
library(stringr)
library(haven)
library(readxl)
library(readr)
library(ggplot2)

# Install icpsrdata if not already installed
if (!requireNamespace("icpsrdata", quietly = TRUE)) {
  install.packages("icpsrdata")
}
library(icpsrdata)

# =============================================================================
# SET YOUR ICPSR CREDENTIALS (one-time setup)
# =============================================================================
# OPTION 1: Set credentials here (NOT recommended for public repos)
# options(
#   "icpsr_email" = "esedran1@jhu.edu",
#   "icpsr_password" = "dataproject2023"
# )

# OPTION 2: Set credentials in your .Rprofile (RECOMMENDED)
# Add these lines to your ~/.Rprofile file:
# options(icpsr_email = "esedran1@jhu.edu")
# options(icpsr_password = "dataproject2023)

# =============================================================================
# DOWNLOAD DATA FROM ICPSR
# =============================================================================
icpsr_email = "[esedran1@jhu.edu]"
icpsr_password = "dataproject2023"

# Create data directory if it doesn't exist
if (!dir.exists("data/raw")) {
  dir.create("data/raw", recursive = TRUE)
}

cat("Downloading ICPSR datasets...\n")

# Download ICPSR 38506 - Voter Registration and Turnout
cat("\n1. Downloading ICPSR 38506 (Voter Turnout 2004-2022)...\n")
icpsr_download(38506, download_dir = "data/raw", unzip = TRUE)

# Download ICPSR 38606 - Urbanicity
cat("\n2. Downloading ICPSR 38606 (Urbanicity by Census Tract)...\n")
icpsr_download(38606, download_dir = "data/raw", unzip = TRUE)

# Download ICPSR 38580 - Street Connectivity (2010 & 2020)
cat("\n3. Downloading ICPSR 38580 (Street Connectivity)...\n")
icpsr_download(38580, download_dir = "data/raw", unzip = TRUE)

cat("\nAll ICPSR downloads complete!\n")

# =============================================================================
# DOWNLOAD CountyDataGood.xlsx FROM GITHUB
# =============================================================================

cat("\nDownloading CountyDataGood.xlsx from GitHub...\n")

# GitHub raw URL for the Excel file
github_url <- "https://github.com/eliza11494-hub/Thesis/raw/main/CountyDataGood.xlsx"
local_file <- "data/CountyDataGood.xlsx"

# Create data directory if needed
if (!dir.exists("data")) {
  dir.create("data")
}

# Download the file
download.file(github_url, destfile = local_file, mode = "wb")
cat("CountyDataGood.xlsx downloaded successfully!\n")

# =============================================================================
# DOWNLOAD ANES TIME SERIES DATA
# =============================================================================

cat("\nDownloading ANES Time Series Cumulative Data File...\n")

# ANES direct download URL
anes_url <- "https://electionstudies.org/wp-content/uploads/2022/09/anes_timeseries_cdf_csv_20220916.csv"
anes_file <- "data/anes_timeseries_cdf_csv_20220916.csv"

# Download if it doesn't exist
if (!file.exists(anes_file)) {
  download.file(anes_url, destfile = anes_file, mode = "wb")
  cat("✓ Downloaded ANES data\n")
} else {
  cat("✓ ANES data already exists\n")
}

# =============================================================================
# IMPORT FILES
# =============================================================================

cat("\nLoading datasets...\n")

# Load Nanda Turnout Data (ICPSR 38506)
Nanda_turnout <- read_sav("data/raw/ICPSR_38506/DS0001/38506-0001-Data.sav")
cat("✓ Loaded Nanda turnout data\n")

# Load Urbanicity Data (ICPSR 38606)
Urbancity_Data <- read_sav("data/raw/ICPSR_38606/DS0001/38606-0001-Data.sav")
cat("✓ Loaded urbanicity data\n")

# Load Street Connectivity Data 2010 (ICPSR 38580)
StreetConnectivity_Data_2010 <- read_sav("data/raw/ICPSR_38580/DS0001/38580-0001-Data.sav")
cat("✓ Loaded 2010 street connectivity data\n")

# Load Street Connectivity Data 2020 (ICPSR 38580)
StreetConnectivity_Data_2020 <- read_sav("data/raw/ICPSR_38580/DS0003/38580-0003-Data.sav")
cat("✓ Loaded 2020 street connectivity data\n")

# Load County Data from GitHub
CountyData_pre2024 <- read_excel(local_file)
cat("✓ Loaded county data from GitHub\n")

# Load ANES Time Series Data
anes_data <- read.csv(anes_file)
cat("✓ Loaded ANES time series data\n")

# =============================================================================
# NANDA CLEANUP
# =============================================================================

names(Nanda_turnout)[names(Nanda_turnout) == "STCOFIPS"] <- "Fips"
nanda_2016_on <- Nanda_turnout[Nanda_turnout$YEAR >= 2016, ]

# =============================================================================
# STREET CONNECTIVITY DATA PROCESSING
# =============================================================================

# Process 2010 data
StreetConnectivity_Data_2010 <- StreetConnectivity_Data_2010 %>%
  mutate(Fips = substr(TRACT_FIPS10, 1, 5))

county_connectivity_averages_2010 <- StreetConnectivity_Data_2010 %>%
  group_by(Fips) %>%
  summarise(
    avg_real_nodes_2010 = mean(N_REALNODES, na.rm = TRUE),
    avg_network_density_2010 = mean(STRNETDENSITY, na.rm = TRUE),
    avg_conNodeRatio_2010 = mean(CONNODERATIO, na.rm = TRUE),
    avg_block_density_2010 = mean(BLOCKDENSITY, na.rm = TRUE)
  )

# Process 2020 data
StreetConnectivity_Data_2020 <- StreetConnectivity_Data_2020 %>%
  mutate(Fips = substr(TRACT_FIPS20, 1, 5))

county_connectivity_averages_2020 <- StreetConnectivity_Data_2020 %>%
  group_by(Fips) %>%
  summarise(
    avg_real_nodes_2020 = mean(N_REALNODES, na.rm = TRUE),
    avg_network_density_2020 = mean(STRNETDENSITY, na.rm = TRUE),
    avg_conNodeRatio_2020 = mean(CONNODERATIO, na.rm = TRUE),
    avg_block_density_2020 = mean(BLOCKDENSITY, na.rm = TRUE)
  )

# Merge connectivity data
county_connectivity_averages <- merge(
  county_connectivity_averages_2010, 
  county_connectivity_averages_2020, 
  by = 'Fips', 
  all = TRUE
)

# =============================================================================
# COUNTY DATA PROCESSING
# =============================================================================

# Rename FIPS column to match
names(CountyData_pre2024)[names(CountyData_pre2024) == "FIPS"] <- "Fips"

# NOTE: You'll need to add NEWTypologyfix.csv to your GitHub repo
# For now, this section is commented out - uncomment once you add the file
# NEWTypologyfix <- read.csv("https://github.com/eliza11494-hub/Thesis/raw/main/NEWTypologyfix.csv", 
#                            header = FALSE)
# new_header <- NEWTypologyfix[1, ]
# NEWTypologyfix <- NEWTypologyfix[-1, ]
# names(NEWTypologyfix) <- new_header

# Merge all data
county_data_all <- CountyData_pre2024  # Start with county data
# county_data_all <- merge(county_data_all, NEWTypologyfix, by = "Fips", all = TRUE)
county_data_all <- merge(county_data_all, nanda_2016_on, by = 'Fips', all = TRUE)
county_data_all <- merge(county_data_all, county_connectivity_averages, by = 'Fips', all = TRUE)

# =============================================================================
# DATA CLEANING & TRANSFORMATION
# =============================================================================

county_data_simplified <- county_data_all %>%
  select(-c("Metro Area", "County name")) %>%
  rename(
    '2018 Typology' = 'Type of County',
    '% 2010-2018 Population Change' = '% Population increase since 2010',
    'BidenTwentyTwenty' = 'Biden ',
    'TwentyTwentyTotal' = 'Total ',
    'TwentyTrump' = 'Trump',
    "Obama2012" = 'Obama % 2012',
    'Romney_p2012' = 'Romney % 2012',
    'Clinton_p2016' = 'Clinton % 2016',
    'Trump_p2016' = 'Trump % 2016',
    'Other_p2016' = 'Other % 2016',
    "Clinton2016" = 'Clinton 2016',
    'Trump2016' = 'Trump 2016',
    'Total2016' = 'Total 2016'
  )

# Convert to numeric
county_data_simplified$TwentyTrump <- as.numeric(county_data_simplified$TwentyTrump)
county_data_simplified$BidenTwentyTwenty <- as.numeric(county_data_simplified$BidenTwentyTwenty)
county_data_simplified$TwentyTwentyTotal <- as.numeric(county_data_simplified$TwentyTwentyTotal)

# Calculate vote shares
county_data_simplified <- county_data_simplified %>%
  mutate(
    Biden_Share = ((BidenTwentyTwenty / TwentyTwentyTotal) * 100),
    Trump_share = ((TwentyTrump / TwentyTwentyTotal) * 100),
    Clinton_share = ((Clinton2016 / Total2016) * 100),
    Trump2016Share = ((Trump2016 / Total2016) * 100)
  )

# Fix typology naming
county_data_simplified$`2023 Typology` <- gsub(
  "Urban Burbs", 
  "Urban Suburbs", 
  county_data_simplified$`2023 Typology`
)

# Calculate margins
county_data_simplified <- county_data_simplified %>%
  mutate(
    Margin_2020_GOPnegative = Biden_Share - Trump_share,
    Margin_2016_GOPnegative = Clinton_share - Trump2016Share,
    margin_2012_GOPnegative = (Obama2012 - Romney_p2012) * 100
  )

# =============================================================================
# CREATE ANALYSIS DATASETS
# =============================================================================

# Presidential data
county_data_presidential <- county_data_simplified %>%
  select(
    "Fips", "State", "County", "2018 Typology", "2023 Typology", 
    "Largest City/Town", '% 2010-2018 Population Change', 
    "margin_2012_GOPnegative", "Margin_2016_GOPnegative", "Margin_2020_GOPnegative"
  ) %>%
  unique()

# Urbanicity data
county_data_urbanicity <- county_data_simplified %>% 
  filter(YEAR == 2016) %>%
  select(
    "Fips", "State", "County", "2018 Typology", "2023 Typology", 
    "Largest City/Town", '% 2010-2018 Population Change', 
    '% Urban', '% Rural', 
    'avg_real_nodes_2010', 'avg_real_nodes_2020', 
    'avg_conNodeRatio_2010', 'avg_conNodeRatio_2020', 
    'avg_block_density_2010', 'avg_block_density_2020', 
    'avg_network_density_2010', 'avg_network_density_2020', 
    'REG_VOTER_TURNOUT_PCT', 
    "margin_2012_GOPnegative", "Margin_2016_GOPnegative", "Margin_2020_GOPnegative"
  ) %>%
  rename('2018regiesteredturnout' = 'REG_VOTER_TURNOUT_PCT')

# New classification data
county_data_newclassification <- county_data_simplified %>%
  filter(`2018 Typology` != `2023 Typology`) %>%
  select(
    "Fips", "State", "County", "2018 Typology", "2023 Typology", 
    "Largest City/Town", '% 2010-2018 Population Change', 
    "margin_2012_GOPnegative", "Margin_2016_GOPnegative", "Margin_2020_GOPnegative",
    '% Urban', '% Rural', 'YEAR', 'REG_VOTER_TURNOUT_PCT'
  )

# =============================================================================
# INTERESTING SUBSETS
# =============================================================================

presidential_thrice_flips <- county_data_presidential %>%
  filter(
    margin_2012_GOPnegative < 0 & Margin_2016_GOPnegative > 0 & Margin_2020_GOPnegative < 0 |
    margin_2012_GOPnegative > 0 & Margin_2016_GOPnegative < 0 & Margin_2020_GOPnegative > 0
  )

presidential_double_flips <- county_data_presidential %>%
  filter(
    margin_2012_GOPnegative < 0 & Margin_2016_GOPnegative > 0 |
    margin_2012_GOPnegative > 0 & Margin_2016_GOPnegative < 0 |
    Margin_2016_GOPnegative < 0 & Margin_2020_GOPnegative > 0 |
    Margin_2016_GOPnegative > 0 & Margin_2020_GOPnegative < 0
  )

double_flip_new_typology <- presidential_double_flips %>%
  filter(`2018 Typology` != `2023 Typology`)

# =============================================================================
# SUMMARY STATISTICS
# =============================================================================

cat("\n=== URBANICITY STATISTICS ===\n")
summary(county_data_urbanicity)

cat("\n=== PRESIDENTIAL STATISTICS ===\n")
summary(county_data_presidential)

# =============================================================================
# VISUALIZATION SETUP
# =============================================================================

gop_color <- "red"
dem_color <- "blue"

# =============================================================================
# 2020 VISUALIZATIONS
# =============================================================================

# Urbanicity vs 2020 Margin
bivariate_urbancity_viz_2020 <- ggplot(
  data = county_data_urbanicity, 
  aes(x = `% Urban`, y = `Margin_2020_GOPnegative`)
) + 
  geom_point(aes(color = ifelse(`Margin_2020_GOPnegative` >= 0, "DEM", "GOP")), size = 3) +
  geom_smooth(method = "lm") +
  labs(
    x = "% Urban",
    y = "2020 Margin",
    title = "Urbanicity vs. 2020 Margin"
  ) +
  scale_color_manual(
    name = "2020 party win",
    values = c("DEM" = dem_color, "GOP" = gop_color),
    labels = c("DEM" = "Democratic", "GOP" = "Republican")
  ) +
  scale_y_continuous(limits = c(-100, 100))

# Ruralicity vs 2020 Margin
bivariate_ruralicity_viz_2020 <- ggplot(
  data = county_data_urbanicity, 
  aes(x = `% Rural`, y = `Margin_2020_GOPnegative`)
) + 
  geom_point(aes(color = ifelse(`Margin_2020_GOPnegative` >= 0, "DEM", "GOP")), size = 3) +
  geom_smooth(method = "lm") +
  labs(
    x = "% Rural",
    y = "2020 Margin",
    title = "Ruralcity vs. 2020 Margin"
  ) +
  scale_color_manual(
    name = "2020 party win",
    values = c("DEM" = dem_color, "GOP" = gop_color),
    labels = c("DEM" = "Democratic", "GOP" = "Republican")
  ) +
  scale_y_continuous(limits = c(-100, 100))

# Network Density vs 2020 Margin
bivariate_density_viz_2020 <- ggplot(
  data = county_data_urbanicity, 
  aes(x = avg_network_density_2020, y = `Margin_2020_GOPnegative`)
) + 
  geom_point(aes(color = ifelse(`Margin_2020_GOPnegative` >= 0, "DEM", "GOP")), size = 3) +
  geom_smooth(method = "lm") +
  labs(
    x = "Avg Network Density",
    y = "2020 Margin",
    title = "Network Density vs. 2020 Margin"
  ) +
  scale_color_manual(
    name = "2020 Party Win",
    values = c("DEM" = dem_color, "GOP" = gop_color),
    labels = c("DEM" = "Democratic", "GOP" = "Republican")
  )

# Block Density vs 2020 Margin
bivariate_block_denisity_viz_2020 <- ggplot(
  data = county_data_urbanicity, 
  aes(x = avg_block_density_2020, y = `Margin_2020_GOPnegative`)
) + 
  geom_point(aes(color = ifelse(`Margin_2020_GOPnegative` >= 0, "DEM", "GOP")), size = 3) +
  geom_smooth(method = "lm") +
  labs(
    x = "Avg Block Density",
    y = "2020 Margin",
    title = "Average Block Density vs. 2020 Margin"
  ) +
  scale_color_manual(
    name = "2020 party win",
    values = c("DEM" = dem_color, "GOP" = gop_color),
    labels = c("DEM" = "Democratic", "GOP" = "Republican")
  )

# Connectivity vs 2020 Margin
bivariate_connectivity_viz_2020 <- ggplot(
  data = county_data_urbanicity, 
  aes(x = avg_conNodeRatio_2020, y = `Margin_2020_GOPnegative`)
) + 
  geom_point(aes(color = ifelse(`Margin_2020_GOPnegative` >= 0, "DEM", "GOP")), size = 3) +
  geom_smooth(method = "lm") +
  labs(
    x = "Avg Connectivity Node Ratio",
    y = "2020 Margin",
    title = "Average Node Connectivity vs. 2020 Margin"
  ) +
  scale_color_manual(
    name = "2020 party win",
    values = c("DEM" = dem_color, "GOP" = gop_color),
    labels = c("DEM" = "Democratic", "GOP" = "Republican")
  )

# =============================================================================
# 2020 REGRESSION MODELS
# =============================================================================

bivariant_connectivity_2020 <- lm(
  formula = Margin_2020_GOPnegative ~ avg_conNodeRatio_2020, 
  data = county_data_urbanicity
)

bivariate_block_density_2020 <- lm(
  formula = Margin_2020_GOPnegative ~ avg_block_density_2020, 
  data = county_data_urbanicity
)

bivariate_network_density_2020 <- lm(
  formula = Margin_2020_GOPnegative ~ avg_network_density_2020, 
  data = county_data_urbanicity
)

bivariate_urbanicity_2020 <- lm(
  formula = Margin_2020_GOPnegative ~ `% Urban`, 
  data = county_data_urbanicity
)

multivariate_urbancity_2020 <- lm(
  formula = Margin_2020_GOPnegative ~ avg_block_density_2020 + avg_conNodeRatio_2020 + `% Urban`, 
  data = county_data_urbanicity
)

multivariate_density_2020 <- lm(
  formula = Margin_2020_GOPnegative ~ avg_block_density_2020 + avg_conNodeRatio_2020 + avg_network_density_2020, 
  data = county_data_urbanicity
)

# =============================================================================
# 2016 VISUALIZATIONS
# =============================================================================

# Network Density vs 2016 Margin
bivariate_density_viz_2016 <- ggplot(
  data = county_data_urbanicity, 
  aes(x = avg_network_density_2010, y = `Margin_2016_GOPnegative`)
) + 
  geom_point(aes(color = ifelse(`Margin_2016_GOPnegative` >= 0, "DEM", "GOP")), size = 3) +
  geom_smooth(method = "lm") +
  labs(
    x = "Avg Network Density",
    y = "2016 Margin",
    title = "Network Density vs. 2016 Margin"
  ) +
  scale_color_manual(
    name = "2016 Party Win",
    values = c("DEM" = dem_color, "GOP" = gop_color),
    labels = c("DEM" = "Democratic", "GOP" = "Republican")
  )

# Block Density vs 2016 Margin
bivariate_block_denisity_viz_2016 <- ggplot(
  data = county_data_urbanicity, 
  aes(x = avg_block_density_2010, y = `Margin_2016_GOPnegative`)
) + 
  geom_point(aes(color = ifelse(`Margin_2016_GOPnegative` >= 0, "DEM", "GOP")), size = 3) +
  geom_smooth(method = "lm") +
  labs(
    x = "Avg Block Density",
    y = "2016 Margin",
    title = "Average Block Density vs. 2016 Margin"
  ) +
  scale_color_manual(
    name = "2016 party win",
    values = c("DEM" = dem_color, "GOP" = gop_color),
    labels = c("DEM" = "Democratic", "GOP" = "Republican")
  )

# =============================================================================
# 2016 REGRESSION MODELS
# =============================================================================

bivariant_connectivity_2016 <- lm(
  formula = Margin_2016_GOPnegative ~ avg_conNodeRatio_2010, 
  data = county_data_urbanicity
)

bivariate_block_density_2016 <- lm(
  formula = Margin_2016_GOPnegative ~ avg_block_density_2010, 
  data = county_data_urbanicity
)

bivariate_network_density_2016 <- lm(
  formula = Margin_2016_GOPnegative ~ avg_network_density_2010, 
  data = county_data_urbanicity
)

multivariate_urbancity_2016 <- lm(
  formula = Margin_2016_GOPnegative ~ avg_block_density_2010 + avg_conNodeRatio_2010 + `% Urban`, 
  data = county_data_urbanicity
)

multivariate_density_2016 <- lm(
  formula = Margin_2016_GOPnegative ~ avg_block_density_2010 + avg_conNodeRatio_2010 + avg_network_density_2010, 
  data = county_data_urbanicity
)

# =============================================================================
# 2012 VISUALIZATIONS
# =============================================================================

# Network Density vs 2012 Margin
bivariate_network_denisity_viz_2012 <- ggplot(
  data = county_data_urbanicity, 
  aes(x = avg_network_density_2010, y = `margin_2012_GOPnegative`)
) + 
  geom_point(aes(color = ifelse(`margin_2012_GOPnegative` >= 0, "DEM", "GOP")), size = 3) +
  geom_smooth(method = "lm") +
  labs(
    x = "Avg Network Density",
    y = "2012 Margin",
    title = "Average Network Density vs. 2012 Margin"
  ) +
  scale_color_manual(
    name = "2012 party win",
    values = c("DEM" = dem_color, "GOP" = gop_color),
    labels = c("DEM" = "Democratic", "GOP" = "Republican")
  )

# Block Density vs 2012 Margin
bivariate_block_denisity_viz_2012 <- ggplot(
  data = county_data_urbanicity, 
  aes(x = avg_block_density_2010, y = `margin_2012_GOPnegative`)
) + 
  geom_point(aes(color = ifelse(`margin_2012_GOPnegative` >= 0, "DEM", "GOP")), size = 3) +
  geom_smooth(method = "lm") +
  labs(
    x = "Avg Block Density",
    y = "2012 Margin",
    title = "Average Block Density vs. 2012 Margin"
  ) +
  scale_color_manual(
    name = "2012 party win",
    values = c("DEM" = dem_color, "GOP" = gop_color),
    labels = c("DEM" = "Democratic", "GOP" = "Republican")
  )

# =============================================================================
# 2012 REGRESSION MODELS
# =============================================================================

bivariant_connectivity_2012 <- lm(
  formula = margin_2012_GOPnegative ~ avg_conNodeRatio_2010, 
  data = county_data_urbanicity
)

bivariate_block_density_2012 <- lm(
  formula = margin_2012_GOPnegative ~ avg_block_density_2010, 
  data = county_data_urbanicity
)

bivariate_network_density_2012 <- lm(
  formula = margin_2012_GOPnegative ~ avg_network_density_2010, 
  data = county_data_urbanicity
)

multivariate_density_2012 <- lm(
  formula = margin_2012_GOPnegative ~ avg_block_density_2010 + avg_conNodeRatio_2010 + avg_network_density_2010, 
  data = county_data_urbanicity
)

# =============================================================================
# PRESIDENTIAL ELECTION VISUALIZATIONS
# =============================================================================

# Population Change vs 2020 Margin
bivariate_presidential_viz_2020 <- ggplot(
  county_data_presidential, 
  aes(x = `% 2010-2018 Population Change`, y = Margin_2020_GOPnegative)
) + 
  geom_point(aes(color = ifelse(Margin_2020_GOPnegative >= 0, "DEM", "GOP")), size = 3) +
  geom_smooth(method = "lm") +
  labs(
    x = "2018 Population Change",
    y = "2020 Margin",
    title = "Population Change vs. Margin"
  ) +
  scale_color_manual(
    name = "2020 party win",
    values = c("DEM" = dem_color, "GOP" = gop_color),
    labels = c("DEM" = "Democratic", "GOP" = "Republican")
  ) +
  scale_x_continuous(limits = c(-0.4, 0.4))

# Regression model
bivariate_margin <- lm(
  formula = Margin_2020_GOPnegative ~ `% 2010-2018 Population Change`, 
  data = county_data_presidential
)

# 2020 Presidential Elections by County Type (Bar Chart)
county_presidential_bar_2020 <- ggplot(
  county_data_presidential, 
  aes(x = `2023 Typology`, y = Margin_2020_GOPnegative)
) +
  stat_summary(
    fun = mean,
    geom = 'col',
    color = 'black',
    fill = 'steelblue'
  ) +
  labs(
    x = 'County Type',
    y = 'Mean Margin',
    title = '2020 Presidential Elections by County Type'
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), 
    axis.title.x = element_text(size = 12)
  )

# 2020 Presidential Elections by County Type (Scatter Plot)
pres_scatter_plot_2020 <- ggplot(
  county_data_presidential, 
  aes(x = `2023 Typology`, y = Margin_2020_GOPnegative, color = Margin_2020_GOPnegative < 0)
) +
  geom_point(size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, color = 'black', linetype = 'solid', linewidth = 2) +
  scale_color_manual(
    values = c('TRUE' = 'red', 'FALSE' = 'blue'), 
    labels = c('TRUE' = 'Republican', 'FALSE' = 'Democratic')
  ) +
  labs(
    x = 'County Type',
    y = '2020 Margin',
    title = '2020 Presidential Elections by County Type',
    color = '2020 Margin'
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), 
    axis.title.x = element_text(size = 12),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9)
  )

# 2016 Presidential Elections by County Type (Bar Chart)
county_presidential_bar_2016 <- ggplot(
  county_data_presidential, 
  aes(x = `2018 Typology`, y = Margin_2016_GOPnegative)
) +
  stat_summary(
    fun = mean,
    geom = 'col',
    color = 'black',
    fill = 'steelblue'
  ) +
  labs(
    x = '2018 County Type',
    y = 'Mean Margin',
    title = '2016 Presidential Elections by County Type'
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), 
    axis.title.x = element_text(size = 12)
  )

# 2016 Presidential Elections by County Type (Scatter Plot)
pres_scatter_plot_2016 <- ggplot(
  county_data_presidential, 
  aes(x = `2018 Typology`, y = Margin_2016_GOPnegative, color = Margin_2016_GOPnegative < 0)
) +
  geom_point(size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, color = 'black', linetype = 'solid', linewidth = 2) +
  scale_color_manual(
    values = c('TRUE' = 'red', 'FALSE' = 'blue'), 
    labels = c('TRUE' = 'Republican', 'FALSE' = 'Democratic')
  ) +
  labs(
    x = 'County Type',
    y = '2016 Margin',
    title = '2016 Presidential Elections by County Type',
    color = '2016 Margin'
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), 
    axis.title.x = element_text(size = 12),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9)
  )

# =============================================================================
# SUBSET ANALYSES
# =============================================================================

suburb_gop_only <- county_data_simplified %>%
  filter(`2023 Typology` == "Urban Suburbs") %>%
  filter(Margin_2020_GOPnegative < 0)

suburb_dem_only <- county_data_simplified %>%
  filter(`2023 Typology` == "Urban Suburbs") %>%
  filter(Margin_2020_GOPnegative > 0)

exurb_dem_only <- county_data_simplified %>%
  filter(`2023 Typology` == "Exurbs") %>%
  filter(Margin_2020_GOPnegative > 0)

exurb_gop_only <- county_data_simplified %>%
  filter(`2023 Typology` == "Exurbs") %>%
  filter(Margin_2020_GOPnegative < 0)

# =============================================================================
# ANES DATA PROCESSING
# =============================================================================

cat("\nProcessing ANES data...\n")

## CLEANUP FOR ANES WAVE RESPONDENTS
anes_wave_respondents <- anes_data %>%
  select(VCF0004, VCF0006, VCF0018a, VCF0018b, VCF0101, VCF0102, VCF0104, 
         VCF0106, VCF0110, VCF0112, VCF0218, VCF0303, VCF0342) %>%
  rename(
    survey_year = VCF0004,
    respondent_id = VCF0006,
    pre_lang = VCF0018a,
    post_lang = VCF0018b,
    age = VCF0101,
    age_group = VCF0102,
    gender = VCF0104,
    race = VCF0106,
    education = VCF0110,
    region = VCF0112,
    religion = VCF0218,
    party_id = VCF0303,
    knowledge = VCF0342
  )

## POLITICAL IDEOLOGY
political_idealogy <- anes_data %>%
  select(VCF0004, VCF0303, VCF0106, VCF0110, VCF0731, VCF0733, VCF0616, 
         VCF0617, VCF0618, VCF0619, VCF0620, VCF0621, VCF0803, VCF0201, 
         VCF0202, VCF0211, VCF0212, VCF0221, VCF0218, VCF0224, VCF0222, VCF0228) %>%
  rename(
    survey_year = VCF0004,
    party_id = VCF0303,
    race = VCF0106,
    education = VCF0110,
    discuss_pol = VCF0731,
    freq_discuss = VCF0733,
    care_outcome = VCF0616,
    party_cant_win = VCF0617,
    local_election = VCF0618,
    trust = VCF0619,
    helpful = VCF0620,
    fair = VCF0621,
    self_id = VCF0803,
    dem_therm = VCF0201,
    dem_party_therm = VCF0218,
    GOP_party_therm = VCF0224,
    parties_therm = VCF0222,
    congress_therm = VCF0228
  )

cat("✓ ANES data processed\n")

# =============================================================================
# PRINT KEY SUMMARIES
# =============================================================================

cat("\n=== 2020 REGRESSION SUMMARIES ===\n")
cat("\nUrbanicity Model:\n")
summary(bivariate_urbanicity_2020)

cat("\nBlock Density Model:\n")
summary(bivariate_block_density_2020)

cat("\nMultivariate Model:\n")
summary(multivariate_urbancity_2020)

# =============================================================================
# SCRIPT COMPLETE
# =============================================================================

cat("\n✓ Script execution complete!\n")
cat("All datasets loaded and processed successfully.\n")
cat("Visualizations and models are ready for analysis.\n")
