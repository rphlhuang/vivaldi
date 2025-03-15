`timescale 1ns/1ps
module adsr_envelope #(
    parameter DATA_WIDTH = 16
    //parameter ATTACK_TIME = 100,//clk cycles
    //parameter DECAY_TIME = 100,
    //parameter SUSTAIN_LEVEL = 0.5,//sustain levelm what it drops to
    //parameter RELEASE_TIME = 100
)(
    input logic clk_i,
    input logic rst_i,
    input logic  valid_i,
    input logic [DATA_WIDTH-1:0] attack_time_i, 
    input logic [DATA_WIDTH-1:0] decay_time_i, 
    input logic [DATA_WIDTH-1:0] sustain_level_i,//not exatly sure how this will synthesize for floating point
    input logic [DATA_WIDTH-1:0] release_time_i,
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
                if (counter < attack_time_i) begin
                    level <= (counter * (2**(DATA_WIDTH-1))) / attack_time_i;//sloped line
                    counter <= counter + 1;
                end else begin
                    state <= DECAY;
                    counter <= 0;
                end
            end
            DECAY: begin
                if (counter < decay_time_i) begin
                    //max amplitude reached 
                    level <= ((2**(DATA_WIDTH-1)) * (decay_time_i - counter) + sustain_level_i * counter) / decay_time_i;//opposite slope
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
                level <= sustain_level_i;
            end
            RELEASE: begin
                if (counter < release_time_i) begin
                    //starts at previou sustain level
                    level <= (sustain_level_i * (release_time_i - counter)) / release_time_i;
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
