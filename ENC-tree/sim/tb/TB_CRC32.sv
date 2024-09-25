`timescale 1ps/1ps

module TB_CRC32;

    parameter DATA_WIDTH = 512;
    parameter CRC_WIDTH = 32;

    parameter NUM_ITER = 10;

    logic                               clk;
    logic                               rst_n;

    logic                               valid_enc_i,    valid_enc_o;
                                        
    logic           [DATA_WIDTH-1:0]    data_enc_i,     data_enc_o;

    logic           [CRC_WIDTH-1:0]     checksum_enc_o,
                                        reversed_checksum;

    // CRC32 encoder module
    CRC32_ENC #(
        .DATA_WIDTH(DATA_WIDTH),
        .CRC_WIDTH(CRC_WIDTH)
    ) u_crc32_enc (
        .clk(clk),
        .rst_n(rst_n),
        
        .valid_i(valid_enc_i),
        .data_i(data_enc_i),

        .valid_o(valid_enc_o),
        .data_o(data_enc_o),
        .checksum_o(checksum_enc_o)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk; // 500MHz clock
        end
    end

    initial begin
        // Reset
        valid_enc_i             = 1'b0;
        rst_n                   = 1'b1;
        #10 rst_n               = ~rst_n;
        #10 rst_n               = ~rst_n;
        #10;

        // Simulation starts now.
        // Generate test stimuli.
        for (int unsigned i = 0; i < NUM_ITER; i++) begin

            // 1) Generate random data.
            @(negedge clk);
            data_enc_i              = { $urandom(), $urandom(), $urandom(), $urandom(),
                                        $urandom(), $urandom(), $urandom(), $urandom(),
                                        $urandom(), $urandom(), $urandom(), $urandom(),
                                        $urandom(), $urandom(), $urandom(), $urandom() };
            $display(">>> [%0t] Input data : 0x%X", $time, data_enc_i);
            valid_enc_i             = 1'b1;
            
            // 2) Encode data.
            wait(valid_enc_o === 1'b1);  // encoding finished
            valid_enc_i             = 1'b0;
            for (int i = 0; i < CRC_WIDTH; i++) begin
                reversed_checksum[i] = checksum_enc_o[CRC_WIDTH - 1 - i];
            end
            $display(">>> [%0t] Encoding finished (Checksum : 0x%X)", $time, reversed_checksum);

            #20;
        end

        #10 $finish;
    end

endmodule