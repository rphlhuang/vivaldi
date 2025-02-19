`timescale 1ps/1ps
module wavereader();

    logic clk;

    logic data_valid;
    int audio_in;
    int audio_out;

    int status;
    logic [7:0] aux;
    int number_of_samples;

    logic           [31:0]  chunk_id;
    logic           [31:0]  chunk_size;
    logic           [31:0]  format;
    logic           [31:0]  junk_chunk_id;
    logic           [31:0]  junk_chunk_size;
    logic           [7:0]   junk_chunk_data[];
    logic           [31:0]  subchunk_1_id;
    logic           [31:0]  subchunk_1_size;
    logic           [15:0]  audio_format;
    logic           [15:0]  num_channels;
    logic           [31:0]  sample_rate;
    logic           [31:0]  byte_rate;
    logic           [15:0]  block_align;
    logic           [15:0]  bits_per_sample;
    logic           [31:0]  subchunk_2_id;
    logic           [31:0]  subchunk_2_size;
    logic signed    [23:0]  data_left, data_left_aux;
    logic signed    [23:0]  data_right, data_right_aux;

    initial begin
        clk = 1'b0;
        forever begin
            #5ns;
            clk = ~clk;
        end
    end

    logic [7:0] my_byte;
    initial begin
        $dumpfile("wavereader.fst");
        $dumpvars;
        $display("------   Simulation Start   ------");
        data_valid = 1'b0;
        data_left_aux = '0;
        data_right_aux = '0;
        audio_in = $fopen("../../out.wav", "r");

        status = $fread(chunk_id, audio_in);
        if (status != 0) begin
            $display ("Chunk ID: 0x%h. Expected: 0x52494646 ('RIFF')", chunk_id);
        end
        status = $fread(chunk_size, audio_in);
        if (status != 0) begin
            chunk_size = { << byte {chunk_size}}; // Converts to big endian
            $display ("Chunk Size: %d bytes", chunk_size);
        end
        status = $fread(format, audio_in);
        if (status != 0) begin
            $display ("Format: 0x%h. Expected: 0x57415645 ('WAVE')", format);
        end

        // Only certain WAV files have a JUNK chunk
        // status = $fread(junk_chunk_id, audio_in);
        // if (status != 0) begin
        //     $display ("JUNK ID: 0x%h. Expected: 0x4a554e4b ('JUNK')", junk_chunk_id);
        // end
        // status = $fread(junk_chunk_size, audio_in);
        // if (status != 0) begin
        //     junk_chunk_size = { << byte {junk_chunk_size}}; // Converts to big endian
        //     $display ("Junk Chunk Size: %d bytes", junk_chunk_size);
        // end
        // // Junk Chunk Data array
        // junk_chunk_data = new[junk_chunk_size];
        // foreach (junk_chunk_data[i]) begin
        //     status = $fread(aux, audio_in);
        //     if (status != 0) begin
        //         junk_chunk_data[i] = aux;
        //     end
        // end
        // $display ("Junk data read");

        status = $fread(subchunk_1_id, audio_in);
        if (status != 0) begin
            $display ("Subchunk 1 ID read: 0x%h. Expected: 0x666d7420 ('fmt ')", subchunk_1_id);
        end
        status = $fread(subchunk_1_size, audio_in);
        subchunk_1_size = { << byte {subchunk_1_size}}; // Converts to big endian
        if (status != 0) begin
            $display ("Subchunk 1 Size: %d bytes. Expected: 16 (PCM)" , subchunk_1_size);
        end
        status = $fread(audio_format, audio_in);
        audio_format = { << byte {audio_format}}; // Converts to big endian
        if (status != 0) begin
            $display ("Audio Format: %d. Expected: 1 (other values indicate data compression)", audio_format);
        end
        status = $fread(num_channels, audio_in);
        num_channels = { << byte {num_channels}}; // Converts to big endian
        if (status != 0) begin
            $display ("Number of Channels: %d. Expected: 2 (stereo)", num_channels);
        end
        status = $fread(sample_rate, audio_in);
        sample_rate = { << byte {sample_rate}}; // Converts to big endian
        if (status != 0) begin
            $display ("Sample Rate: %d Hz", sample_rate);
        end
        status = $fread(byte_rate, audio_in);
        byte_rate = { << byte {byte_rate}}; // Converts to big endian
        if (status != 0) begin
            $display ("Byte Rate: %d Bps", byte_rate);
        end
        status = $fread(block_align, audio_in);
        block_align = { << byte {block_align}}; // Converts to big endian
        if (status != 0) begin
            $display ("Block Align: %d bytes", block_align);
        end
        status = $fread(bits_per_sample, audio_in);
        bits_per_sample = { << byte {bits_per_sample}}; // Converts to big endian
        if (status != 0) begin
            $display ("Bits per Sample: %d", bits_per_sample);
        end
        status = $fread(subchunk_2_id, audio_in);
        if (status != 0) begin
            $display ("Subchunk 2 ID: 0x%h. Expected: 0x64617461 ('data')", subchunk_2_id);
        end
        status = $fread(subchunk_2_size, audio_in);
        subchunk_2_size = { << byte {subchunk_2_size}}; // Converts to big endian
        if (status != 0) begin
            $display ("Subchunk 2 Size: %d bytes", subchunk_2_size);
        end
        number_of_samples = (subchunk_2_size*8)/(num_channels*bits_per_sample);
        $display ("Calculated Number of Samples: %d", number_of_samples);


        $display ("\nReading the audio data");
        #100ns;
        // for (int i = 0; i < number_of_samples; i++) begin
        for (int i = 0; i < 100; i++) begin
            for (int j = 0; j < (bits_per_sample/8); j++) begin
                status = $fread(aux, audio_in);
                data_left_aux = {aux, data_left_aux[23:8]};
            end
            for (int j = 0; j < (bits_per_sample/8); j++) begin
                status = $fread(aux, audio_in);
                data_right_aux = {aux, data_right_aux[23:8]};
            end
            @(posedge clk);
            data_valid = 1'b1;
            data_right = data_right_aux;
            data_left = data_left_aux;
            @(posedge clk);
            data_valid = 1'b0;
            #22665ns;
        end

        $display ("Audio data read");
        $fclose(audio_in);
        $display("------   Simulation End   ------");
        $finish;
    end

endmodule
