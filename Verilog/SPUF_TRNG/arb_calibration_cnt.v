`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2021 21:20:29
// Design Name: 
// Module Name: arb_calibration
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


module arb_calibration_cnt(
    input rst,
    input s,
    input r,
    output q,
    output [1:0] stable,
    output [15:0] cnt
    );
    
    wire qbar;
    wire q_reg;
    wire qbar_reg;
    wire [7:0] q_cnt;
    wire [7:0] qbar_cnt;
    
    nandLatch ARBITER_0(
        .s(s  ),
        .r(r  ),
        .q(q),
        .qbar(qbar)
     );
     
     cali_latch_cnt Dflip1(
        .clk (q    ),
        .rst (rst  ),
        .ena (rst  ),
        .dout(q_reg),
        .cnt (q_cnt)
     );
     
      cali_latch_cnt Dflip2(
         .clk (qbar     ),
         .rst (rst      ),
         .ena (rst      ),
         .dout(qbar_reg ),
         .cnt (qbar_cnt )
      );
      
      assign stable = {q_reg, qbar_reg};
      assign cnt    = {q_cnt, qbar_cnt};
      
endmodule
