https://www.edaplayground.com/x/49aD

class parent;
	int a, b;
	virtual task display_c();
		$display("Parent");
	endtask
endclass

class child extends parent;
	int a;
	task display_c();
		$display("Child");
	endtask
endclass

program ldy;
initial begin
	parent p;
	child c;
	c = new();
	p = c;
	c.display_c();   //result: Child        Child
	p.display_c();   //result:Parent       Child
end

endprogram




///////////////////////////////////////////////
inheriante_virtual_class：
      b = new;
      a = b;      
打印出来的和b一样因为b是new出来的。
			a = new;		//反向是错的，父类不能强行赋值给子类
      b = a;
      a.print();	//没有new直接打印也不行
      b.print();
