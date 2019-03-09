program main; 
bit [0:2] y; 
bit [0:2] values[$]= '{3,5,6}; 

covergroup cg; 
cover_point_y : coverpoint y; 
endgroup 

cg cg_inst = new(); 

initial 
foreach(values[i]) 
begin 
y = values[i]; 
cg_inst.sample(); 
end 

endprogram 
