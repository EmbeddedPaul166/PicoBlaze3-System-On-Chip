
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name PUR_Project -dir "/home/paul/Documents/Laboratory_reports/PUR/PUR_Project/PUR_Project/planAhead_run_2" -part xc3s50atq144-5
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/paul/Documents/Laboratory_reports/PUR/PUR_Project/PUR_Project/top_cs.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/paul/Documents/Laboratory_reports/PUR/PUR_Project/PUR_Project} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "top.ucf" [current_fileset -constrset]
add_files [list {top.ucf}] -fileset [get_property constrset [current_run]]
link_design
