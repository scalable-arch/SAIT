module ERR_GEN
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
    output  logic   [CRC_WIDTH-1:0]     checksum_o,
    output  logic                       corrupted_o                    
);

    logic           [DATA_WIDTH-1:0]    data,       data_n;
    logic           [CRC_WIDTH-1:0]     checksum,   checksum_n;
    logic                               corrupted,  corrupted_n;

    int unsigned                        start_bit;
    int unsigned                        bit_pos;

    always_comb begin
        data_n                          = data_i;
        checksum_n                      = checksum_i;
        corrupted_n                     = 1'b0;

        if (valid_i) begin
            corrupted_n                     = 1'b0;

            if ($urandom_range(0, 1)) begin
                start_bit                       = $urandom_range(0, DATA_WIDTH + CRC_WIDTH - 32);

                for (int unsigned i = 0; i < CRC_WIDTH; i++) begin
                    if ($urandom_range(0, 1)) begin
                        corrupted_n                 = 1'b1;
                        bit_pos                     = start_bit + i;

                        if (bit_pos < DATA_WIDTH) begin
                            data_n                  = data_n ^ (1 << bit_pos);
                        end
                        else begin
                            checksum_n              = checksum_n ^ (1 << (bit_pos - DATA_WIDTH));
                        end

                        $display("... Error injected at bit %d", bit_pos);
                    end
                end
            end
        end
        else begin
            data_n                      = data;
            checksum_n                  = checksum;
            corrupted_n                 = corrupted;
        end
    end

    always_ff @(posedge clk)
        if (!rst_n) begin
            valid_o                     <= 1'b0;
            data                        <= {$bits(data_i){1'bx}};
            checksum                    <= {$bits(checksum_i){1'bx}};
            corrupted                   <= {$bits(corrupted_o){1'bx}};
        end
        else begin
            valid_o                     <= valid_i;
            data                        <= data_n;
            checksum                    <= checksum_n;
            corrupted                   <= corrupted_n;
        end

    assign  data_o                      = data;
    assign  checksum_o                  = checksum;
    assign  corrupted_o                 = corrupted;

endmodule;