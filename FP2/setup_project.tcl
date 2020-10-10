# Thanks to https://grittyengineer.com/vivado-project-mode-tcl-script/ for this script!

####################################################################
# EDIT 1: Change the name of the output folder on line 7 if you wish
####################################################################
# Create output folder and clear contents
set outputdir ./fp2
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
create_project -part xc7a100tcsg324-1 alu $outputdir

#add source files to Vivado project
add_files -fileset sim_1 ./alu_sim.vhd
# add_files [glob ./path/to/sources/*.vhd]
# add_files -fileset constrs_1 ./path/to/constraint/constraint.xdc
# add_files [glob ./path/to/library/sources/*.vhd]
# set_property -library userDefined [glob ./path/to/library/sources/*.vhd]
add_files [glob ./*.vhd]
#add_files -fileset constrs_1 ./Nexys4DDR_Master.xdc

####################################################################
# EDIT 3: Change the name of the top level vhdl module in your test bench
# on line 38 (e.g. change test_alu to your top level module name)
####################################################################
#set top level module and update compile order
set_property top alu [current_fileset]
# update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

#launch simulation
launch_simulation 

#launch synthesis
#launch_runs synth_1
#wait_on_run synth_1

#Run implementation and generate bitstream
#set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
#launch_runs impl_1 -to_step write_bitstream
#wait_on_run impl_1
#puts "Implementation done!"
