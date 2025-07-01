##########################################################################################
### Module Creator: R.T Lee    				##################################
### During : Sep.9 23						    ######################
### Project: EDA TOOLS Automative running script option	            ######################
### Version: V1                           					       ###
### Last updating date: Oct. 12 23 by huh					       ###
### Function: including vcs / cov / nWave                                              ###
##########################################################################################

TOP_Design = fx_pt_add_rnd_reg
run_file = run.f
fsdb_file = 
syn_lib = ADDER
Pttrn1 = FSDB
Pttrn2 = T_NUM=10000
Pttrn3 = SN=0
Pttrn4 = AIW=2
Pttrn5 = AFW=5
Pttrn6 = BIW=4
Pttrn7 = BFW=6
Pttrn8 = SFW=3
Pttrn9 = MSG

##########################################################################################
### vcs should be executed in the "sim/run" sub-directory.                             ###
##########################################################################################

vcs:
	vcs -f $(run_file) -kdb -lca -full64 -R +v2k \
            -debug_access+all  \
            +define+$(Pttrn1)+$(Pttrn2)+$(Pttrn3)+$(Pttrn4)+$(Pttrn5)+$(Pttrn6)+$(Pttrn7)+$(Pttrn8)+$(Pttrn9) \
            -l sim.log



##########################################################################################
### cov should be executed in the "sim/run" sub-directory.                             ###
##########################################################################################

cov:
	vcs -f $(run_file) -kdb -lca -full64 -cm cond+line+tgl+fsm+branch \
            -R +v2k -debug_access+all \
            +define+$(Pttrn1)+$(Pttrn2)+$(Pttrn3)+$(Pttrn4)+$(Pttrn5)+$(Pttrn6)+$(Pttrn7)+$(Pttrn8)+$(Pttrn9)\
            -l sim.log 
     
	verdi -cov -covdir simv.vdb &


##########################################################################################
### nWave should be executed in the "sim/run" sub-directory.                           ###
##########################################################################################

nWave:
	nWave -ssf $(fsdb_file).fsdb &


##########################################################################################
### syn should be executed in the "syn/run" sub-directory.                             ###
##########################################################################################

syn:
	dcnxt_shell -f dc_syn.tcl | tee -i ./syn.log &


##########################################################################################
### 99_clean can slove the issue of flashing windows when we run verdi.                ###
### 99_clean should be executed in the "sim/run" sub-directory.                        ###
##########################################################################################

99_clean:
	rm -rf novas.rc novas.fsdb novas.conf 
	rm -rf INCA_libs nWaveLog BSSLib.lib++


##########################################################################################
### clean_sim can clean all files(directories) in the "sim" sub-directory.             ###
### clean_sim should be executed in the "sim/run" sub-directory.                       ###
##########################################################################################

clean_sim:
	rm -rf unrSimv* simv* csrc* novas* *.log *key \
	*fsdb *Log *bak *el *report no_trace* vhdl* partition* \
	dprof* clk* *DB *dir work *lib verdi* *.history INCA_libs \
        *.svf	alib-52 *.pvl *.mr .fsm.* BSSLib.lib++



##########################################################################################
### clean_syn will clean all files(directories) in the "syn" sub-directory.            ###
### clean_syn should be executed in the "syn/run" sub-directory.                       ###
##########################################################################################

clean_syn:
	rm -rf *.log *bak *el *report no_trace* vhdl* partition* \
	dprof* clk* *DB *dir work *lib \
	*.ddc *.sdf *.svf *_syn.v *.qor alib-52 *.pvl *.syn *.mr \
        formality_svf FM_INFO reports $(syn_lib)

