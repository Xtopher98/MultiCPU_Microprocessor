# Thanks to https://grittyengineer.com/vivado-project-mode-tcl-script/ for this script!
# Also thanks to https://www.eevblog.com/forum/fpga/using-vivado-in-tcl-mode/ for simulation 
# configuration information!

####################################################################
# EDIT 1: Change the name of the output folder on line 7 if you wish
####################################################################
# Create output folder and clear contents
set outputdir ./FP3
file mkdir $outputdir
set files [glob -nocomplain "$outputdir/*"]
if {[llength $files] != 0} {
    puts "deleting contents of $outputdir"
    file delete -force {*}[glob -directory $outputdir *]; # clear folder contents
} else {
    puts "$outputdir is empty"
}

####################################################################
# EDIT 2: Change the name of the top level vhdl module in your test bench
# on line 22 (e.g. change test_alu to your top level module name)
####################################################################
#Create project
create_project -part xc7a100tcsg324-1 gpu $outputdir

# Example commands for adding files to the project
# add_files [glob ./path/to/sources/*.vhd]
# add_files -fileset constrs_1 ./path/to/constraint/constraint.xdc
# add_files [glob ./path/to/library/sources/*.vhd]
# set_property -library userDefined [glob ./path/to/library/sources/*.vhd]

# add source files for the  Vivado simulation project
add_files -fileset sim_1 ./testbench.vhd

# add source files for the FPGA board project
add_files [glob ./*.vhd] 
add_files -fileset constrs_1 ./Nexys4DDR_Master.xdc

####################################################################
# EDIT 3: Change the name of the top level vhdl module in your test bench
# on line 42 (e.g. change test_alu to your top level module name)
####################################################################
#set top level module and update compile order
set_property top gpu [current_fileset]
set_property top testbench [get_fileset sim_1]

# Set the compile order for both the FPGA project and simulation
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

#launch simulation
launch_simulation -simset sim_1 -mode behavioral

#launch synthesis
launch_runs synth_1
wait_on_run synth_1

#Run implementation and generate bitstream
####set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
####launch_runs impl_1 -to_step write_bitstream
####wait_on_run impl_1
puts "Implementation done!"