module VGA_16_12_matrix (input clk, rst,
                         output reg vga_hs,
                         output reg vga_vs,
                         output reg [4:0]vga_r,
                         output reg [5:0]vga_g,
                         output reg [4:0]vga_b );
               
reg [2:0] clk_div;               
reg [9:0] h_count;
reg [9:0] v_count;

reg [3:0] col_idx; // Column Index (640/40 = 16)
always @(*)
begin
     if (h_count < 10'd40)
     begin
           col_idx = 4'd0;
     end
     
     else if (h_count < 10'd80)
     begin
          col_idx = 4'd1;
     end
     
     else if(h_count < 10'd120)
     begin
          col_idx = 4'd2;
     end
     
     else if(h_count < 10'd160)
     begin
          col_idx = 4'd3;
     end
     
     else if(h_count < 10'd200)
     begin
          col_idx = 4'd4;
     end
     
     else if(h_count < 10'd240)
     begin
          col_idx = 4'd5;
     end
     
     else if(h_count < 10'd280)
     begin
          col_idx = 4'd6;
     end
     
     else if(h_count < 10'd320)
     begin
          col_idx = 4'd7;
     end
     
     else if(h_count < 10'd360)
     begin
          col_idx = 4'd8;
     end
     
     else if(h_count < 10'd400)
     begin
          col_idx = 4'd9;
     end
     
     else if(h_count < 10'd440)
     begin
          col_idx = 4'd10; 
     end
     
      else if(h_count < 10'd480)
     begin
          col_idx = 4'd11;
     end
     
     else if(h_count < 10'd520)
     begin
          col_idx = 4'd12;
     end
     
     else if(h_count < 10'd560)
     begin
          col_idx = 4'd13;
     end
     
     else if(h_count < 10'd600)
     begin
          col_idx = 4'd14;
     end
     
     else
     begin
          col_idx = 4'd15; 
     end
end

reg [3:0] row_idx; //Row Index (480/40 = 12)
always @(*)
begin
     if (v_count < 10'd40)
     begin
           row_idx = 4'd0;
     end
     
     else if (v_count < 10'd80)
     begin
          row_idx = 4'd1;
     end
     
     else if(v_count < 10'd120)
     begin
          row_idx = 4'd2;
     end
     
     else if(v_count < 10'd160)
     begin
          row_idx = 4'd3;
     end
     
     else if(v_count < 10'd200)
     begin
          row_idx = 4'd4;
     end
     
     else if(v_count < 10'd240)
     begin
          row_idx = 4'd5;
     end
     
     else if(v_count < 10'd280)
     begin
          row_idx = 4'd6;
     end
     
     else if(v_count < 10'd320)
     begin
          row_idx = 4'd7;
     end
     
     else if(v_count < 10'd360)
     begin
          row_idx = 4'd8;
     end
     
     else if(v_count < 10'd400)
     begin
          row_idx = 4'd9;
     end
     
     else if(v_count < 10'd440)
     begin
          row_idx = 4'd10; 
     end
     
      else
     begin
          row_idx = 4'd11;
     end
end

wire [3:0] colour_idx = row_idx + col_idx; // Combining both row and column to bring 16x12 colour palette

always @(posedge clk)
begin
     if(~rst)
     begin
          clk_div <= 0;
          h_count <= 0;
          v_count <= 0;
           vga_hs <= 1;
           vga_vs <= 1;
           vga_r  <= 5'd00000; 
           vga_g  <= 6'd000000;
           vga_b  <= 5'd00000;
     end
     
     else
     begin
          if (clk_div == 3'd4) // Clk division (125MHZ)
          begin
                clk_div <= 0;
                
                if (h_count == 10'd799) // Horizontal total pixels = 800
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
                       
                if (h_count >= 10'd656 && h_count < 10'd752 ) // Horizontal syncronization [Hsync start(656) + Hsync time(96) = 752 pixels]
                begin
                     vga_hs <= 0;
                end
                       
                else
                begin
                     vga_hs <= 1;
                end
                       
                if (v_count >= 10'd490 && v_count < 10'd492) // Vertical syncronization [Vsync start(490) + Vsync time(2) = 492 lines]
                begin
                     vga_vs <= 0; 
                end   
                
                else
                begin
                     vga_vs <= 1;
                end
                       
                if (h_count < 10'd640 && v_count < 10'd480) // Resolution
                begin
                     case(colour_idx) //Values containing colour details
                          4'd0:  //Black
                          begin 
                               vga_r <= 5'b00000; 
                               vga_g <= 6'b000000; 
                               vga_b <= 5'b00000; 
                          end
                          
                          4'd1:  //White
                          begin 
                               vga_r <= 5'b11111; 
                               vga_g <= 6'b111111; 
                               vga_b <= 5'b11111; 
                          end
                          
                          4'd2:  //Yellow
                          begin 
                               vga_r <= 5'b11111; 
                               vga_g <= 6'b111111; 
                               vga_b <= 5'b00000; 
                          end
                          
                          4'd3:  //Cyan
                          begin 
                               vga_r <= 5'b00000; 
                               vga_g <= 6'b111111; 
                               vga_b <= 5'b11111; 
                          end
                          
                          4'd4:  //Green
                          begin 
                               vga_r <= 5'b00000; 
                               vga_g <= 6'b111111; 
                               vga_b <= 5'b00000; 
                          end
                          
                          4'd5:  //Magenta
                          begin 
                               vga_r <= 5'b11111; 
                               vga_g <= 6'b000000; 
                               vga_b <= 5'b11111; 
                          end
                          
                          4'd6:  //Red
                          begin 
                               vga_r <= 5'b11111; 
                               vga_g <= 6'b000000; 
                               vga_b <= 5'b00000; 
                          end
                          
                          4'd7:  //Blue
                          begin 
                               vga_r <= 5'b00000; 
                               vga_g <= 6'b000000; 
                               vga_b <= 5'b11111; 
                          end
                          
                          4'd8:  //Orange
                          begin 
                               vga_r <= 5'b11111; 
                               vga_g <= 6'b100000; 
                               vga_b <= 5'b00000; 
                          end
                          
                          4'd9:  // Light green
                          begin 
                               vga_r <= 5'b10000; 
                               vga_g <= 6'b111111; 
                               vga_b <= 5'b00000; 
                          end
                          
                          4'd10:  // Light greenish blue
                          begin
                               vga_r <= 5'b00000; 
                               vga_g <= 6'b111111; 
                               vga_b <= 5'b10000; 
                          end
                          
                          4'd11:  // Purple
                          begin 
                               vga_r <= 5'b10000; 
                               vga_g <= 6'b000000; 
                               vga_b <= 5'b11111; 
                          end
                          
                          4'd12:  // Pink
                          begin 
                               vga_r <= 5'b11111; 
                               vga_g <= 6'b000000; 
                               vga_b <= 5'b10000; 
                          end
                          
                          4'd13:  // Dark green
                          begin 
                               vga_r <= 5'b00000; 
                               vga_g <= 6'b100000; 
                               vga_b <= 5'b00000; 
                          end
                          
                          4'd14:  //Leaf green
                          begin 
                               vga_r <= 5'b10000; 
                               vga_g <= 6'b110000; 
                               vga_b <= 5'b00000; 
                          end
                          
                          4'd15:  //Gray
                          begin 
                               vga_r <= 5'b10000; 
                               vga_g <= 6'b100000; 
                               vga_b <= 5'b10000; 
                          end
                     endcase
                end
                
                else // blanking [Back poarch + Sync pulse + front poarch]
                begin
                     vga_r <= 5'b00000;
                     vga_g <= 6'b000000;
                     vga_b <= 5'b00000;
                end    
          end
          
          else
          begin
                clk_div <= clk_div + 1;
          end   
     end
end

endmodule
