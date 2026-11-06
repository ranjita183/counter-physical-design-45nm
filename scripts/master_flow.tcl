################################################################################
# Master Flow Script for 4-Bit Counter 45nm ASIC Physical Design (Cadence Innovus)
# Executes the Netlist-to-GDSII PnR flow modularly step-by-step.
################################################################################

puts "======================================================================"
puts "  [STEP 1/5] Executing Floorplanning & Physical Cell Insertion"
puts "======================================================================"
source ./scripts/floorplan_new.tcl

puts "======================================================================"
puts "  [STEP 2/5] Power Planning (Executed via floorplan_new.tcl)"
puts "======================================================================"
# Note: power_plan.tcl is modularly sourced within floorplan_new.tcl

puts "======================================================================"
puts "  [STEP 3/5] Executing Standard Cell Placement & Pre-CTS Optimization"
puts "======================================================================"
source ./scripts/placement.tcl

puts "======================================================================"
puts "  [STEP 4/5] Executing Clock Tree Synthesis (CTS - CCOpt)"
puts "======================================================================"
source ./scripts/cts.tcl

puts "======================================================================"
puts "  [STEP 5/5] Executing NanoRoute Global/Detail Routing & GDSII Stream-Out"
puts "======================================================================"
source ./scripts/route.tcl

puts "======================================================================"
puts "  ASIC Physical Design Flow Completed Successfully!"
puts "======================================================================"
