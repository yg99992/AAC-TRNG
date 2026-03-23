
// D Flip-Flop


module cali_latch_cnt(clk,rst,ena,dout, cnt);
	
	input clk;
	input rst;
	input ena;
	output dout;
	output reg [7:0] cnt;
    
    FDCE #(
    .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
    ) FDCE_inst (
    .Q(dout), // 1-bit Data output
    .C(clk), // 1-bit Clock input
    .CE(ena), // 1-bit Clock enable input, 1 -> enable
    .CLR(!ena), // 1-bit Asynchronous clear input, 1 -> clear
    .D(1'b1) // 1-bit Data input
    );
    
	always @(posedge clk, negedge rst) begin
	   if(!rst)begin
	       cnt <= 1'b0;
	   end else begin
		   cnt <= cnt+1'b1;
	   end	
	end
	
endmodule

