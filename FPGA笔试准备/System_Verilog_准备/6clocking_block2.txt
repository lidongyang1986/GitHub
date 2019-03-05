https://www.edaplayground.com/x/3nhk

//----------------------------------------------------------------------
//  Copyright (c) 2018 by Doulos Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//----------------------------------------------------------------------

module GRG_CB;

bit Clk, Enable, Load, UpDn, Running;
logic [3:0] Data, Int_Data, Q;

clocking CB1 @(negedge Clk);
  default input #1ns output #2ns;
  input Q;
  output Enable, Data;
//  output #1step UpDn = GRG_CB.U1.UpDn;
  output #1step UpDn;
  output posedge Load;
endclocking

assign Int_Data = Data;

default clocking CB1; // Clocking block CB1 set as default 

initial begin
// Clocking Block Drives
  CB1.Load <= 0;              // Time 0
  CB1.Data <= 0;
  CB1.Enable <= 1;
  CB1.UpDn <= 1;
  ##2 CB1.Load <= 1;
  CB1.Data[2:0] <= 3'h3;  // Drive 3-bit slice of Q in current cycle
  ##1 CB1.Enable <= 0;       
  CB1.UpDn <= 0;
  CB1.Load <= 0;
  ##1 CB1.Data <= 4'hz;   // Wait 1 Clk cycle and then drive Q
  ##1 CB1.Enable <= 1;
  ##4 CB1.Data[3] <= 1'b0;  // Wait 4 Clk cycles, then drive bit 3 of Q
  CB1.Data[2:0] <= 3'b101;
  CB1.Load <= 1;
  CB1.Data <= ##2 Int_Data;  // Remember Int_Data, then drive Data after 2 clocks
  CB1.UpDn <= 1;
  ##1 Running <= 0;
end

initial begin
  Clk = 0;
  Running = 1;
  while (Running) begin
    #5 Clk = ~Clk;
  end
$display ("Finished!!");
end

counter U1 (.*);

// Dump waves
initial begin
  $dumpfile("dump.vcd");
  $dumpvars(1, GRG_CB.U1);
end

endmodule
