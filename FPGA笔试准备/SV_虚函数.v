class class_a;
  virtual function void print();
    $display("class_a");
  endfunction : print
endclass : class_a

class class_b extends class_a;
  virtual function void print(); 
    $display("class_b");
  endfunction : print
endclass : class_b

module top;
  initial begin
    
    // 1) what gets displayed for each print(), explain why
    $display("1");
    begin
      class_a a;
      class_b b;

      a = new;
      b = new;
      a.print();
      b.print();
    end
    
    // 2) what gets displayed for each print(), explain why
    $display("2");
    begin
      class_a a;
      class_b b;

      b = new;		//子类可以new之后赋值给父类，但不可反过来
      a = b;
      a.print();
      b.print();
    end
    
    // 3) what gets displayed for each print(), explain why
    $display("3");
    begin
      class_a a;
      class_a a2;
      class_b b;
      class_b b2;
      
      b = new;
      a = b;
      a2 = a;
      $cast(b2, a);
      a2.print();
      b2.print();
    end 

    // 4) what gets displayed for each print(), explain why
    $display("4");
    begin
      class_a a;
      class_a a2;
      class_b b;
      class_b b2;
      
      //a = new;		//反向是错的，父类不能强行赋值给子类
      //b = a;
      //a.print();		//没有new直接打印也不行
      //b.print();
    end     
    
    
    
  end
endmodule 

// 4) If we remove virtual from the extended class, how does that change things?
// 5) If we remove virtual from both classes, how does that change things?
