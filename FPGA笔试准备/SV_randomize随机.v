https://www.edaplayground.com/x/2VFM

program randomize_with;
  class frame_t;
    rand bit [7:0] src_addr;
    rand bit [7:0] dst_addr;
    constraint c {
      src_addr <=  127;
      dst_addr >=  128;
    }
    task print();
      begin 
        $write("Source      address %2x\n",src_addr);
        $write("Destination address %2x\n",dst_addr);
      end
    endtask  
  endclass


  initial begin
    frame_t frame = new();
    integer i = 0;
    $write("-------------------------------\n");
    $write("Randomize Value\n");
    i = frame.randomize();
    frame.print();
    $write("-------------------------------\n");
    $write("Randomize with Value\n");
    i = frame.randomize() with {
      src_addr > 100;
      dst_addr < 130;
      dst_addr > 128;
    };
    frame.print();
    $write("-------------------------------\n");
  end
endprogram
