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

