// Copyright (c) 2024 Sungkyunkwan University
// All rights reserved
// Author: Yujin Lim <dbwls1229@g.skku.edu>


// Define your CRC32 here.
// GEN_POLY : CRC32 generator polynomial (Ignore the highest "1").
`define     GEN_POLY                    32'h814141AB


module CRC32_GEN
#(
    parameter   DATA_WIDTH              = 512,
    parameter   CRC_WIDTH               = 32
)
(
    input   wire    [DATA_WIDTH-1:0]    data_i,
    output  logic   [CRC_WIDTH-1:0]     checksum_o
);

    logic           [DATA_WIDTH-1:0]    dividend;
    logic           [CRC_WIDTH-1:0]     crc_temp;
        
    always_comb begin
        dividend                            = data_i;
        crc_temp                            = 32'h00000000;

        for (int unsigned i = 0; i < DATA_WIDTH; i = i + 1) begin
            if (crc_temp[CRC_WIDTH-1] != dividend[DATA_WIDTH-1]) begin
                crc_temp                        = (crc_temp << 1) ^ `GEN_POLY;
            end 
            else begin
                crc_temp                        = crc_temp << 1;
            end

            dividend                            = dividend << 1;
        end
    end

    assign  checksum_o                  = crc_temp;  // final crc checksum

endmodule