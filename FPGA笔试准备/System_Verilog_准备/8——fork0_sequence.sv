https://www.edaplayground.com/x/6KHy

// Interview Question
// Fill in the code below

class my_sequencer;
  int id;
endclass : my_sequencer

class my_sequence;
  task start (my_sequencer seqr);
    int delay = $urandom_range(1,10);
    $display("time: %d, starting sequence on sequencer with id:%d", $time, seqr.id);
    #(delay * 1us);
    $display("time: %d, finishing sequence on sequencer with id:%d", $time, seqr.id);
  endtask : start
endclass : my_sequence


module top;
  initial begin
    my_sequencer seqr;
    my_sequencer seqr_q[$];
    
    my_sequence seq1,seq2; 
    my_sequence seq; 
    my_sequence seqn[$];

    
    static int num_of_seqr = $urandom_range(3,5);
    
    for (int i = 0; i < num_of_seqr; i++) begin
      seqr = new;
      seqr.id = i;
      seqr_q.push_back(seqr);
    end
    
    // write SV code to start a new instance of my_sequence on each of the sequencers in seqr_q
    // conditions:
    // 1) all sequences must start simultaneously (at time 0)
    // 2) code must wait until all sequences are finished before reaching "end" of initial block
    

    /*
	foreach(seqr_q[i]) begin
      automatic int vi = i;
      $display("%d", i);
         fork begin
            seq = new;
           seq.start(seqr_q[vi]);
         end
        join_none
    end
*/
    
    ////////lidongyang solutions1: ////////////////
    /*
        seq1 = new; 
    	seq2 = new;
    
        fork 
           seq1.start(seqr_q[0]);
           seq2.start(seqr_q[1]);
        join
    */

    ////////lidongyang solutions2: ////////////////
    /*
    foreach(seqr_q[i]) begin
      automatic int vi = i;
      seqn[i]=new;
    end
    
    
        fork 
            seqn[0].start(seqr_q[0]);
            seqn[1].start(seqr_q[1]);  
        join 
    */
    
    ////////lidongyang solutions3: ////////////////
    foreach(seqr_q[i]) begin
      automatic int vi = i;
      seqn[i]=new;
    end
    

    foreach(seqr_q[i]) begin
      	automatic int vi = i;
        fork 
          seqn[vi].start(seqr_q[vi]);
        join_none
    end
  
    
    wait fork;
    
    $display("time: %d, end reached", $time);
  end
endmodule 
