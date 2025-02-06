module i2s_transmitter
#()
(
    input wire clk,               // 48 kHz audio clock
    input wire reset,             // Reset signal
    input wire [15:0] audio_sample,  // 16-bit audio sample (your sine wave data)
    output logic sdata_out,         // I2S Data Output (Serial Data Line)
    output logic bclk,              // Bit Clock (BCLK)
    output logic lrclk              // Left/Right Clock (LRCLK)
);

    logic [15:0] shift_l;           // Holds the audio sample for shifting
    logic [4:0] bit_counter;          // Counter for bits per audio sample (16 bits)
    logic [1:0] lr_counter;           // Counter for Left/Right channel switching

    // Generate BCLK (Bit Clock) at 3.072 MHz (assuming 48kHz sample rate)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bclk <= 0;
        end else begin
            bclk <= ~bclk; // Toggle BCLK on each clock edge
        end
    end

    // Generate LRCLK (Left/Right Clock) at 48 kHz
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lrclk <= 0;
            lr_counter <= 0;
        end else if (bit_counter == 16) begin
            lr_counter <= lr_counter + 1; // Toggle every 16 bits (for stereo audio)
            if (lr_counter == 2) begin
                lrclk <= ~lrclk; // Toggle LRCLK (left/right channel switching)
                lr_counter <= 0;
            end
        end
    end

    // Shift the audio sample for serial transmission and handle I2S protocol
    always @(posedge bclk or posedge reset) begin
        if (reset) begin
            shift_l <= 16'b0;
            sdata_out <= 0;
            bit_counter <= 0;
        end else begin
            if (bit_counter == 0) begin
                shift_l <= audio_sample; // Load the new audio sample when bit_counter resets
            end else begin
                sdata_out <= shift_l[15]; // MSB of shift register goes to SDATA_OUT
                shift_l <= {shift_l[14:0], 1'b0}; // Shift left by one bit
            end

            if (bit_counter < 16) begin
                bit_counter <= bit_counter + 1;
            end else begin
                bit_counter <= 0; // Reset the bit counter after 16 bits
            end
        end
    end
endmodule
