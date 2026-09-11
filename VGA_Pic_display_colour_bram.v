module VGA_Pic_display(input clk,rst,
                       output reg vga_hs,
                       output reg vga_vs,
                       output reg [4:0] vga_r,
                       output reg [5:0] vga_g,
                       output reg [4:0] vga_b);

reg [2:0] clk_div;
reg [9:0] h_count;
reg [9:0] v_count;                                      
wire [15:0] ram_data;   

reg [1:0]  pixel_sel_d;        
reg active_d;
 

wire [16:0] rom_addr = ((v_count << 7)+(v_count << 5))+(h_count >> 2);

wire active_display = (h_count < 10'd640)&&(v_count < 10'd480); //Active display checker

wire [3:0] pixel_color = (ram_data >> ((2'd3 - pixel_sel_d) * 4)) & 4'hF;

blk_mem_gen_0 u_img_rom (.clka (clk),
                         .ena(clk_div == 3'd4),
                         .wea (1'b0),
                         .addra (rom_addr),
                         .dina  (16'd0),
                         .douta (ram_data));       

always @(posedge clk)
begin
     if(~rst)
     begin
           h_count     <= 0;
           v_count     <= 0;
           clk_div     <= 0;
           active_d    <= 0;
           pixel_sel_d <= 0;
           vga_hs      <= 1;
           vga_vs      <= 1;
           vga_r       <= 0;
           vga_g       <= 0;
           vga_b       <= 0;
     end
     
     else
     begin
          if (clk_div == 3'd4) // Clk division (125MHZ)
          begin
                clk_div <= 0;
                
                if (h_count == 10'd799)  // Horizontal total pixels = 800
                begin
                     h_count <= 0;
                     
                     if (v_count == 10'd524) // Vertical total lines = 525
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
                
                active_d   <= active_display;
                pixel_sel_d <= h_count[1:0];
                
                if (h_count >= 10'd656 && h_count < 10'd752)  // Horizontal syncronization [Hsync start(656) + Hsync time(96) = 752 pixels]
                begin
                     vga_hs<= 0; 
                end
                
                else
                begin
                     vga_hs <= 1;
                end
                
                if(v_count >= 10'd490 && v_count < 10'd492) // Vertical syncronization [Vsync start(490) + Vsync time(2) = 492 lines]
                begin
                     vga_vs <= 0;
                end
                
                else
                begin
                     vga_vs <= 1;
                end
                
                if (active_d) 
                begin
                     case (pixel_color)
                          4'd0: 
                          begin 
                               vga_r <= 5'd22; 
                               vga_g <= 6'd53; 
                               vga_b <= 5'd29; 
                          end
                          
                          4'd1: 
                          begin 
                               vga_r <= 5'd2; 
                               vga_g <= 6'd8; 
                               vga_b <= 5'd3; 
                          end
                          
                          4'd2: 
                          begin 
                               vga_r <= 5'd18; 
                               vga_g <= 6'd14; 
                               vga_b <= 5'd5; 
                          end
                          
                          4'd3: 
                          begin 
                               vga_r <= 5'd9; 
                               vga_g <= 6'd30; 
                               vga_b <= 5'd21; 
                          end
                          
                          4'd4: 
                          begin 
                               vga_r <= 5'd24; 
                               vga_g <= 6'd52; 
                               vga_b <= 5'd13; 
                          end
                          
                          4'd5: 
                          begin 
                               vga_r <= 5'd9; 
                               vga_g <= 6'd27; 
                               vga_b <= 5'd5; 
                          end
                          
                          4'd6: 
                          begin 
                               vga_r <= 5'd15; 
                               vga_g <= 6'd43; 
                               vga_b <= 5'd27; 
                          end
                          
                          4'd7: 
                          begin 
                               vga_r <= 5'd7; 
                               vga_g <= 6'd21; 
                               vga_b <= 5'd13; 
                          end
                          
                          4'd8: 
                          begin 
                               vga_r <= 5'd15; 
                               vga_g <= 6'd35; 
                               vga_b <= 5'd19; 
                          end
                          
                          4'd9: 
                          begin 
                               vga_r <= 5'd3; 
                               vga_g <= 6'd12; 
                               vga_b <= 5'd9; 
                          end
                          
                          4'd10: 
                          begin 
                               vga_r <= 5'd19; 
                               vga_g <= 6'd44; 
                               vga_b <= 5'd10; 
                          end
                          
                          4'd11: 
                          begin 
                               vga_r <= 5'd15; 
                               vga_g <= 6'd37; 
                               vga_b <= 5'd6; 
                          end
                          
                          4'd12: 
                          begin 
                               vga_r <= 5'd27; 
                               vga_g <= 6'd55; 
                               vga_b <= 5'd19; 
                          end
                          
                          4'd13: 
                          begin 
                               vga_r <= 5'd12; 
                               vga_g <= 6'd29; 
                               vga_b <= 5'd16; 
                          end
                          
                          4'd14: 
                          begin 
                               vga_r <= 5'd5; 
                               vga_g <= 6'd19; 
                               vga_b <= 5'd2; 
                          end
                          
                          4'd15: 
                          begin 
                               vga_r <= 5'd13; 
                               vga_g <= 6'd32; 
                               vga_b <= 5'd10; 
                          end
                     endcase     
                end
                
                else // blanking [Back poarch + Sync pulse + front poarch]
                begin 
                     vga_r <= 5'd00000;
                     vga_g <= 6'd000000;
                     vga_b <= 5'd00000;
                end
          end
          
          else
          begin
               clk_div <= clk_div + 1;
          end
     end

end
                       
endmodule
