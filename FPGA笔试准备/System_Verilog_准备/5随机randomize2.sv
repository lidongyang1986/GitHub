https://www.edaplayground.com/x/5kSB

class Base; 
rand integer Var; 
constraint range { Var < 100 ; Var > 0 ;} 
endclass 

class Extended extends Base; 
  constraint range { Var ==550 ;} // Overrighting the Base class constraints. 
endclass 

program inhe_33; 
Extended obj_e; 
Base obj_b; 
initial 
begin 
obj_e = new(); 

for(int i=0 ; i < 7 ; i++) 
if(obj_e.randomize()) 
$display(" Randomization sucsessfull : Var = %0d ",obj_e.Var); 
else 
$display("Randomization failed"); 
end 
endprogram 
