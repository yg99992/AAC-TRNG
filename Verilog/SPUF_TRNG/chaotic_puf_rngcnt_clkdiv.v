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


module chaotic_puf_rngcnt_clkdiv
#(
    parameter TW = 8
)
(
    input iclk,
    input rst_n,
    input iT,
    input [63:0] iC, 
    input [15:0] clk_div_cfg,
    output reg [TW-1 : 0] resp_reg,
    output reg resp_xor_reg,
    output reg stable_reg,
    output reg finish,
    
    output reg [2*TW-1 :0]stable_each_reg,
    output reg [TW*16-1:0] cnt_all_reg
    );
    reg  tigReg;
    reg  tig_pulse;
    reg  tig_pulse_buf;
    
    wire clk_trigger;
    wire [TW-1 : 0] resp;
    wire resp_xor;
    wire stable;
    
    wire [2*TW-1 :0]stable_each;
    wire [TW*16-1:0] cnt_all;

    // Latch the trigger signal 
    always@(posedge clk_trigger, negedge rst_n) begin 
         if(!rst_n)begin
             tigReg          <= 1'b0;
             tig_pulse_buf   <= 1'b0;
         end else begin 
             tigReg   <= iT;    // gen negedge
             tig_pulse_buf   <= tig_pulse;
         end
    end 

    always@(posedge clk_trigger, negedge rst_n) begin 
         if(!rst_n)begin
             tig_pulse   <= 1'b0;
         end else begin 
            if( (tigReg == 1'b1) & (tig_pulse == 1'b0))
                tig_pulse   <= 1'b1;
            else
                tig_pulse   <= 1'b0;
         end
    end     


    always@(posedge clk_trigger, negedge rst_n)begin
        if(!rst_n)
            finish          <= 1'b0;
        else begin
            if(tigReg == 1'b0)
                finish      <= 1'b0;
            else if( (tig_pulse==0) & (tig_pulse_buf==1))  // finished when the tig_pulse is falling edge
                finish      <= 1'b1;
            else
                finish      <= finish;
        end
    end
    
    always@(posedge clk_trigger, negedge rst_n)begin
        if(!rst_n)begin
            resp_reg    <= 'b0;
            resp_xor_reg<= 'b0;
            stable_reg  <= 'b0;
            
            stable_each_reg     <= 'b0;
            cnt_all_reg         <= 'b0;
        end else begin
            if (tigReg == 1'b0) begin
                resp_reg        <= 'b0;
                resp_xor_reg    <= 'b0;
                stable_reg      <= 'b0;
                
                stable_each_reg     <= 'b0;
                cnt_all_reg         <= 'b0;
            end else if(tig_pulse == 1'b1) begin  // sampling data
                resp_reg        <= resp;
                resp_xor_reg    <= resp_xor;
                stable_reg      <= stable;
                
                stable_each_reg     <= stable_each;
                cnt_all_reg         <= cnt_all;
            end else begin
                resp_reg        <= resp_reg;
                resp_xor_reg    <= resp_xor_reg;
                stable_reg      <= stable_reg;
                
                stable_each_reg     <= stable_each_reg;
                cnt_all_reg         <= cnt_all_reg;
            end
        end
    end

    
    (*KEEP_HIERARCHY = "TRUE"*)
    SIPUF64x8_cnt
    #(
        .TW( 8  ),
        .ST( 64 )
    ) puf_core
    (
            .tigReg     (tig_pulse     ),
            .iC         (iC            ),    
            .resp       (resp          ),   // output all response
            .resp_xor   (resp_xor      ),   // output 1-bit final response
            .stable     (stable        ),
            .stable_each(stable_each   ),
            .cnt_all    (cnt_all       )
        );
        
    clk_div clk_div (
         .clk_i(iclk), 
         .rst_n(rst_n   ),
         .div  (clk_div_cfg),
         .clk_o(clk_trigger)
        );    
endmodule
