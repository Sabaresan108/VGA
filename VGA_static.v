module VGA_static(input clk, rst,
               output reg vga_hs,
               output reg vga_vs,
               output reg [4:0]vga_r,
               output reg [5:0]vga_g,
               output reg [4:0]vga_b );
               
reg [2:0] clk_div;               
reg [9:0] h_count;
reg [9:0] v_count;

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
                    if (h_count < 10'd80) // White
                    begin
                         vga_r <= 5'b11111;
                         vga_g <= 6'b111111;
                         vga_b <= 5'b11111;
                    end
                    
                    else if (h_count < 10'd160) // Yellow
                    begin
                          vga_r <= 5'b11111;
                          vga_g <= 6'b111111;
                          vga_b <= 5'b00000;
                    end
                    
                    else if (h_count < 10'd240) //Cyan
                    begin
                         vga_r <= 5'b00000;
                         vga_g <= 6'b111111;
                         vga_b <= 5'b11111;
                    end
                    
                    else if (h_count < 10'd320) //Green
                    begin
                         vga_r <= 5'b00000;
                         vga_g <= 6'b111111;
                         vga_b <= 5'b00000;
                    end
                    
                    else if (h_count < 10'd400) // Pink
                    begin
                         vga_r <= 5'b11111;
                         vga_g <= 6'b000000;
                         vga_b <= 5'b11111;
                    end
                    
                    else if (h_count < 10'd480) //RED
                    begin
                         vga_r <= 5'b11111;
                         vga_g <= 6'b000000;
                         vga_b <= 5'b00000;
                    end
                                        
                    else if (h_count < 10'd560) //Blue
                    begin
                         vga_r <= 5'b00000;
                         vga_g <= 6'b000000;
                         vga_b <= 5'b11111;
                    end
                    
                    else //Black
                    begin
                         vga_r <= 5'b00000;
                         vga_g <= 6'b000000;
                         vga_b <= 5'b00000;                        
                    end                    
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
