//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Top level of memory model
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
module bus_top(bus_interface bif0); //。dut是用来规定接口方向

  reg [63:0] internal_reg;
  
  always@(posedge bif0.clk)begin
    internal_reg<=bif0.bus;
    $display("RTL_reg=%x",internal_reg);
  end 
  
endmodule























//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Declare memory interface
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
interface bus_interface (input bit clk);
  logic [63:0] bus;
  logic [31:0] tb_bus;


/*
  always@(posedge clk)begin
    bus[31:0]=tb_bus;
    $display("posedge bus=%x", bus);
  end
  
  always@(negedge clk)begin
    bus[63:32]=tb_bus;
    $display("negedge bus=%x",bus);
  end  
*/
  
  
  task bus_if_wr (input logic [31:0] tb_bus);
    @(posedge clk)begin
    	bus[31:0]=tb_bus;
    	$display("posedge bus=%x", bus);
    end
    @(negedge clk)begin
      	bus[63:32]=tb_bus;
      	$display("negedge bus=%x", bus);
    end   
  endtask
  
  //==============================================
  // Define the DUT modport
  //==============================================
  modport  dut (input  bus, clk);
  //==============================================
  // Define the Testbench Driver modport
  //==============================================
  modport  tb  (output tb_bus, input clk);

endinterface





//启动入口
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Memory top level with DUT and testbench
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
module bus_tb();
  logic clk = 0;
  always #1 clk = ~clk;
  //==============================================
  // interface with clock connected
  //==============================================
  bus_interface bus_if0(clk);

  //==============================================
  // Connect the DUT
  //==============================================
  bus_top U_bus_top(
    .bif0(bus_if0.dut)		//注意有方向
  );
  
  //==============================================
  // Connect the testbench
  //==============================================
  test U_test(
    .tbf0(bus_if0.tb)
  );
  
endmodule





//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Testbench top level program
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
program test(bus_interface tbf0);
  
  
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Driver class
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  class driver;
    //virtual bus_interface.tb ports;
 
    //==============================================
    // Constructor
    //==============================================
    /*
    function new(virtual bus_interface.tb ports);
       this.ports = ports;
    endfunction
    */
    
    //==============================================
    // Test vector generation
    //==============================================
    task run_t();
      integer i = 0;
      for (i= 0; i < 8; i ++) begin       
        $display("i: %0d",i);
         #1 //tbf0.tb_bus = i+1;  
        	tbf0.bus_if_wr (i+1);
      end

    endtask
  endclass
  
  
  //==============================================
  // Initial block to start the testbench
  //==============================================
  initial begin
    driver   tb_driver0  = new();

   fork
      begin
        tb_driver0.run_t();
      end

     join
     $finish;
  end
 
  
endprogram 
