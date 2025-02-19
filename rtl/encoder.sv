module encoder
#()
(
    input clk,
    input [0:0] A_i,
    input [0:0] B_i,
    input [0:0] BTN_i,
    output [4:0] EncPos_o,
    output [7:0] LED_o
    );
	 logic [4:0] EncPos_o;
	 logic [7:0] LED_o;

     logic [31:0] currState_l = "idle";
	 logic [31:0] nextState_l;


	 always@(posedge clk or posedge BTN_i)
	 begin
			 if (BTN_i == 1'b1) begin
				 currState_l <= "idle";
				 EncPos_o <= 5'b00000;
			 end
			 // detect if the shaft is rotated to right or left
			 // right: add 1 to the position at each click
			 // left: subtract 1 from the position at each click
			 else begin
				 if(currState_l != nextState_l) begin
						if(currState_l == "add") begin
								if(EncPos_o < 5'b10011) begin
									EncPos_o <= EncPos_o + 1'b1;
								end
								else begin
									EncPos_o <= 5'b00000;
								end
						end
						else if(currState_l == "sub") begin
								if(EncPos_o > 5'b00000) begin
									EncPos_o <= EncPos_o - 1'b1;
								end
								else begin
									EncPos_o <= 5'b10011;
								end
						end
						else begin
								EncPos_o <= EncPos_o;
						end
				 end
				 else begin
						EncPos_o <= EncPos_o;
				 end

            currState_l <= nextState_l;
			 end
	 end


	 // *******************************************
	 //  					  Next State
	 // *******************************************
	 always@(currState_l or A_i or B_i)
	 begin
				 case (currState_l)
					  //detent position

					  "idle" : begin
							 LED_o <= {2'b00, 1'b0, EncPos_o};

							 if (B_i == 1'b0) begin
								 nextState_l <= "R1";
							 end
							 else if (A_i == 1'b0) begin
								 nextState_l <= "L1";
							 end
							 else begin
								 nextState_l <= "idle";
							 end
					  end
				     // start of right cycle
				     // R1
					  "R1" : begin
							 LED_o <= {2'b01, 1'b0, EncPos_o};

							 if (B_i == 1'b1) begin
								 nextState_l <= "idle";
							 end
							 else if (A_i == 1'b0) begin
								 nextState_l <= "R2";
							 end
							 else begin
								 nextState_l <= "R1";
							 end
					  end
					  // R2
					  "R2" : begin
							 LED_o <= {2'b01, 1'b0, EncPos_o};

							 if (A_i == 1'b1) begin
								 nextState_l <= "R1";
							 end
							 else if (B_i == 1'b1) begin
								 nextState_l <= "R3";
							 end
							 else begin
								 nextState_l <= "R2";
							 end
					  end
					  // R3
					  "R3" : begin
							 LED_o <= {2'b01, 1'b0, EncPos_o};

							 if (B_i == 1'b0) begin
								 nextState_l <= "R2";
							 end
							 else if (A_i == 1'b1) begin
								 nextState_l <= "add";
							 end
							 else begin
								 nextState_l <= "R3";
							 end
					  end
					  // R3
					  "R3" : begin
							 LED_o <= {2'b01, 1'b0, EncPos_o};

							 if (B_i == 1'b0) begin
								 nextState_l <= "R2";
							 end
							 else if (A_i == 1'b1) begin
								 nextState_l <= "add";
							 end
							 else begin
								 nextState_l <= "R3";
							 end
					  end
					  // Add
					  "add" : begin
							 LED_o <= {2'b01, 1'b0, EncPos_o};
							 nextState_l <= "idle";
					  end
   				  // Start of left cycle
                 // L1
					  "L1" : begin
							 LED_o <= {2'b10, 1'b0, EncPos_o};

							 if (A_i == 1'b1) begin
								 nextState_l <= "idle";
							 end
							 else if (B_i == 1'b0) begin
								 nextState_l <= "L2";
							 end
							 else begin
								 nextState_l <= "L1";
							 end
					  end
                 // L2
					  "L2" : begin
							 LED_o <= {2'b10, 1'b0, EncPos_o};

							 if (B_i == 1'b1) begin
								 nextState_l <= "L1";
							 end
							 else if (A_i == 1'b1) begin
								 nextState_l <= "L3";
							 end
							 else begin
								 nextState_l <= "L2";
							 end
					  end
                 // L3
					  "L3" : begin
							 LED_o <= {2'b10, 1'b0, EncPos_o};

							 if (A_i == 1'b0) begin
								 nextState_l <= "L2";
							 end
							 else if (B_i == 1'b1) begin
								 nextState_l <= "sub";
							 end
							 else begin
								 nextState_l <= "L3";
							 end
					  end
                 // Sub
					  "sub" : begin
							 LED_o <= {2'b10, 1'b0, EncPos_o};
							 nextState_l <= "idle";
					  end
					  //  Default
					  default : begin
							 LED_o <= {2'b11, 1'b0, EncPos_o};
							 nextState_l <= "idle";
					  end
				 endcase

	 end

endmodule
