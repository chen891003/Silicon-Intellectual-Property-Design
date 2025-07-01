`timescale 1ns/100ps
module fx_pt_add_rnd(a, b, sum);

parameter SN  = 2;
parameter AIW = 1;
parameter AFW = 4;
parameter BIW = 4;
parameter BFW = 6;
parameter SIW = (AIW>BIW)? AIW+2:BIW+2;
parameter SFW = 3;

parameter FZ  = (AFW>BFW)? AFW:BFW;  					//小數部分補零 內定參數
parameter FZM = (FZ>SFW)? FZ:SFW;

input  [AIW+AFW-1:0] a;
input  [BIW+BFW-1:0] b;
output [SIW+SFW-1:0] sum;

wire [SIW+SFW-1:0] a_ext,b_ext;
reg  [SIW+SFW-1:0]  sum_tmp;
generate
	case(SN)
		0:begin : unsgn_cond						         //unsigned
			/*unsgn_cond #(.SN(SN),.AIW(AIW),.AFW(AFW),.BIW(BIW),.BFW(BFW),.SIW(SIW),.SFW(SFW))
			ins1 (.a(a),.b(b),.sum(sum));*/
			wire [SIW+FZM-1:0] a_ext,b_ext;
			reg  [SIW+FZM-1:0]  sum_ext;
			reg  [SIW+SFW-1:0] sum_tmp;


			assign a_ext = {{(SIW-AIW){1'b0}}, a, {FZM-AFW{1'b0}}};
			assign b_ext = {{(SIW-BIW){1'b0}}, b, {FZM-BFW{1'b0}}};


			always@(a_ext or b_ext or sum_tmp) begin
				sum_ext = a_ext + b_ext;
				if(sum_ext[FZM-SFW-1]==1'b1)begin
					sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW] + 1'b1;  
				end
				else begin
					sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];
				end

			end
			assign sum = sum_tmp;	
		  end
		1:begin : signed_complement						     //signed_complement
			/*signed_complement #(.SN(SN),.AIW(AIW),.AFW(AFW),.BIW(BIW),.BFW(BFW),.SIW(SIW),.SFW(SFW))
			ins2 (.a(a),.b(b),.sum(sum));*/
			wire [SIW+FZM-1:0] a_ext,b_ext;
			reg  [SIW+FZM-1:0]  sum_ext;
			reg  [SIW+SFW-1:0] sum_tmp;

			reg round;

							//小數部分補零 內定參數
			assign a_ext = {{(SIW-AIW){a[AIW+AFW-1]}}, a, {FZM-AFW{1'b0}}};
			assign b_ext = {{(SIW-BIW){b[BIW+BFW-1]}}, b, {FZM-BFW{1'b0}}};


			always@(a_ext or b_ext or sum_tmp) begin
				sum_ext = a_ext + b_ext;
				if((FZM-SFW)>0)begin
					case(sum_ext[SIW+FZM-1])
						1'b1:begin
							if(sum_ext[FZM-SFW-1]==1'b1)begin
								if(sum_ext[FZM-SFW-1:0]=={1'b1,{(FZM-SFW-1){1'b0}}})begin
									sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];
								end
								else begin
									sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW] + 1'b1;  
								end
							end
							else begin
								sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];
							end			  
						end
						1'b0:begin
							if(sum_ext[FZM-SFW-1]==1'b1)begin
								sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW] + 1'b1;  
							end
							else begin
								sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];
							end
						end
						default: sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];
					endcase			
				end		
				else 
					sum_tmp = sum_ext[SIW+FZM-1-1:FZM-SFW-1];
			end
			assign sum = sum_tmp;	
					  end 
		2:begin : signed_magnitude						     //signed_magnitude
			/*signed_magnitude #(.SN(SN),.AIW(AIW),.AFW(AFW),.BIW(BIW),.BFW(BFW),.SIW(SIW),.SFW(SFW))
			ins3 (.a(a),.b(b),.sum(sum));*/	
			wire [SIW+FZM-1:0] a_ext,b_ext;
			reg  [SIW+FZM-2:0] a_ext_tmp,b_ext_tmp;
			reg  [SIW+FZM-1:0]  sum_ext;
			reg  [SIW+SFW-1:0] sum_tmp,sum_tmp_2;
			wire a_sgn,b_sgn;
			assign a_ext = { a[AIW+AFW-1],{(SIW-AIW){1'b0}}, a[AIW+AFW-2:0], {FZM-AFW{1'b0}}};
			assign b_ext = { b[BIW+BFW-1],{(SIW-BIW){1'b0}}, b[BIW+BFW-2:0], {FZM-BFW{1'b0}}};
			assign a_sgn = a[AIW+AFW-1];
			assign b_sgn = b[BIW+BFW-1];

			always@(*)begin
				a_ext_tmp = a_ext[SIW+FZM-2:0];
				b_ext_tmp = b_ext[SIW+FZM-2:0];
				if(a_sgn^b_sgn)begin
					if(a_ext_tmp>b_ext_tmp)
						sum_ext = {a_ext[SIW+FZM-1],a_ext_tmp-b_ext_tmp};
					else if (a_ext_tmp==b_ext_tmp)
						sum_ext = {{(SIW+FZM){1'b0}}};
					else
						sum_ext = {b_ext[SIW+FZM-1],b_ext_tmp-a_ext_tmp};
				end
				else begin
					sum_ext = {a_ext[SIW+FZM-1],a_ext_tmp+b_ext_tmp};
				end

					if(sum_ext[FZM-SFW-1]==1'b1)       //round
						sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW] + 1'b1; 
					else
						sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];

					if(sum_tmp == {1'b1,{(SIW+SFW-1){1'b0}}})  //special
						sum_tmp_2 = {(SIW+SFW){1'b0}};
					else
						sum_tmp_2 = sum_tmp;
			end

			assign sum = sum_tmp_2;

		  	end 

		default :begin : signed_magnitude						     //signed_magnitude
			signed_magnitude #(.SN(SN),.AIW(AIW),.AFW(AFW),.BIW(BIW),.BFW(BFW),.SIW(SIW),.SFW(SFW))
			ins3 (.a(a),.b(b),.sum(sum));
		end
		
	endcase
endgenerate

endmodule
//////////////////////////////////////////////////////////////////// 無號數表示法
module unsgn_cond (a, b, sum);

parameter SN  = 0;
parameter AIW = 2;
parameter AFW = 3;
parameter BIW = 3;
parameter BFW = 4;
parameter SIW = (AIW>BIW)? AIW+2:BIW+2;
parameter SFW = 2;

parameter FZ  = (AFW>BFW)? AFW:BFW;     					//小數部分補零 內定參數
parameter FZM = (FZ>SFW)? FZ:SFW;

input  [AIW+AFW-1:0] a;
input  [BIW+BFW-1:0] b;
output [SIW+SFW-1:0] sum;

wire [SIW+FZM-1:0] a_ext,b_ext;
reg  [SIW+FZM-1:0]  sum_ext;
reg  [SIW+SFW-1:0] sum_tmp;


assign a_ext = {{(SIW-AIW){1'b0}}, a, {FZM-AFW{1'b0}}};
assign b_ext = {{(SIW-BIW){1'b0}}, b, {FZM-BFW{1'b0}}};


always@(a_ext or b_ext or sum_tmp) begin
	sum_ext = a_ext + b_ext;
	if(sum_ext[FZM-SFW-1]==1'b1)begin
		sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW] + 1'b1;  
	end
	else begin
		sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];
	end

end
assign sum = sum_tmp;
endmodule
//////////////////////////////////////////////////////////////////////有號2補數
module signed_complement (a, b, sum);

parameter SN  = 1;
parameter AIW = 2;
parameter AFW = 5;
parameter BIW = 4;
parameter BFW = 6;
parameter SIW = (AIW>BIW)? AIW+2:BIW+2;
parameter SFW = 3;

parameter FZ  = (AFW>BFW)? AFW:BFW;     					
parameter FZM = (SFW>=FZ)? SFW+1:FZ;	

input  [AIW+AFW-1:0] a;
input  [BIW+BFW-1:0] b;
output [SIW+SFW-1:0] sum;

wire [SIW+FZM-1:0] a_ext,b_ext;
reg  [SIW+FZM-1:0]  sum_ext;
reg  [SIW+SFW-1:0] sum_tmp;

reg round;

				//小數部分補零 內定參數
assign a_ext = {{(SIW-AIW){a[AIW+AFW-1]}}, a, {FZM-AFW{1'b0}}};
assign b_ext = {{(SIW-BIW){b[BIW+BFW-1]}}, b, {FZM-BFW{1'b0}}};


always@(a_ext or b_ext or sum_tmp) begin
	sum_ext = a_ext + b_ext;
	if((FZM-SFW)>0)begin
		case(sum_ext[SIW+FZM-1])
			1'b1:begin
				if(sum_ext[FZM-SFW-1]==1'b1)begin
					if(sum_ext[FZM-SFW-1:0]=={1'b1,{(FZM-SFW-1){1'b0}}})begin
						sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];
					end
					else begin
						sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW] + 1'b1;  
					end
				end
				else begin
					sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];
				end			  
			end
			1'b0:begin
				if(sum_ext[FZM-SFW-1]==1'b1)begin
					sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW] + 1'b1;  
				end
				else begin
					sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];
				end
			end
			default: sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];
		endcase			
	end		
	else 
		sum_tmp = sum_ext[SIW+FZM-1-1:FZM-SFW-1];
end
assign sum = sum_tmp;

endmodule
//////////////////////////////////////////////////////////////////////有號大小表示法
module signed_magnitude (a, b, sum);

parameter SN  = 2;
parameter AIW = 4;
parameter AFW = 4;
parameter BIW = 3;
parameter BFW = 6;
parameter SIW = (AIW>BIW)? AIW+2:BIW+2;
parameter SFW = 3;

parameter FZ  = (AFW>BFW)? AFW:BFW; 
parameter FZM = (FZ>SFW)? FZ:SFW;  

input  [AIW+AFW-1:0] a;
input  [BIW+BFW-1:0] b;
output [SIW+SFW-1:0] sum;  					

wire [SIW+FZM-1:0] a_ext,b_ext;
reg  [SIW+FZM-2:0] a_ext_tmp,b_ext_tmp;
reg  [SIW+FZM-1:0]  sum_ext;
reg  [SIW+SFW-1:0] sum_tmp,sum_tmp_2;
wire a_sgn,b_sgn;
assign a_ext = { a[AIW+AFW-1],{(SIW-AIW){1'b0}}, a[AIW+AFW-2:0], {FZM-AFW{1'b0}}};
assign b_ext = { b[BIW+BFW-1],{(SIW-BIW){1'b0}}, b[BIW+BFW-2:0], {FZM-BFW{1'b0}}};
assign a_sgn = a[AIW+AFW-1];
assign b_sgn = b[BIW+BFW-1];

always@(*)begin
	a_ext_tmp = a_ext[SIW+FZM-2:0];
	b_ext_tmp = b_ext[SIW+FZM-2:0];
	if(a_sgn^b_sgn)begin
		if(a_ext_tmp>b_ext_tmp)
			sum_ext = {a_ext[SIW+FZM-1],a_ext_tmp-b_ext_tmp};
		else if (a_ext_tmp==b_ext_tmp)
			sum_ext = {{(SIW+FZM){1'b0}}};
		else
			sum_ext = {b_ext[SIW+FZM-1],b_ext_tmp-a_ext_tmp};
	end
	else begin
		sum_ext = {a_ext[SIW+FZM-1],a_ext_tmp+b_ext_tmp};
	end

		if(sum_ext[FZM-SFW-1]==1'b1)       //round
			sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW] + 1'b1; 
		else
			sum_tmp = sum_ext[SIW+FZM-1:FZM-SFW];

		if(sum_tmp == {1'b1,{(SIW+SFW-1){1'b0}}})  //special
			sum_tmp_2 = {(SIW+SFW){1'b0}};
		else
			sum_tmp_2 = sum_tmp;
end

assign sum = sum_tmp_2;

endmodule








