module low_pass_filter #(
    parameter [31:0] width_p = 8)
(   input [0:0] clk_i,
    input [0:0] reset_i,
    input [width_p-1:0] data_i,
    input [0:0] valid_i,
    input [0:0] ready_i,
    output [width_p-1:0] data_o,
    output [0:0] valid_o,
    output [0:0] ready_o
);

logic [width_p-1:0] data_diff_l;
logic [width_p-1:0] data_prev_l;


// at every calculation get the current input data for the next iteration
always_ff @(posedge clk_i) begin
    if(reset_i) begin
        data_prev_l <= 0;
    end
    else if(ready_o && valid_i) begin
        data_prev_l <= data_i;
    end
    else begin
        data_prev_l <= data_prev_l;
    end
end


always_comb begin : difference_calc
    if(reset_i) begin
        data_diff_l = '0;
    end
    else begin
        data_diff_l = data_i + data_prev_l;
    end
end



elastic
elastic_inst
  (.clk_i(clk_i),
   .reset_i(reset_i),
   .data_i(data_diff_l),
   .valid_i(valid_i),
   .ready_o(ready_o),
   .valid_o(valid_o),
   .data_o(data_o),
   .ready_i(ready_i)
  );


endmodule
