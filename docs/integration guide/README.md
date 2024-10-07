# Integration Guide

## Overview

This project provides the synthesis of a CRC32 encoder and decoder, along with the simulation of the CRC32 code's error detection performance.

## CRC32 Encoder & Decoder Synthesis (Verilog)
This section focuses on the Verilog RTL for synthesizing the CRC32 encoder and decoder logic.

We offer two approaches for implementing CRC32 :

+ **General** : Uses the basic division method.
+ **Table-based** : Utilizes precomputed CRC32 values.

Both methods allow synthesis using any desired CRC32 polynomial.

For more information, please refer to the `README` in the `Verilog/` directory.

### Port List

The following tables detail the port specifications for the CRC32 encoder and decoder modules.

#### Encoder
| Port           | Direction | Width    | Description                               |
| :---           | :---      | :---     | :---                                      |
| clk            | Input     | 1        | Clock                                     |
| rst_n          | Input     | 1        | Reset (active low) synchronizd to the clk |
| valid_i        | Input     | 1        | Valid signal for data_i                   |
| data_i         | Input     | 512      | Input data                                |
| valid_o        | Output    | 1        | Valid signal for data_o, checksum_o       |
| data_o         | Output    | 512      | Output data (same as data_i)              |
| checksum_o     | Output    | 32       | Calculated checksum for input data        |

#### Decoder
| Port           | Direction | Width    | Description                               |
| :---           | :---      | :---     | :---                                      |
| clk            | Input     | 1        | Clock                                     |
| rst_n          | Input     | 1        | Reset (active low) synchronizd to the clk |
| valid_i        | Input     | 1        | Valid signal for data_i, checksum_i       |
| data_i         | Input     | 512      | Input data                                |
| checksum_i     | Input     | 32       | Input checksum                            |
| valid_o        | Output    | 1        | Valid signal for data_o, detected_o       |
| data_o         | Output    | 512      | Output data (same as data_i)              |
| detected_o     | Output    | 32       | Error detection signal ('1' if detected)  |      


## Error Detection Performance Simulation (C)
This section includes simple C code simulations to evaluate the error detection capabilities of the CRC32 code.






You can also verify the encoding result of given data using ~~ mode.

       
