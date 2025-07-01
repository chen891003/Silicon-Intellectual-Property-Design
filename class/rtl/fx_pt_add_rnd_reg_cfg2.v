module fx_pt_add_rnd_reg_cfg2(rst, 
                         clk, 
                         in_a, 
                         in_b, 
                         sum_reg);

parameter SN = 1;
parameter AIW = 9;
parameter AFW = 8;
parameter BIW = 10;
parameter BFW = 9;
parameter SIW = (AIW>BIW)? AIW+2:BIW+2;
parameter SFW = 7;

input  rst, clk;
input  [AIW+AFW-1:0] in_a; 
input  [BIW+BFW-1:0] in_b;
output reg [SIW+SFW-1:0] sum_reg; 

wire [SIW+SFW-1:0] sum;
reg  [AIW+AFW-1:0] a; 
reg  [BIW+BFW-1:0] b;
 

always@(posedge clk or negedge rst)begin
	if(!rst)begin
		a <= 0;
		b <= 0;
		sum_reg <= 0;
	end
	else begin
		a <= in_a;
		b <= in_b;
		sum_reg <= sum;
	end
end

fx_pt_add_rnd #(.SN(SN),.AIW(AIW),.AFW(AFW),.BIW(BIW),.BFW(BFW),.SIW(SIW),.SFW(SFW)) cfg2 (.a(a), .b(b), .sum(sum));

endmodule
