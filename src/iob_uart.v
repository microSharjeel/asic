`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"
`include "iob_uart.vh"
`include "UARTsw_reg.vh"

module iob_uart 
  # (
     parameter ADDR_W = `UART_ADDR_W, //NODOC Address width
     parameter DATA_W = `UART_RDATA_W, //NODOC CPU data width
     parameter WDATA_W = `UART_WDATA_W //NODOC CPU data width
     )

  (

   //CPU interface
`ifndef USE_AXI4LITE
 //`include "cpu_nat_s_if.v"
 	       //CPU native interface
	       
               `INPUT(valid,   1),  //Native CPU interface valid signal
	       `INPUT(address, ADDR_W),  //Native CPU interface address signal
               `INPUT(wdata,   WDATA_W), //Native CPU interface data write signal
	       `INPUT(wstrb,   DATA_W/8),  //Native CPU interface write strobe signal
	       `OUTPUT(rdata,  DATA_W), //Native CPU interface read data signal
	       `OUTPUT(ready,  1),  //Native CPU interface ready signal
`else
 `include "cpu_axi4lite_s_if.v"
`endif

   //additional inputs and outputs

   //`OUTPUT(interrupt, 1), //to be done
   `OUTPUT(txd, 1),
   `INPUT(rxd, 1),
   `INPUT(cts, 1),
   `OUTPUT(rts, 1),
//`include "gen_if.v"
//General interface signals
`INPUT(clk,          1), //System clock input
`INPUT(rst,          1) //System reset, asynchronous and active high
   );

`SWREG_W(UART_SOFTRESET, 1, 0) //Bit duration in system clock cycles.
`SWREG_W(UART_DIV, DATA_W/2, 0) //Bit duration in system clock cycles.
`SWREG_W(UART_TXDATA, DATA_W/4, 0) //TX data
`SWREG_W(UART_TXEN, 1, 0) //TX enable.
`SWREG_R(UART_TXREADY, 1, 0) //TX ready to receive data
`SWREG_R(UART_RXDATA, DATA_W/4, 0) //RX data
`SWREG_W(UART_RXEN, 1, 0) //RX enable.
`SWREG_R(UART_RXREADY, 1, 0) //RX data is ready to be read.
//BLOCK Register File & Holds the current configuration of the UART as well as internal parameters. Data to be sent or that has been received is stored here temporarily.
`include "UARTsw_reg.vh"
//`include "UARTsw_reg_gen.v"
//write registers
`REG_ARE(clk, rst, 0, valid & wstrb & (address == 0), UART_SOFTRESET, wdata[1-1:0])
`REG_ARE(clk, rst, 0, valid & wstrb & (address == 1), UART_DIV, wdata[DATA_W/2-1:0])
`REG_ARE(clk, rst, 0, valid & wstrb & (address == 2), UART_TXDATA, wdata[DATA_W/4-1:0])
`REG_ARE(clk, rst, 0, valid & wstrb & (address == 3), UART_TXEN, wdata[1-1:0])
`REG_ARE(clk, rst, 0, valid & wstrb & (address == 6), UART_RXEN, wdata[1-1:0])


//read registers
`SIGNAL(rdata_int, DATA_W)
`SIGNAL2OUT(rdata, rdata_int)

always @* begin
   rdata_int = 1'b0;
   case(address)
     4: rdata_int = UART_TXREADY;
     5: rdata_int = UART_RXDATA;
     7: rdata_int = UART_RXREADY;
     default: rdata_int = 1'b0;
   endcase
end
`SIGNAL(ready_int, 1)
`REG_AR(clk, rst, 0, ready_int, valid)
`SIGNAL2OUT(ready, ready_int)
   
   uart_core uart_core0 
     (
      .clk(clk),
      .rst(rst),
      .rst_soft(UART_SOFTRESET),
      .tx_en(UART_TXEN),
      .rx_en(UART_RXEN),
      .tx_ready(UART_TXREADY),
      .rx_ready(UART_RXREADY),
      .tx_data(UART_TXDATA),
      .rx_data(UART_RXDATA),
      .data_write_en(valid & |wstrb & (address == `UART_TXDATA_ADDR)),
      .data_read_en(valid & !wstrb & (address == `UART_RXDATA_ADDR)),
      .bit_duration(UART_DIV),
      .rxd(rxd),
      .txd(txd),
      .cts(cts),
      .rts(rts)
      );
   
endmodule


