################################################################################
# GLOBAL & DETAIL ROUTING (NanoRoute)
# Performs global routing, detail routing, antenna fixing, DRC & GDS export.
################################################################################

# Set routing layer limits
setDesignMode -bottomRoutingLayer 1
setDesignMode -topRoutingLayer 7

# NanoRoute configuration
setNanoRouteMode -route_detail_fix_antenna true

# Run Global & Detail Routing
routeDesign -globalDetail

# Check connectivity and fix open nets
verifyConnectivity
ecoRoute

# Perform DRC checks
verify_drc -limit 0

# Fix DRC and Antenna violations
setNanoRouteMode -route_with_eco true
setNanoRouteMode -route_antenna_diode_insertion true
setNanoRouteMode -route_antenna_cell_name ANTENNA
editDelete -regular_wire_with_drc
ecoRoute

# Report Post-Route Timing
setAnalysisMode -analysisType onChipVariation
timeDesign -postRoute
timeDesign -postRoute -hold

saveDesign ./design/route.enc

# Stream out final layout to GDSII format
streamOut -merge {/home/chethan/BMSIT_WORKSHOP/libs/gds/gsclib045.gds /home/chethan/BMSIT_WORKSHOP/libs/gds/gsclib045_hvt.gds /home/chethan/BMSIT_WORKSHOP/libs/gds/gsclib045_lvt.gds} ./outputs/final.gds
