https://www.edaplayground.com/x/4g6K

class dynamic_array; 
rand byte size; 
rand byte data[]; 
  
  constraint size_c { data.size()==12; } 
constraint arr_uniq { 
    foreach( data[ii] )
     {
       data[ii]>5 && data[ii]<11;
     }   
  }
      
endclass 


program summ; 
dynamic_array obj = new(); 
integer sum; 

initial 
begin 
sum =0; 
void'(obj.randomize()); 
  
for(int i=0;i< obj.data.size() ;i++) 
  $display(" obj %d is %d ",i,obj.data[i]); 
end 
  
endprogram 
