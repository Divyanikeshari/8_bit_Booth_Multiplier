`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2024 23:34:36
// Design Name: 
// Module Name: booth_mul_tb
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


module booth_mul_tb;
reg clk, start;
reg [7:0] data_in;
wire [15:0] product;

booth_mul_DP dp(clk, data_in, start, product);


// Clock 
initial 
begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
start = 0;
data_in = 0;
end

initial
begin
    @(posedge clk)
    start=1;
    @(posedge clk)
    data_in = 8'b10001010; // multiplicand (10)
    @(posedge clk)
    data_in= 8'b00000101; // multiplier (5)
 
    #200 start = 0;
    #200$finish;

end

endmodule
