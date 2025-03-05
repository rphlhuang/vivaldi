module kpyd2hex
  (input [7:0] kpyd_i, 
  input clk_i,           
  input reset_i,
  output [3:0] hex_o
  );

  logic [1:0] row;
  always_comb begin
    case (kpyd_i[7:4])
      4'b0001: row = 2'b00; 
      4'b0010: row = 2'b01;  
      4'b0100: row = 2'b10;  
      4'b1000: row = 2'b11;  
      default: row = 2'b00;  
    endcase
  end

  logic [1:0] col;
  always_comb begin
    case (kpyd_i[3:0])
      4'b0001: col = 2'b00;  
      4'b0010: col = 2'b01;  
      4'b0100: col = 2'b10;  
      4'b1000: col = 2'b11;  
      default: col = 2'b00;  
    endcase
  end

  wire [3:0] address = {row, col};

  ram_1r1w_async #(
    .width_p(4),             
    .depth_p(16),           
    .filename_p("kpyd2hex.hex") 
  ) ram_lut (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .wr_valid_i(1'b0),    
    .wr_data_i(4'b0),         
    .wr_addr_i(4'b0),       
    .rd_addr_i(address),     
    .rd_data_o(hex_o)        
  );

endmodule
