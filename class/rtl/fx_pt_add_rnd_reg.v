module fx_pt_add_rnd_reg(rst, 
                         clk, 
                         in_a, 
                         in_b, 
                         sum_reg);

parameter SN = 0;
parameter AIW = 2;
parameter AFW = 5;
parameter BIW = 4;
parameter BFW = 6;
parameter SIW = (AIW>BIW)? AIW+2:BIW+2;
parameter SFW = 3;

input  rst, clk;
input  [AIW+AFW-1:0] in_a; 
input  [BIW+BFW-1:0] in_b;
output [SIW+SFW-1:0] sum_reg; 

wire [SIW+SFW-1:0] sum;
reg  [AIW+AFW-1:0] a; 
reg  [BIW+BFW-1:0] b;
reg  [SIW+SFW-1:0] sum_temp; 

always@(posedge clk or negedge rst)begin
	if(!rst)begin
		a <= 0;
		b <= 0;
		sum_temp <= 0;
	end
	else begin
		a <= in_a;
		b <= in_b;
		sum_temp <= sum;
	end
end
assign sum_reg = sum_temp;

fx_pt_add_rnd #(.SN(SN),.AIW(AIW),.AFW(AFW),.BIW(BIW),.BFW(BFW),.SIW(SIW),.SFW(SFW))fx_pt_add_rnd_HW1 (.a(a), .b(b), .sum(sum));

endmodule