`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2022 19:41:03
// Design Name: 
// Module Name: freq_div
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


module freq_div(
input clk,output reg  slow_clk
   );

reg [2:0] counter;
initial begin
counter <=0;

end
    
always @(posedge clk)begin
    if (counter[2]==1) begin
    slow_clk<= ~slow_clk;
    counter <= 0;
    end
    
    else begin
    
    counter <= counter +1;
    end



end
  
    
    
endmodule
