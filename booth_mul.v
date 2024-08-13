`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2024 20:03:55
// Design Name: 
// Module Name: booth_mul
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// shift register module
module shift_Reg(data_in,clr,clk,ld,msb_in,data_out,sft);//msb_in is the MSB which will be insert and same as sign bit
input [7:0] data_in; //8 bit input data
input clr,clk,ld,sft,msb_in;
output reg [7:0] data_out;
always @(posedge clk)
begin
if (clr)
    data_out<=0;
else if(ld)
    data_out<=data_in;
else if(sft)
    data_out={msb_in,data_out[7:1]};
end
endmodule

//D flip flop module
module ff_reg (data_in,data_out,clk,clr);
input data_in,clk,clr;
output reg data_out;
always @(posedge clk)
begin
if (clr)
    data_out<=0;
else 
    data_out<= data_in;
end
endmodule

//Parallel input parallel output module
module PIPO(data_in,data_out,load,clk);
input [7:0]data_in;
input load,clk;
output reg [7:0]data_out;
always @(posedge clk)
begin
if (load)
    data_out<=data_in;
end 
endmodule

//Simple ALU for Addition and subtraction 
module addsub(data_out,A,B,select);
input [7:0] A,B;
input select;
output reg[7:0] data_out;
always @(*)
begin
if (select==1)
    data_out<=A-B;
else if(select==0)
    data_out<=A+B;
end
endmodule

//Counter module
module counter(c_out,decr,load,clk);
input decr,load,clk;
output reg [2:0]c_out;
always @(posedge clk)
begin
if (load)
    c_out <=3'b111;
else if(decr)
    c_out <= c_out-1;
end
endmodule

//Booth multiplier controller module
module booth_mul_CP(clk, ld_A, ld_Q, clr_A, clr_Q, sft_A, sft_Q, clr_ff, ld_M, add_sub, ff_out, eqz, decr, ld_count,start,done,Q0);
input start,clk,ff_out,Q0, eqz;
output reg  ld_A, ld_Q, clr_A, clr_Q, sft_A, sft_Q, clr_ff, ld_M, add_sub, decr, ld_count,done;
reg [2:0]state;
parameter s1=3'b000, s2=3'b001,s3=3'b010, s4=3'b011,s5=3'b100, s6=3'b101,s7=3'b110;
always @(posedge clk)
begin
case(state)
s1: if (start) 
    state <=s2;
    else 
    state <=s1;
s2: state<=s3;
s3: begin
    #5 
    if({Q0,ff_out}==2'b01)
    state<=s5;
    else if({Q0,ff_out}==2'b10)
    state <= s4;
    else 
    state <= s6;
    end
s4: state<=s6;
s5: state<=s6;
s6: begin
    #5
     if(({Q0,ff_out}==2'b01) && !eqz)
        state <=  s5;
	 else if(({Q0,ff_out}==2'b10) && !eqz)
        state <=  s4;
	 else if(eqz)
		state <= s7; 
    end
s7: state<=s7;
default: state <=s1;
endcase
end
always @(state)
begin
case (state)
s1: begin
    clr_A=1;
    clr_Q=1;
    ld_A=0;
    ld_Q=0;
    sft_A=0;
    sft_Q=0;
    ld_M=0;
    clr_ff=1;
    ld_count=0;
    decr =0;
    done=0;
    end 
s2: begin 
    clr_A=1;
    clr_ff=1;
    ld_count=1;
    ld_M=1;
    clr_Q=0;
    ld_A=0;
    ld_Q=0;
    sft_A=0;
    sft_Q=0;
    decr=0;
    done=0;
    end 
s3: begin 
    ld_Q=1;
    clr_A=0;
    clr_ff=0;
    ld_count=0;
    ld_M=0;
    clr_Q=0;
    ld_A=0;
    sft_A=0;
    sft_Q=0;
    decr=0;
    done=0;
    
    end 
s4: begin
    add_sub=1;
    ld_A=1;
    ld_Q=0;
    sft_Q=0;
    sft_A=0;
    clr_A=0;
    clr_ff=0;
    ld_count=0;
    ld_M=0;
    clr_Q=0;
    decr=0;
    done=0;
    end 
s5: begin
    add_sub=0;
    ld_A=1;
    ld_Q=0;
    sft_Q=0;
    sft_A=0;
    clr_A=0;
    clr_ff=0;
    ld_count=0;
    ld_M=0;
    clr_Q=0;
    decr=0;
    done=0;
    end 
s6: begin
    sft_Q=1;
    sft_A=1;
    decr=1;
    ld_A=0;
    ld_Q=0;
    clr_A=0;
    clr_Q=0;
    add_sub=0;
    clr_ff=0;
    ld_count=0;
    ld_M=0;
    done=0;
    
    end
s7: begin
    done=1;
    clr_A=0;
    clr_Q=0;
    ld_A=0;
    ld_Q=0;
    sft_A=0;
    sft_Q=0;
    ld_M=0;
    clr_ff=0;
    ld_count=0;
    decr =0;
    end

endcase  
end
endmodule

// Booth multiplier dataflow module
module booth_mul_DP(clk, data_in, start, product);
input [7:0] data_in;
input clk,start;
output [15:0] product;
wire sft_A, sft_Q, clr_A, clr_Q, clr_ff, add_sub, ld_A, ld_Q, ld_M, decr, ld_count, ff_out, eqz, done;
wire [7:0] A,M,Z,Q;//Q is output of shift register Q
wire signed [2:0] count;
assign eqz = ~|(count);
assign product = {A,Q};

shift_Reg Areg(Z,clr_A,clk,ld_A,A[7],A,sft_A);
shift_Reg Qreg(data_in,clr_Q,clk,ld_Q,A[0],Q,sft_Q);
ff_reg Qff(Q[0],ff_out,clk,clr_ff);
PIPO multiplicand(data_in,M,ld_M,clk);
addsub alu(Z,A,M,add_sub);
counter COUNT(count,decr,ld_count,clk);
booth_mul_CP controller(clk,ld_A, ld_Q, clr_A, clr_Q, sft_A, sft_Q, clr_ff, ld_M, add_sub, ff_out, eqz, decr, ld_count,start,done,Q[0]);


endmodule


