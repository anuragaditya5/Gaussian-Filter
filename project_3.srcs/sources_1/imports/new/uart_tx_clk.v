/*
This module is for generating clock pulse for UART transmitter which is also known as BAUD Rate
Alternatively baud rate is no of clock pulse per second
In each clock pulse, one bit of data is transmit to the receiver

****************************** Baud rate calculations ******************************
This module generates Baud rate = 115200 How?
My FPGA system clock is = 100MHz, Period = 10ns
So, (100 Mega clock pulse /115200) = 868 (This much no. of clock pulses are required for each bit)
*/
module uart_tx_clk(
input clk,
output reg clk_out

    );
    
    reg [20:0]count;
    always @ (posedge clk)begin
    if(count == 868)            //baud rate is 115200 
        count <= 0;
    else
        count <= count + 1;
        
    clk_out <= (count < 434)?1:0;   //Duty cycle is 50%
    end
endmodule