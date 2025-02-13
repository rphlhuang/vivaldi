`timescale 1ns/1ps

module adsr_envelope #(
    parameter DATA_WIDTH = 16,
    parameter CLK_PERIOD = 10,
    parameter ATTACK_TIME = 100,//clk cycles
    parameter DECAY_TIME = 100,
    parameter SUSTAIN_LEVEL = 0.5,//sustain levelm what it drops to
    parameter RELEASE_TIME = 100
)(
    input logic clk_i,
    input logic rst_i,
    input logic  valid_i,
    output logic ready_o,
    output logic signed [DATA_WIDTH-1:0] envelope_o
);

typedef enum logic [2:0] { IDLE, ATTACK, DECAY, SUSTAIN, RELEASE } adsr_state_t;
adsr_state_t state = IDLE;

logic [31:0] counter = 0;
logic signed [DATA_WIDTH-1:0] level = 0;

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        state <= IDLE;
        counter <= 0;
        level <= 0;
    end else begin
        case (state)
            IDLE: begin
                if (valid_i) begin
                    state <= ATTACK;//first state
                    counter <= 0;
                end
                level <= 0;
            end
            ATTACK: begin
                if (counter < ATTACK_TIME) begin
                    level <= (counter * (2**(DATA_WIDTH-1))) / ATTACK_TIME;//sloped line
                    counter <= counter + 1;
                end else begin
                    state <= DECAY;
                    counter <= 0;
                end
            end
            DECAY: begin
                if (counter < DECAY_TIME) begin
                    //max amplitude reached -
                    level <= ((2**(DATA_WIDTH-1)) - (counter * (2**(DATA_WIDTH-1) * (1 - SUSTAIN_LEVEL)) / DECAY_TIME));//opposite slope
                    counter <= counter + 1;
                end else begin
                    state <= SUSTAIN;
                end
            end
            SUSTAIN: begin
                if (!valid_i) begin
                    state <= RELEASE;
                    counter <= 0;
                end
                //constanr value
                level <= SUSTAIN_LEVEL * (2**(DATA_WIDTH-1));
            end
            RELEASE: begin
                if (counter < RELEASE_TIME) begin
                    //starts at previou sustain level
                    level <= ((SUSTAIN_LEVEL * (2**(DATA_WIDTH-1))) * (RELEASE_TIME - counter)) / RELEASE_TIME;
                    counter <= counter + 1;
                end else begin
                    state <= IDLE;
                    level <= 0;
                end
            end
        endcase
    end
end

assign envelope_o = level;
assign ready_o = 1'b1;

endmodule
