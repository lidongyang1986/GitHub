https://www.edaplayground.com/x/3B3b


`timescale 1ns/1ns
// program declaration with ports.
program clocking_skew_prg (
  input  wire        clk,
  output logic [7:0] din,
  input  wire  [7:0] dout,
  output logic [7:0] addr,
  output logic       ce,
  output logic       we
);
 
  // Clocking block 
  clocking ram @(posedge clk);
     input  #5 dout;
     output #3 din,addr,ce,we;
  endclocking

  initial begin
    // Init the outputs
    ram.addr <= 0;
    ram.din <= 0;
    ram.ce <= 0;
    ram.we <= 0;
    // Write Operation to Ram
    for (int i = 0; i < 2; i++) begin
      @ (posedge clk);
      ram.addr <= i;
      ram.din <= $random;
      ram.ce <= 1;
      ram.we <= 1;
      @ (posedge clk);
      ram.ce <= 0;
    end
    // Read Operation to Ram
    for (int i = 0; i < 2; i++) begin
      @ (posedge clk);
      ram.addr <= i;
      ram.ce <= 1;
      ram.we <= 0;
      // Below line is same as  @ (posedge clk);
      @ (ram); 
      ram.ce <= 0;
    end
    #40 $finish;
  end

endprogram







// Simple top level file
module clocking_skew();

logic        clk = 0;
wire   [7:0] din;
logic  [7:0] dout;
wire   [7:0] addr;
wire         ce;
wire         we;
reg    [7:0] memory [0:255];

// Clock generator
always #10 clk++;

// Simple ram model
always @ (posedge clk)
 if (ce)
   if (we)
     memory[addr] <= din;
   else
     dout <= memory[addr];

// Monitor all the signals
initial begin
 $monitor("@%0dns addr :%0x din %0x dout %0x we %0x ce %0x",
           $time, addr, din,dout,we,ce);
end
// Connect the program
clocking_skew_prg U_program(
 .clk   (clk),
 .din   (din),
 .dout  (dout),
 .addr  (addr),
 .ce    (ce),
 .we    (we)
);

  
  initial begin
     $dumpfile ("clocking_skew.vcd");
     $dumpvars (0,clocking_skew);
  end   
  
endmodule
