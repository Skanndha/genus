set_db init_hdl_search_path ../rtl 
set_db init_lib_search_path ../lib
set_db library {fast_vdd1v0_basicCells.lib slow_vdd1v0_basicCells.lib}

# Ensure correct HDL file list
read_hdl top_noc_to_ram.v decoder.v extractor.v ram_16kx16.v

# Elaborate the design
elaborate top_noc_to_ram -parameters {6 14 32}

# Read and apply constraints
read_sdc ../constraints/constraints.g

# Generate reports
report timing
report power

# Perform synthesis
syn_generic
syn_map

# Save reports and outputs
report timing > ../output/timing_report.rpt
report power > ../output/power_report.rpt
report area > ../output/area_report.rpt
write_hdl > ../output/evm_mapped.v
write_sdc > ../output/evm_sdc.sdc



# Set up the environment
set_db init_hdl_search_path ../rtl 
set_db init_lib_search_path ../lib
set_db library {fast_vdd1v0_basicCells.lib slow_vdd1v0_basicCells.lib}

# Read the HDL files (Ensure all paths are correct)
read_hdl top_noc_to_ram.v
read_hdl decoder.v
read_hdl extractor.v
read_hdl ram_16kx16.v

# Elaborate the top-level design
elaborate top_noc_to_ram -parameters {BUFFER_DEPTH=6 ADDR_WIDTH=14 DATA_WIDTH=32}

# Read constraints (Ensure the SDC file path is correct and matches your design)
read_sdc ../constraints/constraints.g

# Check design after elaboration
check_design > ../output/design_checks.rpt

# Generate initial reports
report timing > ../output/pre_synthesis_timing.rpt
report power > ../output/pre_synthesis_power.rpt
report area > ../output/pre_synthesis_area.rpt

# Perform synthesis
syn_generic
syn_map

# Check design integrity post-synthesis
check_design > ../output/post_synthesis_design_checks.rpt

# Generate reports after synthesis
report timing > ../output/post_synthesis_timing.rpt
report power > ../output/post_synthesis_power.rpt
report area > ../output/post_synthesis_area.rpt

# Save synthesized netlist and constraints
write_hdl > ../output/synthesized_netlist.v
write_sdc > ../output/synthesized_constraints.sdc

