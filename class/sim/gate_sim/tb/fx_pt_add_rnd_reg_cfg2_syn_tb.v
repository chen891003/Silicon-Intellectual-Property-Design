`timescale 1ns / 100ps

`ifndef  SN
`define  SN 1
`endif

`ifndef  AIW
`define  AIW 2
`endif

`ifndef  AFW
`define  AFW 10
`endif

`ifndef  BIW
`define  BIW 4
`endif

`ifndef  BFW
`define  BFW 8
`endif

`ifndef  SFW
`define  SFW 3
`endif

`ifndef  T_NUM
`define  T_NUM 10000
`endif

`ifndef  PERIOD
`define  PERIOD 10
`endif

module fx_pt_add_rnd_reg_syn_tb;

parameter SN = `SN;
parameter AIW = `AIW;
parameter AFW = `AFW;
parameter BIW = `BIW;
parameter BFW = `BFW;
parameter SIW = (AIW>BIW)? AIW+2:BIW+2;
parameter SFW = `SFW;

reg  rst, clk;
reg  [AIW+AFW-1:0] in_a_t, a_t; 
reg  [BIW+BFW-1:0] in_b_t, b_t;
wire [SIW+SFW-1:0] sum_reg_t; 

reg     [SIW+SFW-1:0] sum_gld, sum_reg_gld;         // the correct result 

//for test signal

integer err_count;

integer i;
integer seed1;
integer seed2;

real a_f, b_f, sum_f, sum_f_rnd;
real a_t_f, b_t_f;

reg  signed [AIW+AFW-1:0] a_t_s; 
reg  signed [BIW+BFW-1:0] b_t_s; 

integer a_t_i, b_t_i;

reg  a_t_sgn, b_t_sgn;

reg  [AIW+AFW-2:0] a_t_mag; 
reg  [BIW+BFW-2:0] b_t_mag;

integer a_t_mag_i, b_t_mag_i;

integer a_deno, b_deno, sum_deno;
real a_deno_f, b_deno_f;

reg sum_sgn;
reg [SIW+SFW-2:0] sum_mag;

`ifdef  FSDB
reg [100*8-1:0] fsdb_name;
`endif

initial clk = 1'b0;
always 
begin
  #(`PERIOD/2)         clk = ~clk;
  #(`PERIOD-`PERIOD/2) clk = ~clk;
end



//assign random input values

initial
begin
#0  rst = 1'b1;
 
    seed1=1;
    seed2=2;

    in_a_t = {(AIW+AFW){1'b0}};
    in_b_t = {(BIW+BFW){1'b0}};
    a_t = {(AIW+AFW){1'b0}};
    b_t = {(BIW+BFW){1'b0}};

    sum_gld = {(SIW+SFW){1'b0}};
    sum_reg_gld = {(SIW+SFW){1'b0}};
  
    err_count=0;

#(`PERIOD) rst = 1'b0;
#(`PERIOD) rst = 1'b1;

  for(i=0; i<`T_NUM; i=i+1)
     begin
       @(posedge clk)
       case(i)
       0: begin
            in_a_t<=#3 {(AIW+AFW){1'b1}};
            in_b_t<=#3 {(BIW+BFW){1'b1}};
          end
       1: begin
            in_a_t<=#3 {1'b0,{(AIW+AFW-1){1'b1}}};
            in_b_t<=#3 {1'b0,{(BIW+BFW-1){1'b1}}};
          end
       2: begin
            in_a_t<=#3 {1'b0,{(AIW+AFW-1){1'b1}}};
            in_b_t<=#3 {1'b1,{(BIW+BFW-1){1'b1}}};
          end
       3: begin
            in_a_t<=#3 {1'b1,{(AIW+AFW-1){1'b1}}};
            in_b_t<=#3 {1'b0,{(BIW+BFW-1){1'b1}}};
          end
       4: begin
            in_a_t<=#3 {1'b1,{(AIW+AFW-1){1'b0}}};
            in_b_t<=#3 {1'b0,{(BIW+BFW-1){1'b0}}};
          end
       5: begin
            in_a_t<=#3 {1'b1,{(AIW+AFW-1){1'b0}}};
            in_b_t<=#3 {1'b1,{(BIW+BFW-1){1'b0}}};
          end
       6: begin
            in_a_t<=#3 {1'b0,{(AIW+AFW-1){1'b0}}};
            in_b_t<=#3 {1'b0,{(BIW+BFW-1){1'b0}}};
          end
       7: begin
            in_a_t<=#3 {1'b0,{(AIW+AFW-1){1'b0}}};
            in_b_t<=#3 {1'b1,{(BIW+BFW-1){1'b0}}};
          end
       default:begin
                 in_a_t<=#3 $random(seed1);
                 in_b_t<=#3 $random(seed2);
	       end
       endcase

       a_t <= in_a_t;
       b_t <= in_b_t;
       sum_reg_gld <= sum_gld;

       #0.1;
	
       a_t_s = a_t;  // unsigned to signed
       b_t_s = b_t;  // unsigned to signed	
		
       a_t_i = a_t;  // unsigned to integer(signed)
       b_t_i = b_t;  // unsigned to integer(signed)
			
       a_t_sgn = a_t[AIW+AFW-1]; // sign of a_t
       b_t_sgn = b_t[BIW+BFW-1]; // sign of b_t		
			
       a_t_mag = a_t[AIW+AFW-2:0]; // mag of a_t
       b_t_mag = b_t[BIW+BFW-2:0]; // mag of b_t
			
       a_t_mag_i = a_t_mag; // unsigned mag to integer(signed)
       b_t_mag_i = b_t_mag; // unsigned mag to integer(signed)
			
       a_deno=1<<(AFW); // denominator of a for fixed point(integer)
       b_deno=1<<(BFW); // denominator of b for fixed point(integer)
       sum_deno=1<<(SFW); // denominator of sum for fixed point(integer)
			
       a_deno_f = a_deno; // integer to real
       b_deno_f = b_deno; // integer to real
			
       case(SN)
         0: begin
              a_t_f = a_t_i; // integer to real
              b_t_f = b_t_i; // integer to real
              a_f = a_t_f/a_deno_f;
              b_f = b_t_f/b_deno_f;
              sum_f = a_f+b_f;
              sum_f_rnd = $floor(sum_f*sum_deno+0.5); //round
              sum_gld = sum_f_rnd; // real to integer
            end

         1: begin
              a_t_f = a_t_s; //signed to real
              b_t_f = b_t_s; //signed to real
              a_f = a_t_f/a_deno_f;
              b_f = b_t_f/b_deno_f;
              sum_f = a_f+b_f;
				  if(sum_f>=0.0)
				     sum_f_rnd = $floor(sum_f*sum_deno+0.5); //round
				  else
                 sum_f_rnd = $ceil(sum_f*sum_deno-0.5); //round
              sum_gld = sum_f_rnd; // real to integer
            end

         default: begin
		     a_t_f = a_t_sgn ? -a_t_mag_i:a_t_mag_i; //signed to real
		     b_t_f = b_t_sgn ? -b_t_mag_i:b_t_mag_i; //signed to real
		     a_f = a_t_f/a_deno_f;
	             b_f = b_t_f/b_deno_f;
		     sum_f = a_f+b_f;
		     
           if(sum_f>=0.0)
	         begin
			 sum_sgn = 1'b0;
			 sum_f_rnd = $floor(sum_f*sum_deno+0.5); //round
			 sum_mag = sum_f_rnd; // real to integer
                         if(sum_mag==0)
		            sum_gld = {1'b0,sum_mag};
                         else sum_gld = {sum_sgn,sum_mag};
	         end 
           else
	         begin 
                         sum_sgn = 1'b1;
			 sum_f_rnd = $floor(-sum_f*sum_deno+0.5); //round
			 sum_mag = sum_f_rnd; // real to integer
			 if(sum_mag==0)
		            sum_gld = {1'b0,sum_mag};
                         else sum_gld = {sum_sgn,sum_mag};
		  end						   
	end
       endcase
			
       `ifdef  MSG
       $display ($time, " a_t=%d b_t=%d sum_gld=%d sum_t=%d\n", 
                          a_t, b_t, sum_gld, inst1.sum);
       $display ($time, " in_a_t=%d in_b_t=%d sum_reg_gld=%d sum_reg_t=%d\n", 
                          in_a_t, in_b_t, sum_reg_gld, sum_reg_t);
       `endif
       
       #(`PERIOD-0.2)
 			
       if (sum_reg_t!==sum_reg_gld)
            begin
              err_count=err_count+1;
	      $display ($time, " An error occurred !");
              $display ($time, " a_t=%d b_t=%d sum_gld=%d sum_t=%d\n", 
                                 a_t, b_t, sum_gld, inst1.sum);
              $display ($time, " in_a_t=%d in_b_t=%d sum_reg_gld=%d sum_reg_t=%d\n", 
                                 in_a_t, in_b_t, sum_reg_gld, sum_reg_t);			   
            end
			
     end
		
  $display(" ");
  $display("-------------------------------------------------------\n");
  $display("--------------------- S U M M A R Y -------------------\n");
  $display("SN=%3d, AIW=%3d, AFW=%3d, BIW=%3d, BFW=%3d, SFW=%3d,\n", 
            SN, AIW, AFW, BIW, BFW, SFW);
  if(err_count==0)
       $display("Congratulations! The results are all PASSED!!\n");
  else
       $display("FAIL!!!  There are %d errors! \n", err_count);
	  
  $display("-------------------------------------------------------\n");
		
  //#10 $stop; 
  #10 $finish;       

end

`ifdef  FSDB
initial
begin
  $sformat(fsdb_name,"fx_pt_add_rnd_reg_tb_SN_%1d_A_%02d_%02d_B_%02d_%02d_S_%02d_syn.fsdb", 
                     SN, AIW, AFW, BIW, BFW, SFW);   // something like sprintf in C
  $fsdbDumpfile(fsdb_name);  //your waveform file for nWave
  $fsdbDumpvars;
end
`endif

initial
begin
$sdf_annotate ("../../../syn/cfg2/run/fx_pt_add_rnd_reg_cfg2_syn.sdf", inst1);
end

fx_pt_add_rnd_reg_cfg2 #(.SN(SN),
                         .AIW(AIW),
                         .AFW(AFW),
                         .BIW(BIW),
                         .BFW(BFW),
		         .SFW(SFW))					 
                       inst1(.rst(rst),
                             .clk(clk),
                             .in_a(in_a_t), 
                             .in_b(in_b_t), 
                             .sum_reg(sum_reg_t));


endmodule
 
