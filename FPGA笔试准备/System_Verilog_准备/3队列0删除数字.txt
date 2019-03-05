https://www.edaplayground.com/x/uX6


class widget;
  int id;
  bit to_remove;
endclass : widget

module top;
  widget q[$];

  integer queue[$] = { 5, 6, 7, 8, 9 };
  
  
  bit [0:2] value[$]='{3,5,6};
  
  
  initial begin
    widget w;
    int num = $urandom_range(20,40);
    for (int i = 0; i < num; i++) begin
      w = new;
      w.id = i;
      w.to_remove = $urandom_range(0,1);
      q.push_back(w);
      $display("widget id:%02d, to_remove:%b", q[$].id, q[$].to_remove);
    end
  
    // write SV code to remove entries in q[$] that have to_remove==1
    
    queue.delete(0);     
    queue.delete(0);   
    queue.delete(0);

    
	for (int i=0; i < queue.size(); i++)
      $display("queue item = %d", queue[i]);
  
    
    /*
    q.delete(2);
    q.delete(4);
    q.delete(5);
    q.delete(7);
    q.delete(9);
    */
      
    for (int i=0; i < q.size(); i++)
      	if (q[i].to_remove) begin
          $display("widget id:%d is removed", q[i].id);
          q.delete(i);
        end
    

  
    // write SV code to check that no entry in q[$] has to_remove==1
    for (int i=0; i < q.size(); i++)
    if (!q[i].to_remove) $display("widget id:%d is ok", q[i].id);
    else                 $display("ERROR: widget id:%d not removed", q[i].id);
     
      
  end
endmodule
