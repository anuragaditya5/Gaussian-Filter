`timescale 1ns / 1ps
/*

===========================================
Verilog code for 300x300 gaussian filter

*/
module top(
    input clk,
    input enable,
    input control,
    output tx_out,
    output reg prosessing_done,
    output reg tx_done

    );
    
    
    
wire slow_clk;
freq_div fv_1(clk,slow_clk);


wire [7:0]x1,x2;
wire [16:0]addra;
reg [16:0]address_IM;       //Address control
//reg [16:0] address_bram_1;
reg [7:0]din;

assign addra = control?address_IM:address;

reg [7:0]state_reg;
reg wea;

reg [16:0] ptr1,ptr2;


 reg [15:0] line_buffer_1[0:2];
 reg [15:0] line_buffer_2[0:2];
 reg [15:0] line_buffer_3[0:2];
 
 reg [15:0] gaussian_line_1[0:2];
 reg [15:0] gaussian_line_2[0:2];
 reg [15:0] gaussian_line_3[0:2];
 
// FOR FPGA ITS Synthesizable
// Initialize the mmemory
initial begin
gaussian_line_1[0] <= 1;
gaussian_line_1[1] <= 2;
gaussian_line_1[2] <= 1;

gaussian_line_2[0] <= 2;
gaussian_line_2[1] <= 4;
gaussian_line_2[2] <= 2;

gaussian_line_3[0] <= 1;
gaussian_line_3[1] <= 2;
gaussian_line_3[2] <= 1;


end


blk_mem_gen_1 bram_1(
  .clka(clk),    // input wire clka
  .addra(ptr1),  // input wire [16 : 0] addra
  .douta(x1),  // output wire [7 : 0] douta
  .clkb(clk),    // input wire clkb
  .addrb(ptr2),  // input wire [16 : 0] addrb
  .doutb(x2)  // output wire [7 : 0] doutb
);

reg [15:0] a0,a1,a2,a3,a4,a5,a6,a7,a8; //16 bit 
reg [15:0] d1,d2,d3,d4,d5;

//----------------------------------- Gaussian Filter -----------------------------------------
always @(negedge slow_clk) begin
    if(~control)begin
        address_IM <= 0;
        ptr1<=0;
        ptr2<=0;
        
        din <= 0;
        wea <= 0;
        prosessing_done <= 0;
        state_reg <= 0;
    end else begin
        case (state_reg)
            8'd0: begin
            wea <= 0;
            din <= tx_data;
            state_reg <= 1;
             
//        if(address_IM % 300==0 || address_IM < 299 || ((address_IM+1) % 300)==0 || address_IM > 89700)begin
//            {ptr1,ptr2,ptr3,ptr4,ptr6,ptr7,ptr8,ptr9} <=0;
            
//            end 
//            else begin     
//             ptr4 <= address_IM-1;
//            ptr6 <= address_IM+1;
//            ptr2<= address_IM-300;
//            ptr8 <= address_IM+300;
            
//            ptr3 <= address_IM-300+1;
//            ptr9 <= address_IM+300+1;
            
//            ptr1<= address_IM-300-1;
//            ptr7 <= address_IM+300-1;
//            end
            
            end
            8'd1: begin
                //datalogic
                if(address_IM % 300==0 | address_IM < 299 | ((address_IM+1) % 300)==0 | address_IM > 89700)begin
                
                din <= 0;
                state_reg <= 15; // Go to writing stage
                
                end 
                else begin 
                 
                    
               state_reg <= 2;
                end 
               
            end
            8'd2: begin
                ptr1<= (address_IM-300-1);            
                ptr2<=(address_IM-300);
                 state_reg <= 3;
                
            end
            8'd3: begin
                line_buffer_1[0]<= x1;
                line_buffer_1[1]<=x2;
                 state_reg <= 4;
            
            end
            
            8'd4: begin
                ptr1<= (address_IM-300+1);            
                ptr2<=(address_IM-1);
                 state_reg <= 5;
            end
            8'd5: begin
                  line_buffer_1[2]<= x1;
                  line_buffer_2[0]<=x2;
                     state_reg <= 6;
            end
            8'd6:begin
                ptr1<= (address_IM);            
                ptr2<=(address_IM+1);
                 state_reg <= 7;
            
            end
             8'd7: begin
                  line_buffer_2[1]<= x1;
                  line_buffer_2[2]<=x2;
                   state_reg <= 8;
            
            end
              8'd8:begin
                ptr1<= (address_IM+300-1);            
                ptr2<=(address_IM+300);
                 state_reg <= 9;
            
            end
             8'd9: begin
                  line_buffer_3[0]<= x1;
                  line_buffer_3[1]<=x2;
                   state_reg <= 10;
            
            end
             8'd10:begin
                ptr1<= (address_IM+300+1);            
                state_reg <= 11;
            
            
            end
             8'd11: begin
                  line_buffer_3[2]<= x1;
                   state_reg <= 12;
            
            end
            8'd12 :begin
                //Multiply
               a0<= line_buffer_1[0] * gaussian_line_1[0];
               a1<= line_buffer_1[1] * gaussian_line_1[1];
               a2<= line_buffer_1[2] * gaussian_line_1[2];
               
               
                
             state_reg <= 21;
            end
            
            8'd21: begin 
                   a3<= line_buffer_2[0] * gaussian_line_2[0];
                   a4<= line_buffer_2[1] * gaussian_line_2[1];
                   a5<= line_buffer_2[2] * gaussian_line_2[2];
            
            
            state_reg<=22;
            end
             8'd22: begin 
             
            
               
               
               a6<= line_buffer_3[0] * gaussian_line_3[0];
               a7<= line_buffer_3[1] * gaussian_line_3[1];
               a8<= line_buffer_3[2] * gaussian_line_3[2];
            
            
            state_reg<=23;
            end
            
            8'd23: begin
            d1<= (a0 + a1 + a2) ;
            d2<= (a3 + a4 + a5) ;
            d3<= ( a6 + a7 + a8 ) ;
            state_reg<= 24;
            
            end
             8'd24: begin
            
            state_reg<= 13;
            d4 <= d1+d2+d3;
            end
            
            
            
            
            8'd13: begin
                d5<= d4/16;
            
             state_reg <= 14;
            end
            
             8'd14: begin
            // RIGHT SHIFT BY 4 I.E, DIVIDED BY SIZTEEN
            din<= d5[7:0];
             state_reg <= 15;
            end
            8'd15: begin  // write data in bram stage
            wea <= 1;
           state_reg <= 30;
            end
            
            8'd30: begin
            wea <= 0;
             state_reg <= 16;
            end
            
             8'd16: begin
            address_IM <= address_IM + 1;
           
             state_reg <= 17;
            end
             8'd17: begin
                       if(address_IM == 90000)
                                state_reg <= 18; // move to done stage
                            else
                                state_reg <= 0;
             
            end
            
            8'd18: begin // DOne state
                state_reg <= 18;
                prosessing_done <= 1;
            end
            default :
            state_reg <= 18;
            
    endcase
end
end


//------------------------------------- Transfering BRAM data from FPGA to PC through UART -------------------------
reg [16:0]address;  //Address controlled by UART controller

blk_mem_gen_0 bram(.clka(clk),.addra(addra),.dina(din),.douta(tx_data),.wea(wea)); //BRAM


//-------------------------------------- UART Controller -------------------------------------
reg [2:0]state;
reg load_send;
always @ (posedge txclk)begin
if(enable) begin
    state <= 0;
    load_send <= 1;
    tx_done <= 0;
    address <= 0;
    end else begin
            case(state)
            3'd0:
                begin
                    load_send <= 1;
                    state <= 1;
                    tx_done <= 0;
                end
            3'd1:
                begin
                    tx_done <= 0;
                    load_send <= 0;
                        if(tx_empty)
                            state <= 2;
                        else
                            state <= 1;
                end
            3'd2:
                  begin
                    address <= address +1;
                    load_send <= 1;
                    state <= 3;
                    tx_done <= 0;
                  end
            3'd3: 
                begin
                    if(address == 90000)     //No of bytes
                        state <= 4;
                    else
                        state <= 0;
                end
            3'd4:
                begin
                    tx_done <= 1;
                    load_send <= 1;
                    state <= 4;
                end
            default:
                state <= 4;
            endcase
        end
end






//---------------------------- UART for 1 byte data transfer ----------------------------------------
wire tx_empty,txclk;
wire [7:0]tx_data;
assign ld_tx_data = load_send;
assign tx_enable = ~load_send;
uart_tx_clk clk0(clk,txclk);
uart_tx TX(enable,txclk,ld_tx_data,tx_data,tx_enable,tx_out,tx_empty);
//------------------------------------------------------------------------------------------
endmodule
