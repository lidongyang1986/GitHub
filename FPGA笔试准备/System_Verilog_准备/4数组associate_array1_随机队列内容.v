https://www.edaplayground.com/x/5MSe

program ldy;
  
  initial begin
    
    int index[], out;   
  	int q[$] = {1,2,3,4}; 
    
    $display("queue_size = %d",q.size());
    index=new[q.size()];
  
    foreach(index[i]) begin
		index[i] = i; 
        $display("index = %d",index[i]);
    end
    
  index.shuffle(); //or index[i] = $urandom_range (1,4);
    
    foreach(q[i])begin
      out = q[index[i]];
      $display("out = %d",out);
    end

  end
  
endprogram
