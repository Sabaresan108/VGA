module SRAM_VGA(input clk, // On board clk = 50 MHZ
					 input SW,
					 output  [7:0] VGA_R,
					 output  [7:0] VGA_G,
					 output  [7:0] VGA_B,
					 output reg VGA_HS,
					 output reg VGA_VS,
					 output reg VGA_BLANK_N,
					 output VGA_SYNC_N,
					 output VGA_CLK,					 
					 output [19:0]SRAM_ADDR,
					 inout  [15:0] SRAM_DQ,
					 output SRAM_CE_N,
					 output SRAM_OE_N,
					 output SRAM_WE_N,
					 output SRAM_UB_N,
					 output SRAM_LB_N);
		
parameter BASE_ADDR = 20'h00000; //BASE address for read
		
wire rst = SW;
reg clk_25 = 1'b0; //VGA clk divider = 25MHZ
reg [9:0] h_count = 10'd0;
reg [9:0] v_count = 10'd0;
reg [19:0] sram_addr_reg;
reg 		 image_active_reg; 

always @(posedge clk)
begin
		clk_25 <= ~clk_25;
end

assign VGA_CLK = clk_25;
assign SRAM_ADDR = sram_addr_reg;
assign VGA_SYNC_N	 = 0;

assign SRAM_CE_N = 0; 		  // Chip enabled
assign SRAM_OE_N = 0; 		  // Output enabled
assign SRAM_WE_N = 1; 		  // Write disabled
assign SRAM_UB_N = 0; 		  // Upper byte enable 
assign SRAM_LB_N = 0; 		  // Lower byte enable
assign SRAM_DQ	  = 16'hzzzz; // Tri state buffer for reading 

parameter
//Horizontal Values
			H_SYNC 	  = 10'd96,
			H_BACK 	  = 10'd48,
			H_VISIBLE  = 10'd640,
			H_FRONT    = 10'd16, 
			H_TOTAL    = 10'd800,
// Vertical Values			
			V_SYNC	  = 10'd2,
			V_BACK 	  = 10'd33,
			V_VISIBLE  = 10'd480,
			V_FRONT	  = 10'd10,
			V_TOTAL	  = 10'd525;
			
wire image_active = (h_count >= (H_SYNC + H_BACK)) && (h_count < (H_SYNC + H_BACK + H_VISIBLE)) && 
						  (v_count >= (V_SYNC + V_BACK))	&& (v_count < (V_SYNC + V_BACK + V_VISIBLE))	;
			
always @(posedge clk_25)
begin
		if(~rst)
		begin
				h_count 	  	  <= 0;
				v_count 	  	  <= 0;
				sram_addr_reg <= BASE_ADDR;
				VGA_HS  	  	  <= 1;
				VGA_VS  	  	  <= 1;
				VGA_BLANK_N	  <= 0;				
		end
		
		else
		begin
				if(h_count == H_TOTAL - 1)
				begin
						h_count <= 0;
						
						if(v_count == V_TOTAL - 1)
						begin
								v_count <= 0;
						end
						
						else
						begin
								v_count <= v_count + 1;
						end
				end
				
				else
				begin
						h_count <= h_count + 1;
				end
				
				if(v_count == 10'd0 && h_count == 10'd0)
				begin
						sram_addr_reg <= BASE_ADDR;
				end
				
				else if (image_active_reg)
				begin
						sram_addr_reg <= sram_addr_reg + 1; // increment to next address
				end
				
				image_active_reg <= image_active; 
				VGA_BLANK_N		  <= image_active_reg;
				VGA_HS			  <= ~(h_count < H_SYNC);
				VGA_VS			  <= ~(v_count < V_SYNC);
		end
end

assign VGA_R = image_active_reg ? {SRAM_DQ[15:11], SRAM_DQ[15:13]} : 8'd0; // Repeat top 3 bits
assign VGA_G = image_active_reg ? {SRAM_DQ[10:5],  SRAM_DQ[10:9]}  : 8'd0; // Repeat top 2 bits
assign VGA_B = image_active_reg ? {SRAM_DQ[4:0],   SRAM_DQ[4:2]}   : 8'd0; // Repeat top 3 bits
						 
endmodule 
