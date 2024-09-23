// Copyright (c) 2024 Sungkyunkwan University
// All rights reserved
// Author: Yujin Lim <dbwls1229@g.skku.edu>


module CRC32_DEC
#(
    parameter   DATA_WIDTH              = 512,
    parameter   CRC_WIDTH               = 32
)
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        valid_i,
    input   wire    [DATA_WIDTH-1:0]    data_i,
    input   wire    [CRC_WIDTH-1:0]     checksum_i,

    output  logic                       valid_o,
    output  logic   [DATA_WIDTH-1:0]    data_o,
    output  logic                       detected_o  // "1" if detected
);

    logic           [CRC_WIDTH-1:0]     checksum,       checksum_n;
    logic                               detected,       detected_n;

    // Module for generate CRC checksum.
    CRC32_GEN                           u_crc_gen_dec
    (
        .data_i                         (data_i),
        .checksum_o                     (checksum_n)
    );

    // It is considered that an error has beed detected
    // if the regenerated CRC checksum and the received CRC checksum 
    // are not the same.
    always_comb begin
        if (checksum_n != checksum_i) begin
            detected_n                  = 1'b1;
        end
        else begin
            detected_n                  = 1'b0;
        end
    end

    always_ff @(posedge clk)
        if (!rst_n) begin
            valid_o                     <= 1'b0;
            detected                    <= 1'bx;
        end
        else begin
            valid_o                     <= valid_i;
            detected                    <= detected_n;
        end

    assign  data_o                      = data_i;
    assign  detected_o                  = detected;

endmodule