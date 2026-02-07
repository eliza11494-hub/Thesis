# Thesis Data Analysis - Setup Guide

This repository contains code for analyzing urban development patterns and voting behavior in U.S. counties.

## Data Sources

This project uses three public ICPSR datasets and the ANES Time Series:

1. **ICPSR 38506** - County Voter Registration and Turnout, 2004-2022
2. **ICPSR 38606** - Urbanicity by Census Tract, 2010  
3. **ICPSR 38580** - Street Connectivity, 2010 & 2020
4. **ANES Time Series** - Cumulative Data File (1948-2020)

## Quick Start

### For Users (One-Click Setup) ⭐

**Just run the script - that's it!**

```r
source("FINAL2DATAWORKSHEET_UPDATED.R")
```

##MAPPING SCRIPT BUILDS OFF FINAL2DATAWORKSHEET_UPDATED

source("MAPPING_SCRIPT.R")

This will:
- Download pre-processed ICPSR data from GitHub
-  Download CountyDataGood.xlsx from GitHub
- Download ANES Time Series data from electionstudies.org
- Merge all data automatically
- Generate visualizations and regression models
- Map 2020 county data

**No manual downloads. No login required. Just run and go!**

### For Developers (If You Need to Reprocess Raw Data)

Only needed if you want to update the source ICPSR datasets:

1. **Download raw ICPSR data** (see MANUAL_DOWNLOAD_GUIDE.md)
2. **Run the processing script:**
   ```r
   source("PROCESS_RAW_DATA_ONCE.R")
   ```
3. **Commit the new processed files** to GitHub
4. Users automatically get the updated data!

## Repository Structure

```
Thesis/
├── data/
│   ├── processed/              # Pre-processed county-level data (COMMITTED)
│   │   ├── nanda_turnout_2016_onwards.csv
│   │   ├── urbanicity_data.csv
│   │   ├── county_connectivity_2010.csv
│   │   └── county_connectivity_2020.csv
│   ├── CountyDataGood.xlsx     # Base county data (COMMITTED)
│   └── anes_timeseries_cdf_csv_20220916.csv  # Auto-downloaded
├── FINAL2DATAWORKSHEET_UPDATED.R    # Main analysis script (RUN THIS)
├── PROCESS_RAW_DATA_ONCE.R          # One-time processing (developers only)
├── MANUAL_DOWNLOAD_GUIDE.md         # Manual download instructions
└── README.md                        # This file

NOT committed (in .gitignore):
├── data/raw/                   # Raw ICPSR files (if you download them)
└── .Rhistory, .RData, etc.
```

## Required R Packages

The script will check for and install these packages automatically:

- `dplyr`
- `tidyverse` 
- `stringr`
- `haven`
- `readxl`
- `readr`
- `ggplot2`

## Key Datasets Generated

After running the script, you'll have these analysis-ready datasets:

- `county_data_simplified` - Full merged dataset
- `county_data_presidential` - Presidential election margins by county
- `county_data_urbanicity` - Urban development metrics
- `presidential_thrice_flips` - Counties that flipped party 3 times
- `presidential_double_flips` - Counties that flipped party 2 times
- `anes_wave_respondents` - ANES respondent-level data
- `political_idealogy` - ANES political attitudes and thermometer ratings

## Visualizations

The script generates plots for:

- Urbanicity vs. election margins (2012, 2016, 2020)
- Block density vs. election margins
- Network density vs. election margins  
- Population change vs. election margins
- County typology distributions

## Regression Models

Bivariate and multivariate models examining:

- Urban percentage
- Block density
- Network density
- Node connectivity ratio

## Notes

- **Fully Reproducible**: Anyone can clone and run without manual downloads
- **ICPSR Compliance**: Raw data not redistributed; only aggregated county-level summaries
- **Fast Setup**: First run takes ~30 seconds (just downloads from GitHub + ANES)
- **Data Privacy**: `data/raw/` in .gitignore, `data/processed/` committed to repo
- **Research Best Practice**: This approach (sharing processed data) is standard in academic research

## About the Data

**For most users**: You don't need ICPSR access! The processed data is in the repo.

**If you want to reprocess from scratch**:
- The processed CSVs in `data/processed/` are aggregated from raw ICPSR datasets
- To regenerate them, download raw data (see MANUAL_DOWNLOAD_GUIDE.md)
- Run `PROCESS_RAW_DATA_ONCE.R` to create fresh processed files
- This respects ICPSR terms (we share aggregates, not raw microdata)

## Troubleshooting

**"Cannot download from GitHub"**
- Check your internet connection
- Verify the repo is public: https://github.com/eliza11494-hub/Thesis
- Make sure `data/processed/*.csv` files are committed to your repo

**"Column not found" errors**
- The processed data format might have changed
- Re-run `PROCESS_RAW_DATA_ONCE.R` to regenerate processed files

**"Package not found"**
- The script auto-installs missing packages
- If it fails, manually run `install.packages("package_name")`
- Update R to version 4.0 or higher

## Contact

Elizabeth Sedran  
Johns Hopkins University  
Thesis Project 2026
