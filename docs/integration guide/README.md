# Integration Guide

# Integration Example

# Port List
## ENC
| Port           | Direction | Width    | Description                               |
| :---           | :---      | :---     | :---                                      |
| clk            | Input     | 1        | Clock                                     |
| rst_n          | Input     | 1        | Reset (active low) synchronizd to the clk |
| valid_i        | Input     | 1        | Valid signal for data_i                   |
| data_i         | Input     | 512      | Input data                                |
| valid_o        | Output    | 1        | Valid signal for data_o, checksum_o       |
| data_o         | Output    | 512      | Output data (same as data_i)              |
| checksum_o     | Output    | 32       | Calculated checksum for input data        |

## DEC
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
