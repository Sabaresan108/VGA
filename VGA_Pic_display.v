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
        
reg in_box_d;
reg active_d;
       
reg [15:0] image_rom [0:16383];

initial
begin
     $readmemh("image.mem",image_rom); //Memory initialization
end

wire in_box = (h_count >= 10'd255 && h_count < 10'd385)&&(v_count >= 10'd175 && v_count < 10'd305); //Image window detection using image height and width

wire [13:0] rom_addr = ((v_count - 10'd176) << 7)+(h_count[6:0]); //Address = (Row x width)+ column (2d to 1d address maping)

wire active_display = (h_count < 10'd640)&&(v_count < 10'd480); //Active display checker

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
                
                data_pixel <= image_rom[rom_addr];
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
                     if (in_box_d)
                     begin
                          vga_r <= data_pixel[15:11];
                          vga_g <= data_pixel[10:5];
                          vga_b <= data_pixel[4:0];
                     end
                    
                     else
                     begin
                          vga_r <= 5'd00000;
                          vga_g <= 6'd000000;
                          vga_b <= 5'b00000;
                     end
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
