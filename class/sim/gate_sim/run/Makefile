##########################################################################################
### Module Creator: R.T Lee    				##################################
### During : Sep.9 23						    ######################
### Project: EDA TOOLS Automative running script option	            ######################
### Version: V1                           					       ###
### Last updating date: Oct. 12 23 by huh					       ###
### Function: including vcs / cov / nWave                                              ###
##########################################################################################

CFG = cfg3
TOP_Design = fx_pt_add_rnd_reg_$(CFG)
syn_file = $(TOP_Design)_syn.v
syn_test_file = $(TOP_Design)_syn_tb.v 
syn_lib = ADDER
FSDB = FSDB
MSG = MSG
PERIOD = PERIOD=10
Pttrn1 = T_NUM=10000
Pttrn2 = SN=2
Pttrn3 = AIW=11
Pttrn4 = AFW=9
Pttrn5 = BIW=8
Pttrn6 = BFW=10
Pttrn7 = SFW=8

##########################################################################################
### vcs_gate should be executed in the "sim/run" sub-directory.                        ###
##########################################################################################

vcs_gate:
	vcs +neg_tchk ../tb/$(syn_test_file)\
            ../../../syn/$(CFG)/run/$(syn_file) \
            -v /usr/cad/CBDK_IC_Contest_v2.1/Verilog/tsmc13.v \
            -R -debug_access+all +define+$(FSDB)+$(MSG)+$(PERIOD)+$(Pttrn1)+$(Pttrn2)+$(Pttrn3)+$(Pttrn4)+$(Pttrn5)+$(Pttrn6)+$(Pttrn7)\
            +lint=TFIPC-L -l sim.log

##########################################################################################
### vcs_gate should be executed in the "sim/run" sub-directory.                        ###
##########################################################################################

vcs_gate_neg:
	vcs +neg_tchk -negdelay \
            ../tb/$(syn_test_file)\
            ../../../syn/$(CFG)/run/$(syn_file) \
            -v /usr/cad/CBDK_IC_Contest_v2.1/Verilog/tsmc13_neg.v \
            -R -debug_access+all +define+$(FSDB)+$(MSG)+$(PERIOD)+$(Pttrn1)+$(Pttrn2)+$(Pttrn3)+$(Pttrn4)+$(Pttrn5)+$(Pttrn6)+$(Pttrn7)\
            +lint=TFIPC-L -l sim.log

##########################################################################################
### syn should be executed in the "syn/run" sub-directory.                                 ###
##########################################################################################

dc:
	dc_shell-xg-t -f ../tcl/dc_syn.tcl | tee -i ./syn.log &
 
dcnxt:
	dcnxt_shell -f ../tcl/dc_syn.tcl | tee -i ./syn.log &


##########################################################################################
### 99_clean can slove the issue of flashing windows when we run verdi.                ###
### 99_clean should be executed in the "sim/run" sub-directory.                            ###
##########################################################################################

99_clean:
	rm -rf novas.rc novas.fsdb novas.conf 
	rm -rf INCA_libs nWaveLog BSSLib.lib++


##########################################################################################
### clean_sim can clean all files(directories) in the "sim" sub-directory.             ###
### clean_sim should be executed in the "sim/run" sub-directory.                           ###
##########################################################################################

clean_sim:
	rm -rf unrSimv* simv* csrc* novas* *.log *key \
	*fsdb *Log *bak *el *report no_trace* vhdl* partition* \
	dprof* clk* *DB *dir work *lib verdi* *.history INCA_libs \
        *.svf	alib-52 *.pvl *.mr .fsm.* BSSLib.lib++



##########################################################################################
### clean_syn will clean all files(directories) in the "syn" sub-directory.            ###
### clean_syn should be executed in the "syn/run" sub-directory.                           ###
##########################################################################################

clean_syn:
	rm -rf *.log *bak *el *report no_trace* vhdl* partition* \
	dprof* clk* *DB *dir work *lib \
	*.ddc *.sdf *.svf *_syn.v *.qor alib-52 *.pvl *.syn *.mr \
        formality_svf FM_INFO reports $(syn_lib)

