//takes in carrier signal of high frequency,
module amp_modulator #(parameter DATA_WIDTH = 16)(
    input clk_i,
    input rst_i,
    input valid_i,
    input logic signed [DATA_WIDTH-1:0] signal_i,//carrier signal, actual wave that gets modulated high freq
    input logic signed [DATA_WIDTH-1:0] modulator_i,//modulating signal, controls amplitude low freq
    output logic signed [DATA_WIDTH-1:0] signal_o,
    output ready_o
);
logic signed [2*DATA_WIDTH-1:0] modulated_signal_reg;
/*
//multiply signal
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        modulated_signal_reg <= 0;
    end else begin
        //add one to prevent flipping carrier signal
        modulated_signal_reg <= signal_i * (1+modulator_i);//we should rplace with DSP later, just for testing purposes
    end
end
*/

//   DSP48E1   : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (DSP48E1_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // DSP48E1: 48-bit Multi-Functional Arithmetic Block
   //          Artix-7
   // Xilinx HDL Language Template, version 2024.2

   DSP48E1 #(
      // Feature Control Attributes: Data Path Selection
      .A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
      .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
      .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
      .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
      .USE_SIMD("ONE48"),               // SIMD selection ("ONE48", "TWO24", "FOUR12")
      // Pattern Detector Attributes: Pattern Detection Configuration
      .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
      .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
      .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
      .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
      .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
      .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
      // Register Control Attributes: Pipeline Register Configuration
      .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
      .ADREG(1),                        // Number of pipeline stages for pre-adder (0 or 1)
      .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
      .AREG(1),                         // Number of pipeline stages for A (0, 1 or 2)
      .BCASCREG(1),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
      .BREG(1),                         // Number of pipeline stages for B (0, 1 or 2)
      .CARRYINREG(1),                   // Number of pipeline stages for CARRYIN (0 or 1)
      .CARRYINSELREG(1),                // Number of pipeline stages for CARRYINSEL (0 or 1)
      .CREG(1),                         // Number of pipeline stages for C (0 or 1)
      .DREG(1),                         // Number of pipeline stages for D (0 or 1)
      .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
      .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
      .OPMODEREG(1),                    // Number of pipeline stages for OPMODE (0 or 1)
      .PREG(1)                          // Number of pipeline stages for P (0 or 1)
   )
   DSP48E1_inst (
      // Cascade: 30-bit (each) output: Cascade Ports
      .ACOUT(),                   // 30-bit output: A port cascade output
      .BCOUT(),                   // 18-bit output: B port cascade output
      .CARRYCASCOUT(),     // 1-bit output: Cascade carry output
      .MULTSIGNOUT(),       // 1-bit output: Multiplier sign cascade output
      .PCOUT(),                   // 48-bit output: Cascade output
      // Control: 1-bit (each) output: Control Inputs/Status Bits
      .OVERFLOW(),             // 1-bit output: Overflow in add/acc output
      .PATTERNBDETECT(), // 1-bit output: Pattern bar detect output
      .PATTERNDETECT(),   // 1-bit output: Pattern detect output
      .UNDERFLOW(),           // 1-bit output: Underflow in add/acc output
      // Data: 4-bit (each) output: Data Ports
      .CARRYOUT(),             // 4-bit output: Carry output
      .P(),                           // 48-bit output: Primary data output
      // Cascade: 30-bit (each) input: Cascade Ports
      .ACIN(),                     // 30-bit input: A cascade data input
      .BCIN(),                     // 18-bit input: B cascade input
      .CARRYCASCIN(),       // 1-bit input: Cascade carry input
      .MULTSIGNIN(),         // 1-bit input: Multiplier sign input
      .PCIN(),                     // 48-bit input: P cascade input
      // Control: 4-bit (each) input: Control Inputs/Status Bits
      .ALUMODE(4'b0000),               // Z + X + Y + CIN // 4-bit input: ALU control input
      .CARRYINSEL(3'b000),         //SELECTS CARRYIN // 3-bit input: Carry select input
      .CLK(),                       // 1-bit input: Clock input
      .INMODE(),                 // 5-bit input: INMODE control input
      .OPMODE(),                 // 7-bit input: Operation mode input
      // Data: 30-bit (each) input: Data Ports
      .A(A),                           // 30-bit input: A data input
      .B({{(18-DATA_WIDTH){1'b0}},signal_i}),                           // 18-bit input: B data input
      .C(C),                           // 48-bit input: C data input
      .CARRYIN(),               // 1-bit input: Carry input signal
      .D(D),                           // 25-bit input: D data input
      // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
      .CEA1(),                     // 1-bit input: Clock enable input for 1st stage AREG
      .CEA2(),                     // 1-bit input: Clock enable input for 2nd stage AREG
      .CEAD(),                     // 1-bit input: Clock enable input for ADREG
      .CEALUMODE(),           // 1-bit input: Clock enable input for ALUMODE
      .CEB1(),                     // 1-bit input: Clock enable input for 1st stage BREG
      .CEB2(),                     // 1-bit input: Clock enable input for 2nd stage BREG
      .CEC(),                       // 1-bit input: Clock enable input for CREG
      .CECARRYIN(),           // 1-bit input: Clock enable input for CARRYINREG
      .CECTRL(),                 // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
      .CED(),                       // 1-bit input: Clock enable input for DREG
      .CEINMODE(),             // 1-bit input: Clock enable input for INMODEREG
      .CEM(),                       // 1-bit input: Clock enable input for MREG
      .CEP(),                       // 1-bit input: Clock enable input for PREG
      .RSTA(),                     // 1-bit input: Reset input for AREG
      .RSTALLCARRYIN(),   // 1-bit input: Reset input for CARRYINREG
      .RSTALUMODE(),         // 1-bit input: Reset input for ALUMODEREG
      .RSTB(),                     // 1-bit input: Reset input for BREG
      .RSTC(),                     // 1-bit input: Reset input for CREG
      .RSTCTRL(),               // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
      .RSTD(),                     // 1-bit input: Reset input for DREG and ADREG
      .RSTINMODE(),           // 1-bit input: Reset input for INMODEREG
      .RSTM(),                     // 1-bit input: Reset input for MREG
      .RSTP()                      // 1-bit input: Reset input for PREG
   );

   // End of DSP48E1_inst instantiation



//envelope
//envelope is supposed to show overall trend for amplitue of high frequency signals, ignoring oscillations
//if signal is less than 0, take absolute value
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        signal_o <= 0;
    end else begin
        //fill bit widths for mult result
        signal_o <= modulated_signal_reg >>> (DATA_WIDTH - 1);
    end
end
endmodule
