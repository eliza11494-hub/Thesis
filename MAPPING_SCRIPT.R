# THESIS MAPPING SCRIPT
# Creates county-level maps of block density and 2020 election margins
# Requires: FINAL2DATAWORKSHEET_GITHUB.R to be run first
# Author: Elizabeth Sedran

# =============================================================================
# SETUP & LIBRARY LOADING
# =============================================================================

cat("=================================================================\n")
cat("THESIS MAPPING SCRIPT\n")
cat("=================================================================\n\n")

# Install packages if needed
required_packages <- c("ggplot2", "maps", "dplyr", "mapproj")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(ggplot2)
library(maps)
library(dplyr)
library(mapproj)

# =============================================================================
# CHECK IF DATA IS LOADED
# =============================================================================

if (!exists("county_data_urbanicity")) {
  cat("⚠️  ERROR: Data not loaded!\n")
  cat("Please run FINAL2DATAWORKSHEET_GITHUB.R first.\n")
  cat("Then run this script.\n\n")
  stop("Data not found. Run main analysis script first.")
}

cat("✓ Data loaded successfully\n\n")

# =============================================================================
# PREPARE MAP DATA
# =============================================================================

cat("Preparing map data...\n")

# Get county map data from maps package
county_map <- map_data("county")

# Get FIPS lookup data
data(county.fips)

# Prepare the FIPS lookup
fips_lookup <- county.fips %>%
  tidyr::separate(polyname, c("region", "subregion"), sep = ",") %>%
  mutate(fips = sprintf("%05d", fips))  # Ensure FIPS is 5 digits with leading zeros

# Make sure your FIPS codes are formatted correctly
county_data_urbanicity <- county_data_urbanicity %>%
  mutate(Fips = sprintf("%05d", as.numeric(Fips)))

# Merge the map data with FIPS lookup
map_with_fips <- county_map %>%
  left_join(fips_lookup, by = c("region", "subregion"))

# Merge with your block density and election data
map_data_final <- map_with_fips %>%
  left_join(county_data_urbanicity, by = c("fips" = "Fips"))

cat("✓ Map data prepared\n\n")

# =============================================================================
# MAP 1: AVERAGE BLOCK DENSITY 2020
# =============================================================================

cat("Creating block density map...\n")

block_density_map <- ggplot(map_data_final, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = avg_block_density_2020), color = "white", size = 0.1) +
  coord_map("albers", lat0 = 39, lat1 = 45) +  # Albers projection for US maps
  scale_fill_gradient(
    low = "lightyellow", 
    high = "darkred", 
    na.value = "grey90",
    name = "Avg Block\nDensity 2020"
  ) +
  labs(
    title = "Average Block Density by County (2020)",
    subtitle = "Darker colors indicate higher block density",
    caption = "Grey areas indicate missing data"
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    legend.position = "right"
  )

print(block_density_map)

cat("✓ Block density map created\n")

# =============================================================================
# MAP 2: 2020 ELECTION MARGINS
# =============================================================================

cat("Creating 2020 election margins map...\n")

# Create a diverging color scale for margins
# Negative = Republican (red), Positive = Democratic (blue)
election_map_2020 <- ggplot(map_data_final, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = Margin_2020_GOPnegative), color = "white", size = 0.1) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  scale_fill_gradient2(
    low = "red",           # Republican
    mid = "white",         # Competitive
    high = "blue",         # Democratic
    midpoint = 0,
    na.value = "grey90",
    name = "2020\nMargin",
    limits = c(-100, 100),
    breaks = c(-75, -50, -25, 0, 25, 50, 75),
    labels = c("R+75", "R+50", "R+25", "0", "D+25", "D+50", "D+75")
  ) +
  labs(
    title = "2020 Presidential Election Margins by County",
    subtitle = "Blue = Biden won, Red = Trump won",
    caption = "Grey areas indicate missing data"
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    legend.position = "right"
  )

print(election_map_2020)

cat("✓ Election margins map created\n")

# =============================================================================
# MAP 3: URBANICITY (% URBAN)
# =============================================================================

cat("Creating urbanicity map...\n")

urbanicity_map <- ggplot(map_data_final, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = `% Urban`), color = "white", size = 0.1) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  scale_fill_gradient(
    low = "lightgreen",
    high = "darkgreen",
    na.value = "grey90",
    name = "% Urban",
    limits = c(0, 100)
  ) +
  labs(
    title = "Urbanicity by County",
    subtitle = "Darker green indicates higher percentage of urban population",
    caption = "Grey areas indicate missing data"
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    legend.position = "right"
  )

print(urbanicity_map)

cat("✓ Urbanicity map created\n")

# =============================================================================
# MAP 4: CONNECTIVITY (AVG NODE CONNECTIVITY RATIO 2020)
# =============================================================================

cat("Creating connectivity map...\n")

connectivity_map <- ggplot(map_data_final, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = avg_conNodeRatio_2020), color = "white", size = 0.1) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  scale_fill_gradient(
    low = "lightyellow",
    high = "darkorange",
    na.value = "grey90",
    name = "Connectivity\nNode Ratio\n(2020)"
  ) +
  labs(
    title = "Street Connectivity by County (2020)",
    subtitle = "Higher values indicate more connected street networks",
    caption = "Grey areas indicate missing data"
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    legend.position = "right"
  )

print(connectivity_map)

cat("✓ Connectivity map created\n")

# =============================================================================
# MAP 5: POPULATION CHANGE (2010-2018)
# =============================================================================

cat("Creating population change map...\n")

population_change_map <- ggplot(map_data_final, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = `% 2010-2018 Population Change`), color = "white", size = 0.1) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  scale_fill_gradient2(
    low = "darkred",      # Population loss
    mid = "white",        # No change
    high = "darkblue",    # Population gain
    midpoint = 0,
    na.value = "grey90",
    name = "Population\nChange\n(2010-2018)",
    limits = c(-0.4, 0.4),
    labels = scales::percent
  ) +
  labs(
    title = "Population Change by County (2010-2018)",
    subtitle = "Blue = Population growth | Red = Population decline",
    caption = "Grey areas indicate missing data"
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    legend.position = "right"
  )

print(population_change_map)

cat("✓ Population change map created\n")

# =============================================================================
# MAP 6: OVERLAY MAP - BLOCK DENSITY WITH ELECTION RESULTS
# =============================================================================

cat("\nCreating overlay map (block density + election results)...\n")

# Create categories for clearer visualization
map_data_final <- map_data_final %>%
  mutate(
    density_category = cut(avg_block_density_2020, 
                          breaks = c(-Inf, 10, 20, 30, Inf),
                          labels = c("Low (< 10)", "Medium (10-20)", "High (20-30)", "Very High (> 30)")),
    election_result = case_when(
      Margin_2020_GOPnegative > 10 ~ "Strong Biden",
      Margin_2020_GOPnegative > 0 ~ "Lean Biden",
      Margin_2020_GOPnegative > -10 ~ "Lean Trump",
      TRUE ~ "Strong Trump"
    )
  )

# Overlay map: Use block density as fill, election results as border color
overlay_map <- ggplot(map_data_final, aes(x = long, y = lat, group = group)) +
  geom_polygon(
    aes(fill = avg_block_density_2020, color = Margin_2020_GOPnegative), 
    size = 0.3
  ) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  scale_fill_gradient(
    low = "lightyellow", 
    high = "darkred", 
    na.value = "grey90",
    name = "Block Density\n(2020)"
  ) +
  scale_color_gradient2(
    low = "red",
    mid = "purple",
    high = "blue",
    midpoint = 0,
    na.value = "grey70",
    name = "2020 Margin\n(Border Color)"
  ) +
  labs(
    title = "Block Density with 2020 Election Results Overlay",
    subtitle = "Fill = Block Density | Border = Election Result (Red=Trump, Blue=Biden)",
    caption = "Counties with high density and blue borders voted for Biden with high density"
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11),
    legend.position = "right"
  )

print(overlay_map)

cat("✓ Overlay map created\n")

# =============================================================================
# MAP 7: FACETED BY BLOCK DENSITY CATEGORY
# =============================================================================

cat("Creating faceted overlay map (by block density)...\n")

# Create a map that shows election results within density categories
faceted_overlay_density <- ggplot(
  map_data_final %>% filter(!is.na(density_category)), 
  aes(x = long, y = lat, group = group)
) +
  geom_polygon(aes(fill = Margin_2020_GOPnegative), color = "white", size = 0.05) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    na.value = "grey90",
    name = "2020\nMargin"
  ) +
  facet_wrap(~ density_category, ncol = 2) +
  labs(
    title = "2020 Election Results by Block Density Category",
    subtitle = "How counties voted based on their average block density"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5),
    strip.text = element_text(size = 12, face = "bold"),
    legend.position = "bottom"
  )

print(faceted_overlay_density)

cat("✓ Faceted overlay map (block density) created\n")

cat("\nBlock Density Categories Used:\n")
cat("  Low:       < 10 blocks per square mile\n")
cat("  Medium:    10-20 blocks per square mile\n")
cat("  High:      20-30 blocks per square mile\n")
cat("  Very High: > 30 blocks per square mile\n\n")

# =============================================================================
# MAP 8: FACETED BY URBANICITY CATEGORY
# =============================================================================

cat("Creating faceted overlay map (by urbanicity)...\n")

# Create urbanicity categories
map_data_final <- map_data_final %>%
  mutate(
    urbanicity_category = cut(`% Urban`, 
                              breaks = c(-Inf, 25, 50, 75, 100),
                              labels = c("Rural (<25%)", "Low Urban (25-50%)", 
                                        "Urban (50-75%)", "Highly Urban (>75%)"))
  )

# Create a map that shows election results within urbanicity categories
faceted_overlay_urbanicity <- ggplot(
  map_data_final %>% filter(!is.na(urbanicity_category)), 
  aes(x = long, y = lat, group = group)
) +
  geom_polygon(aes(fill = Margin_2020_GOPnegative), color = "white", size = 0.05) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    na.value = "grey90",
    name = "2020\nMargin"
  ) +
  facet_wrap(~ urbanicity_category, ncol = 2) +
  labs(
    title = "2020 Election Results by Urbanicity Category",
    subtitle = "How counties voted based on their urbanicity"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5),
    strip.text = element_text(size = 12, face = "bold"),
    legend.position = "bottom"
  )

print(faceted_overlay_urbanicity)

cat("✓ Faceted overlay map (urbanicity) created\n")

cat("\nUrbanicity Categories Used:\n")
cat("  Rural:           < 25% urban\n")
cat("  Low Urban:       25-50% urban\n")
cat("  Urban:           50-75% urban\n")
cat("  Highly Urban:    > 75% urban\n\n")

# =============================================================================
# MAP 8: COMBINED VIEW (UPDATED)
# =============================================================================

cat("\nCreating combined comparison map...\n")

# Create a version that shows both side by side
library(gridExtra)

# Simpler versions for side-by-side
map1_simple <- ggplot(map_data_final, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = avg_block_density_2020), color = "white", size = 0.05) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  scale_fill_gradient(
    low = "lightyellow", 
    high = "darkred", 
    na.value = "grey90",
    name = "Block\nDensity"
  ) +
  labs(title = "Block Density (2020)") +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    legend.position = "bottom"
  )

map2_simple <- ggplot(map_data_final, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = Margin_2020_GOPnegative), color = "white", size = 0.05) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    na.value = "grey90",
    name = "Margin"
  ) +
  labs(title = "2020 Election Margins") +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    legend.position = "bottom"
  )

combined_map <- grid.arrange(map1_simple, map2_simple, ncol = 2)

cat("✓ Combined map created\n")

# =============================================================================
# SAVE MAPS
# =============================================================================

cat("\nSaving maps...\n")

# Save individual maps
ggsave("block_density_map_2020.png", plot = block_density_map, 
       width = 12, height = 8, dpi = 300)
cat("✓ Saved: block_density_map_2020.png\n")

ggsave("election_margins_map_2020.png", plot = election_map_2020, 
       width = 12, height = 8, dpi = 300)
cat("✓ Saved: election_margins_map_2020.png\n")

ggsave("urbanicity_map.png", plot = urbanicity_map, 
       width = 12, height = 8, dpi = 300)
cat("✓ Saved: urbanicity_map.png\n")

ggsave("connectivity_map.png", plot = connectivity_map, 
       width = 12, height = 8, dpi = 300)
cat("✓ Saved: connectivity_map.png\n")

ggsave("population_change_map.png", plot = population_change_map, 
       width = 12, height = 8, dpi = 300)
cat("✓ Saved: population_change_map.png\n")

ggsave("overlay_map.png", plot = overlay_map, 
       width = 14, height = 8, dpi = 300)
cat("✓ Saved: overlay_map.png\n")

ggsave("faceted_density_map.png", plot = faceted_overlay_density, 
       width = 14, height = 10, dpi = 300)
cat("✓ Saved: faceted_density_map.png\n")

ggsave("faceted_urbanicity_map.png", plot = faceted_overlay_urbanicity, 
       width = 14, height = 10, dpi = 300)
cat("✓ Saved: faceted_urbanicity_map.png\n")

ggsave("combined_comparison_map.png", plot = combined_map, 
       width = 16, height = 6, dpi = 300)
cat("✓ Saved: combined_comparison_map.png\n")

# =============================================================================
# SUMMARY STATISTICS FOR MAPPED DATA
# =============================================================================

cat("\n=================================================================\n")
cat("MAPPING SUMMARY STATISTICS\n")
cat("=================================================================\n\n")

cat("Block Density 2020:\n")
cat("  Min:    ", min(county_data_urbanicity$avg_block_density_2020, na.rm = TRUE), "\n")
cat("  Max:    ", max(county_data_urbanicity$avg_block_density_2020, na.rm = TRUE), "\n")
cat("  Mean:   ", mean(county_data_urbanicity$avg_block_density_2020, na.rm = TRUE), "\n")
cat("  Median: ", median(county_data_urbanicity$avg_block_density_2020, na.rm = TRUE), "\n")
cat("  Counties with data: ", sum(!is.na(county_data_urbanicity$avg_block_density_2020)), "\n")
cat("  By Category:\n")
cat("    Low (< 10):        ", sum(county_data_urbanicity$avg_block_density_2020 < 10, na.rm = TRUE), " counties\n")
cat("    Medium (10-20):    ", sum(county_data_urbanicity$avg_block_density_2020 >= 10 & 
                                     county_data_urbanicity$avg_block_density_2020 < 20, na.rm = TRUE), " counties\n")
cat("    High (20-30):      ", sum(county_data_urbanicity$avg_block_density_2020 >= 20 & 
                                     county_data_urbanicity$avg_block_density_2020 < 30, na.rm = TRUE), " counties\n")
cat("    Very High (> 30):  ", sum(county_data_urbanicity$avg_block_density_2020 >= 30, na.rm = TRUE), " counties\n")
cat("\n")

cat("2020 Election Margins:\n")
cat("  Min (R):    ", min(county_data_urbanicity$Margin_2020_GOPnegative, na.rm = TRUE), "\n")
cat("  Max (D):    ", max(county_data_urbanicity$Margin_2020_GOPnegative, na.rm = TRUE), "\n")
cat("  Mean:       ", mean(county_data_urbanicity$Margin_2020_GOPnegative, na.rm = TRUE), "\n")
cat("  Median:     ", median(county_data_urbanicity$Margin_2020_GOPnegative, na.rm = TRUE), "\n")
cat("  Counties Biden won:  ", sum(county_data_urbanicity$Margin_2020_GOPnegative > 0, na.rm = TRUE), "\n")
cat("  Counties Trump won:  ", sum(county_data_urbanicity$Margin_2020_GOPnegative < 0, na.rm = TRUE), "\n")
cat("  Counties with data:  ", sum(!is.na(county_data_urbanicity$Margin_2020_GOPnegative)), "\n\n")

cat("Urbanicity (% Urban):\n")
cat("  Min:    ", min(county_data_urbanicity$`% Urban`, na.rm = TRUE), "%\n")
cat("  Max:    ", max(county_data_urbanicity$`% Urban`, na.rm = TRUE), "%\n")
cat("  Mean:   ", mean(county_data_urbanicity$`% Urban`, na.rm = TRUE), "%\n")
cat("  Median: ", median(county_data_urbanicity$`% Urban`, na.rm = TRUE), "%\n")
cat("  Counties with data: ", sum(!is.na(county_data_urbanicity$`% Urban`)), "\n\n")

cat("Street Connectivity 2020:\n")
cat("  Min:    ", min(county_data_urbanicity$avg_conNodeRatio_2020, na.rm = TRUE), "\n")
cat("  Max:    ", max(county_data_urbanicity$avg_conNodeRatio_2020, na.rm = TRUE), "\n")
cat("  Mean:   ", mean(county_data_urbanicity$avg_conNodeRatio_2020, na.rm = TRUE), "\n")
cat("  Median: ", median(county_data_urbanicity$avg_conNodeRatio_2020, na.rm = TRUE), "\n")
cat("  Counties with data: ", sum(!is.na(county_data_urbanicity$avg_conNodeRatio_2020)), "\n\n")

cat("Population Change 2010-2018:\n")
cat("  Min (decline): ", min(county_data_urbanicity$`% 2010-2018 Population Change`, na.rm = TRUE) * 100, "%\n")
cat("  Max (growth):  ", max(county_data_urbanicity$`% 2010-2018 Population Change`, na.rm = TRUE) * 100, "%\n")
cat("  Mean:          ", mean(county_data_urbanicity$`% 2010-2018 Population Change`, na.rm = TRUE) * 100, "%\n")
cat("  Median:        ", median(county_data_urbanicity$`% 2010-2018 Population Change`, na.rm = TRUE) * 100, "%\n")
cat("  Counties growing:   ", sum(county_data_urbanicity$`% 2010-2018 Population Change` > 0, na.rm = TRUE), "\n")
cat("  Counties declining: ", sum(county_data_urbanicity$`% 2010-2018 Population Change` < 0, na.rm = TRUE), "\n")
cat("  Counties with data: ", sum(!is.na(county_data_urbanicity$`% 2010-2018 Population Change`)), "\n\n")

# =============================================================================
# SCRIPT COMPLETE
# =============================================================================

cat("=================================================================\n")
cat("✓✓✓ MAPPING COMPLETE! ✓✓✓\n")
cat("=================================================================\n\n")

cat("Maps created:\n")
cat("  1. block_density_map_2020 (variable)\n")
cat("  2. election_map_2020 (variable)\n")
cat("  3. urbanicity_map (variable)\n")
cat("  4. connectivity_map (variable)\n")
cat("  5. population_change_map (variable)\n")
cat("  6. overlay_map (variable)\n")
cat("  7. faceted_overlay_density (variable) ← Elections by BLOCK DENSITY!\n")
cat("  8. faceted_overlay_urbanicity (variable) ← Elections by URBANICITY!\n")
cat("  9. combined_map (variable)\n\n")

cat("Files saved:\n")
cat("  1. block_density_map_2020.png\n")
cat("  2. election_margins_map_2020.png\n")
cat("  3. urbanicity_map.png\n")
cat("  4. connectivity_map.png\n")
cat("  5. population_change_map.png\n")
cat("  6. overlay_map.png\n")
cat("  7. faceted_density_map.png ← Elections by block density!\n")
cat("  8. faceted_urbanicity_map.png ← Elections by urbanicity!\n")
cat("  9. combined_comparison_map.png\n\n")

cat("To view maps in R, use:\n")
cat("  print(block_density_map)\n")
cat("  print(election_map_2020)\n")
cat("  print(urbanicity_map)\n")
cat("  print(connectivity_map)\n")
cat("  print(population_change_map)\n")
cat("  print(overlay_map)\n")
cat("  print(faceted_overlay_density)\n")
cat("  print(faceted_overlay_urbanicity)\n")
cat("  print(combined_map)\n\n")


