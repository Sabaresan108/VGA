module VGA_Pic_display(input clk,rst,
                       output reg vga_hs,
                       output reg vga_vs,
                       output reg [4:0] vga_r,
                       output reg [5:0] vga_g,
                       output reg [4:0] vga_b);

reg [2:0] clk_div;
reg [9:0] h_count;
reg [9:0] v_count;
reg [15:0] data_pixel;                                        
reg [15:0] ram_data;   

reg [2:0]  pixel_sel_d;        
reg in_box_d;
reg active_d;
       
(* ram_style = "block" *) reg  [15:0] b_ram [0:38399];

initial
begin
     $readmemh("image.mem",b_ram); //Memory initialization
end

wire in_box = (h_count >= 10'd255 && h_count < 10'd385)&&(v_count >= 10'd175 && v_count < 10'd305); //Image window detection using image height and width

wire [15:0] rom_addr = ((v_count << 6)+(v_count << 4))+(h_count >> 3); //Address = (Row x width)+ column (2d to 1d address maping)

wire active_display = (h_count < 10'd640)&&(v_count < 10'd480); //Active display checker

wire [1:0] pixel_color = (ram_data >> ((3'd7 - pixel_sel_d) * 2)) & 2'b11;




always @(posedge clk)
begin
     if(~rst)
     begin
           h_count    <= 0;
           v_count    <= 0;
           clk_div    <= 0;
           data_pixel <= 0;
           in_box_d   <= 0;
           active_d   <= 0;
           vga_hs     <= 1;
           vga_vs     <= 1;
           vga_r      <= 0;
           vga_g      <= 0;
           vga_b      <= 0;
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
                     h_count = h_count + 1;
                end
                
                ram_data <= b_ram[rom_addr];
                in_box_d   <= in_box;
                active_d   <= active_display;
                
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
                
                if (active_d) //Check whether image is in correct dimension
                begin
                     case (pixel_color)
                           2'b00: //Black 
                           begin
                                vga_r <= 5'b00000;
                                vga_g <= 6'b000000;
                                vga_b <= 5'b00000;
                           end
                           
                           2'b01: //Dark gray
                           begin 
                                vga_r <= 5'b01010;
                                vga_g <= 6'b010101;
                                vga_b <= 5'b01010;
                           end
                           
                           2'b10: // Light gray
                           begin
                                vga_r <= 5'b10101;
                                vga_g <= 6'b101010;
                                vga_b <= 5'b10101;
                           end
                        
                           2'b11: //Full white 
                           begin 
                                vga_r <= 5'b11111;
                                vga_g <= 6'b111111;
                                vga_b <= 5'b11111;
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
