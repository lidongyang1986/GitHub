//////////////////////////////////////////
// Interface declaration for the memory///
//////////////////////////////////////////

interface mem_interface(input bit clock);
  logic [7:0] mem_data;
  logic [1:0] mem_add;
  logic       mem_en;
  logic       mem_rd_wr;

  clocking cb@(posedge clock);
     default input #1 output #1;
     output     mem_data;
     output      mem_add;
     output mem_en;
     output mem_rd_wr;
  endclocking

  modport MEM(clocking cb,input clock);

endinterface

////////////////////////////////////////////
// Interface for the input side of switch.//
// Reset signal is also passed hear.      //
////////////////////////////////////////////
interface input_interface(input bit clock);
  logic           data_status;
  logic     [7:0] data_in;
  logic           reset;

  clocking cb@(posedge clock);
     default input #1 output #1;
     output    data_status;
     output    data_in;
  endclocking

  modport IP(clocking cb,output reset,input clock);

endinterface

/////////////////////////////////////////////////
// Interface for the output side of the switch.//
// output_interface is for only one output port//
/////////////////////////////////////////////////

interface output_interface(input bit clock);
  logic    [7:0] data_out;
  logic    ready;
  logic    read;

  clocking cb@(posedge clock);
    default input #1 output #1;
    input     data_out;
    input     ready;
    output    read;
  endclocking

  modport OP(clocking cb,input clock);

endinterface



=====================================================================================================


`include "interface.svh"
`include "testcase.svh"    
    
module top();

/////////////////////////////////////////////////////
// Clock Declaration and Generation                //
/////////////////////////////////////////////////////
bit Clock;

initial
  forever #10 Clock = ~Clock;

/////////////////////////////////////////////////////
//  Memory interface instance                      //
/////////////////////////////////////////////////////

mem_interface mem_intf(Clock);

/////////////////////////////////////////////////////
//  Input interface instance                       //
/////////////////////////////////////////////////////

input_interface input_intf(Clock);

/////////////////////////////////////////////////////
//  output interface instance                      //
/////////////////////////////////////////////////////

output_interface output_intf[4](Clock);

/////////////////////////////////////////////////////
//  Program block Testcase instance                //
/////////////////////////////////////////////////////

testcase TC (mem_intf,input_intf,output_intf);

/////////////////////////////////////////////////////
//  DUT instance and signal connection             //
/////////////////////////////////////////////////////

switch DUT    (.clk(Clock),
               .reset(input_intf.reset),
               .data_status(input_intf.data_status),
               .data(input_intf.data_in),
               .port0(output_intf[0].data_out),
               .port1(output_intf[1].data_out),
               .port2(output_intf[2].data_out),
               .port3(output_intf[3].data_out),
               .ready_0(output_intf[0].ready),
               .ready_1(output_intf[1].ready),
               .ready_2(output_intf[2].ready),
               .ready_3(output_intf[3].ready),
               .read_0(output_intf[0].read),
               .read_1(output_intf[1].read),
               .read_2(output_intf[2].read),
               .read_3(output_intf[3].read),
               .mem_en(mem_intf.mem_en),
               .mem_rd_wr(mem_intf.mem_rd_wr),
               .mem_add(mem_intf.mem_add),
               .mem_data(mem_intf.mem_data));


endmodule
    
