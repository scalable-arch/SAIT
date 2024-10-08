`timescale 1ps/1ps

module TB_CRC32;

    parameter DATA_WIDTH = 512;
    parameter CRC_WIDTH = 32;

    parameter NUM_ITER = 100;

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

    localparam [DATA_WIDTH-1:0] CRC_COEFF_TABLE[CRC_WIDTH-1:0] = '{
        512'hD210_37B1_B96B_DC5B_837A_27C3_2024_A43C_2784_0AEF_3372_EAF4_89A0_F5B0_5B97_AEBF_44EB_00EB_91FB_097C_0D93_D510_F114_BEBF_B110_1011_89F5_2801_5444_0001_EA00_0001,
        512'h7630_58D2_CBBC_64EC_858E_6845_606D_EC44_688C_1F31_5597_3F1D_9AE1_1ED0_ECB8_F3C1_CD3D_013C_B20D_1B84_16B4_7F31_133D_C3C0_D330_3032_9A1F_7803_FCCC_0002_3E00_0003,
        512'h3E70_8614_2E13_1582_8866_F749_E0FF_7CB4_F69C_348D_985C_94CF_BC62_C811_82E6_493C_DE91_0292_F5E1_3E74_20FB_2B72_D76F_393E_1770_7074_BDCB_D806_ADDC_0005_9600_0007,
        512'hAEF1_3B99_E54D_F75E_93B7_C950_E1DA_5D55_CABC_63F4_03CB_C36B_F165_6593_5E5B_3CC6_F9C9_05CE_7A39_7594_4C65_83F5_5FCA_CCC3_9FF0_F0F8_F262_980C_0FFC_000A_C600_000F,
        512'h5DE2_7733_CA9B_EEBD_276F_92A1_C3B4_BAAB_9578_C7E8_0797_86D7_E2CA_CB26_BCB6_798D_F392_0B9C_F472_EB28_98CB_07EA_BF95_9987_3FE1_E1F1_E4C5_3018_1FF8_0015_8C00_001E,
        512'h69D4_D9D6_2C5C_0121_CDA5_0280_A74D_D16B_0D75_853F_3C5D_E75B_4C35_63FD_22FB_5DA4_A3CF_17D2_791E_DF2D_3C05_DAC5_8E3F_8DB1_CED3_D3F2_407F_4831_6BB4_002A_F200_003D,
        512'hD3A9_B3AC_58B8_0243_9B4A_0501_4E9B_A2D6_1AEB_0A7E_78BB_CEB6_986A_C7FA_45F6_BB49_479E_2FA4_F23D_BE5A_780B_B58B_1C7F_1B63_9DA7_A7E4_80FE_9062_D768_0055_E400_007A,
        512'h7543_50E9_081B_D8DC_B5EE_2DC1_BD13_E190_1252_1E13_C205_7799_B975_7A44_D07A_D82D_CBD7_5FA2_7580_75C8_FD84_BE06_C9EA_8878_8A5F_5FD8_8808_08C4_FA94_00AA_2200_00F5,
        512'hEA86_A1D2_1037_B1B9_6BDC_5B83_7A27_C320_24A4_3C27_840A_EF33_72EA_F489_A0F5_B05B_97AE_BF44_EB00_EB91_FB09_7C0D_93D5_10F1_14BE_BFB1_1010_1189_F528_0154_4400_01EA,
        512'hD50D_43A4_206F_6372_D7B8_B706_F44F_8640_4948_784F_0815_DE66_E5D5_E913_41EB_60B7_2F5D_7E89_D601_D723_F612_F81B_27AA_21E2_297D_7F62_2020_2313_EA50_02A8_8800_03D4,
        512'hAA1A_8748_40DE_C6E5_AF71_6E0D_E89F_0C80_9290_F09E_102B_BCCD_CBAB_D226_83D6_C16E_5EBA_FD13_AC03_AE47_EC25_F036_4F54_43C4_52FA_FEC4_4040_4627_D4A0_0551_1000_07A8,
        512'h5435_0E90_81BD_8DCB_5EE2_DC1B_D13E_1901_2521_E13C_2057_799B_9757_A44D_07AD_82DC_BD75_FA27_5807_5C8F_D84B_E06C_9EA8_8788_A5F5_FD88_8080_8C4F_A940_0AA2_2000_0F50,
        512'hA86A_1D21_037B_1B96_BDC5_B837_A27C_3202_4A43_C278_40AE_F337_2EAF_489A_0F5B_05B9_7AEB_F44E_B00E_B91F_B097_C0D9_3D51_0F11_4BEB_FB11_0101_189F_5280_1544_4000_1EA0,
        512'h50D4_3A42_06F6_372D_7B8B_706F_44F8_6404_9487_84F0_815D_E66E_5D5E_9134_1EB6_0B72_F5D7_E89D_601D_723F_612F_81B2_7AA2_1E22_97D7_F622_0202_313E_A500_2A88_8000_3D40,
        512'hA1A8_7484_0DEC_6E5A_F716_E0DE_89F0_C809_290F_09E1_02BB_CCDC_BABD_2268_3D6C_16E5_EBAF_D13A_C03A_E47E_C25F_0364_F544_3C45_2FAF_EC44_0404_627D_4A00_5511_0000_7A80,
        512'h4350_E908_1BD8_DCB5_EE2D_C1BD_13E1_9012_521E_13C2_0577_99B9_757A_44D0_7AD8_2DCB_D75F_A275_8075_C8FD_84BE_06C9_EA88_788A_5F5F_D888_0808_C4FA_9400_AA22_0000_F500,
        512'h86A1_D210_37B1_B96B_DC5B_837A_27C3_2024_A43C_2784_0AEF_3372_EAF4_89A0_F5B0_5B97_AEBF_44EB_00EB_91FB_097C_0D93_D510_F114_BEBF_B110_1011_89F5_2801_5444_0001_EA00,
        512'h0D43_A420_6F63_72D7_B8B7_06F4_4F86_4049_4878_4F08_15DE_66E5_D5E9_1341_EB60_B72F_5D7E_89D6_01D7_23F6_12F8_1B27_AA21_E229_7D7F_6220_2023_13EA_5002_A888_0003_D400,
        512'h1A87_4840_DEC6_E5AF_716E_0DE8_9F0C_8092_90F0_9E10_2BBC_CDCB_ABD2_2683_D6C1_6E5E_BAFD_13AC_03AE_47EC_25F0_364F_5443_C452_FAFE_C440_4046_27D4_A005_5110_0007_A800,
        512'h350E_9081_BD8D_CB5E_E2DC_1BD1_3E19_0125_21E1_3C20_5779_9B97_57A4_4D07_AD82_DCBD_75FA_2758_075C_8FD8_4BE0_6C9E_A887_88A5_F5FD_8880_808C_4FA9_400A_A220_000F_5000,
        512'h6A1D_2103_7B1B_96BD_C5B8_37A2_7C32_024A_43C2_7840_AEF3_372E_AF48_9A0F_5B05_B97A_EBF4_4EB0_0EB9_1FB0_97C0_D93D_510F_114B_EBFB_1101_0118_9F52_8015_4440_001E_A000,
        512'hD43A_4206_F637_2D7B_8B70_6F44_F864_0494_8784_F081_5DE6_6E5D_5E91_341E_B60B_72F5_D7E8_9D60_1D72_3F61_2F81_B27A_A21E_2297_D7F6_2202_0231_3EA5_002A_8880_003D_4000,
        512'hA874_840D_EC6E_5AF7_16E0_DE89_F0C8_0929_0F09_E102_BBCC_DCBA_BD22_683D_6C16_E5EB_AFD1_3AC0_3AE4_7EC2_5F03_64F5_443C_452F_AFEC_4404_0462_7D4A_0055_1100_007A_8000,
        512'h50E9_081B_D8DC_B5EE_2DC1_BD13_E190_1252_1E13_C205_7799_B975_7A44_D07A_D82D_CBD7_5FA2_7580_75C8_FD84_BE06_C9EA_8878_8A5F_5FD8_8808_08C4_FA94_00AA_2200_00F5_0000,
        512'hA1D2_1037_B1B9_6BDC_5B83_7A27_C320_24A4_3C27_840A_EF33_72EA_F489_A0F5_B05B_97AE_BF44_EB00_EB91_FB09_7C0D_93D5_10F1_14BE_BFB1_1010_1189_F528_0154_4400_01EA_0000,
        512'h43A4_206F_6372_D7B8_B706_F44F_8640_4948_784F_0815_DE66_E5D5_E913_41EB_60B7_2F5D_7E89_D601_D723_F612_F81B_27AA_21E2_297D_7F62_2020_2313_EA50_02A8_8800_03D4_0000,
        512'h8748_40DE_C6E5_AF71_6E0D_E89F_0C80_9290_F09E_102B_BCCD_CBAB_D226_83D6_C16E_5EBA_FD13_AC03_AE47_EC25_F036_4F54_43C4_52FA_FEC4_4040_4627_D4A0_0551_1000_07A8_0000,
        512'h0E90_81BD_8DCB_5EE2_DC1B_D13E_1901_2521_E13C_2057_799B_9757_A44D_07AD_82DC_BD75_FA27_5807_5C8F_D84B_E06C_9EA8_8788_A5F5_FD88_8080_8C4F_A940_0AA2_2000_0F50_0000,
        512'h1D21_037B_1B96_BDC5_B837_A27C_3202_4A43_C278_40AE_F337_2EAF_489A_0F5B_05B9_7AEB_F44E_B00E_B91F_B097_C0D9_3D51_0F11_4BEB_FB11_0101_189F_5280_1544_4000_1EA0_0000,
        512'h3A42_06F6_372D_7B8B_706F_44F8_6404_9487_84F0_815D_E66E_5D5E_9134_1EB6_0B72_F5D7_E89D_601D_723F_612F_81B2_7AA2_1E22_97D7_F622_0202_313E_A500_2A88_8000_3D40_0000,
        512'h7484_0DEC_6E5A_F716_E0DE_89F0_C809_290F_09E1_02BB_CCDC_BABD_2268_3D6C_16E5_EBAF_D13A_C03A_E47E_C25F_0364_F544_3C45_2FAF_EC44_0404_627D_4A00_5511_0000_7A80_0000,
        512'hE908_1BD8_DCB5_EE2D_C1BD_13E1_9012_521E_13C2_0577_99B9_757A_44D0_7AD8_2DCB_D75F_A275_8075_C8FD_84BE_06C9_EA88_788A_5F5F_D888_0808_C4FA_9400_AA22_0000_F500_0000};

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

    always_comb begin
        // Calculate over 32-bits of CRC checksum.
        for (int i = 0; i < CRC_WIDTH; i++) begin
            original_checksum[i]                   = ^(original_data & CRC_COEFF_TABLE[i]);
        end        
    end

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