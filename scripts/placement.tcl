################################################################################
# PLACEMENT
# Assigns physical locations to standard cells, optimizes for timing and
# congestion, and legalizes cell positions on the placement grid.
################################################################################

# --- Pre-Placement Checks & Settings ---
checkDesign -floorplan
checkFPlan -reportUtil

# Enable route-aware detail placement checks; cap max global placement density at 70%
setPlaceMode -place_detail_check_route true
setPlaceMode -place_global_max_density 0.70
setPlaceMode -place_global_uniform_density true

# Activate constraint modes and fanout limit
set_interactive_constraint_modes [all_constraint_modes -active]
set_max_fanout 18 [dbGet top.name]

# Set routing layer bounds (Metal1 to Metal7)
setDesignMode -topRoutingLayer 7
setDesignMode -bottomRoutingLayer 1

# Specify MMMC analysis views for setup (func_ss) and hold (func_ff) timing
set_analysis_view -setup func_ss -hold func_ff

# --- Running Placement ---
place_design
checkPlace
refinePlace
place_opt_design

# Save checkpoint
saveDesign ./design/placement_new.enc

# --- Congestion Analysis & Timing Checks ---
reportCongestion -3d -overflow
timeDesign -preCTS -outDir ./reports/placement -prefix prects

saveDesign ./design/placement_new.enc
