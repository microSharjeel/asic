//data width
`define DCACHE_ADDR_W 24
`define FIRM_ADDR_W  20
`define BOOTROM_ADDR_W 12
`define SRAM_ADDR_W    14//20  changed to avoid big ram
`define N_SLAVES 1
`define DATA_W 32
//address width
`define ADDR_W 32
// number of slaves (log2)
`define N_SLAVES_W $clog2(`N_SLAVES)

//init sram/ddr with firmware
`ifdef INIT_MEM
 `ifdef USE_DDR
  `ifdef RUN_DDR
   `define DDR_INIT
  `else
   `define SRAM_INIT
  `endif
 `else //ddr not used
  `define SRAM_INIT
 `endif
`else
 `define LD_FW
`endif

// run modes
`ifdef USE_DDR
 `ifdef RUN_DDR
  `define RUN_DDR_USE_SRAM
 `else
  `define RUN_SRAM_USE_DDR
 `endif
`endif
 
// data bus select bits
`define V_BIT (`REQ_W - 1) //valid bit
`define E_BIT (`REQ_W - (`ADDR_W-32)) //`E+1)) //extra mem select bit
`define P_BIT (`REQ_W - (`ADDR_W-32)) //`P+1)) //peripherals select bitP:=31
`define B_BIT (`REQ_W - (`ADDR_W-31)) //`B+1)) //boot controller select bit
