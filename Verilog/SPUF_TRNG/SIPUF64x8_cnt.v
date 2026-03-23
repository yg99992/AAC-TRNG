`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.12.2020 02:13:28
// Design Name: 
// Module Name: chaotic_puf
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


module SIPUF64x8_cnt
#(
    parameter TW = 8,  // number of path
    parameter ST = 64  // number of stages
)
(
    input tigReg,
    input  [ST-1 : 0] iC,    
    output [TW-1 : 0] resp,   // output all response
    output resp_xor,   // output 1-bit final response
    output stable,
    output [2*TW-1:0]stable_each,
    output [TW*16-1:0] cnt_all
    );
    (* DONT_TOUCH= "TRUE" *) wire [TW-1:0] L0;
    (* DONT_TOUCH= "TRUE" *) wire [TW-1:0] L1;
    
    assign resp_xor = ^resp[TW-1:0];
    assign stable   = |stable_each;
    
    
    
//////////////////////////////////////////////////
/////  Delay line 
//////////////////////////////////////////////////
    (*KEEP_HIERARCHY = "TRUE"*)
    lines8_stages64_diff delay_0(
        .itriger    (tigReg),
        .iC         (iC),
        .oTP        (L0)
        );
            
    (*KEEP_HIERARCHY = "TRUE"*)
    lines8_stages64_diff delay_1(
        .itriger    (tigReg),
        .iC         (iC),
        .oTP        (L1)
        );
//////////////////////////////////////////////////


//////////////////////////////////////////////////
/////  Arbiter generate block
////////////////////////////////////////////////// 

genvar i;

generate
for(i=0; i<TW; i=i+1) begin: arb
    (*KEEP_HIERARCHY = "TRUE"*)
    arb_calibration_cnt ARBITER(
        .rst    (tigReg         ),
        .s      (L0[i]          ),
        .r      (L1[i]          ),
        .q      (resp[i]        ),
        .stable (stable_each[2*i+1 : 2*i]),
        .cnt    (cnt_all[16*i+15 : 16*i])
     );
end
endgenerate


endmodule
