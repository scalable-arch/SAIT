`timescale 1ps/1ps

module TB_CRC32;

    parameter DATA_WIDTH = 512;
    parameter CRC_WIDTH = 32;

    parameter NUM_ITER = 10000;

    logic                               clk;
    logic                               rst_n;

    logic                               valid_err_i,    valid_err_o,
                                        valid_dec_o;

    logic           [DATA_WIDTH-1:0]    original_data,  
                                        erroneous_data;
    logic           [CRC_WIDTH-1:0]     original_checksum,
                                        erroneous_checksum;

    logic                               detected_o;
    logic                               corrupted;

    integer                             succeed,        failed;

    // CRC32 checksum generator module
    CRC32_GEN #(
        .DATA_WIDTH(DATA_WIDTH),
        .CRC_WIDTH(CRC_WIDTH)
    ) u_crc32_gen (
        .data_i(original_data),
        .checksum_o(original_checksum)
    );

    // CRC32 decoder module
    CRC32_DEC #(
        .DATA_WIDTH(DATA_WIDTH),
        .CRC_WIDTH(CRC_WIDTH)
    ) u_crc32_dec (
        .clk(clk),
        .rst_n(rst_n),
        
        .valid_i(valid_err_o),
        .data_i(erroneous_data),
        .checksum_i(erroneous_checksum),

        .valid_o(valid_dec_o),
        .data_o(data_o),
        .detected_o(detected_o)
    );

    // Error generator module
    ERR_GEN #(
        .DATA_WIDTH(DATA_WIDTH),
        .CRC_WIDTH(CRC_WIDTH)
    ) u_err_gen (
        .clk(clk),
        .rst_n(rst_n),

        .valid_i(valid_err_i),
        .data_i(original_data),
        .checksum_i(original_checksum),

        .valid_o(valid_err_o),
        .data_o(erroneous_data),
        .checksum_o(erroneous_checksum),
        .corrupted_o(corrupted)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk; // 500MHz clock
        end
    end

    initial begin
        succeed                 = 0;
        failed                  = 0;
    end

    initial begin
        // Reset
        rst_n                   = 1'b1;
        valid_err_i             = 1'b0;
        #10 rst_n               = ~rst_n;
        #10 rst_n               = ~rst_n;
        #15;

        // Simulation starts now.
        // Generate test stimuli.
        for (int unsigned i = 0; i < NUM_ITER; i++) begin

            // 1) Generate random data and encode.
            @(negedge clk);
            original_data           = { $urandom(), $urandom(), $urandom(), $urandom(),
                                        $urandom(), $urandom(), $urandom(), $urandom(),
                                        $urandom(), $urandom(), $urandom(), $urandom(),
                                        $urandom(), $urandom(), $urandom(), $urandom() };
            $display(">>> [%0t] Input data : 0x%X (Checksum : 0x%X)", $time, original_data, original_checksum);

            // 2) Inject errors on the encoded codeword.
            valid_err_i             = 1'b1;
            wait(valid_err_o === 1'b1);  // error generation finished
            valid_err_i             = 1'b0;
            $display(">>> [%0t] Corrupted data : 0x%X (Checksum : 0x%X)", $time, erroneous_data, erroneous_checksum);

            // 3) Decode the corrupted codeword.
            wait(valid_dec_o === 1'b1);  // decoding finished

            // 4) Check if the decoding is correct.
            if (corrupted === detected_o) begin
                $display(">>> [%0t] Decoding finished : SUCCEED (%d)\n", $time, corrupted);
                succeed             += 1;
            end
            else begin
                $display(">>> [%0t] Decoding finished : FAILED (%d)\n", $time, corrupted);
                failed              += 1;
            end

            #20;
        end

        $display("-----------------------------------------------");
        $display("  SUCCEED : %d, FAILED : %d", succeed, failed);
        $display("-----------------------------------------------");

        #10 $finish;
    end

endmodule