`include "uvm_macros.svh"
import uvm_pkg::*;

class first extends uvm_object;
    rand bit[3:0] data;
    
    function new(string path="first");
        super.new(path);
    endfunction
    
    `uvm_object_utils_begin(first)
    `uvm_field_int(data, UVM_DEFAULT);
    `uvm_object_utils_end
endclass

class second extends uvm_object;
    first f;
    
    function new(string path="second");
        super.new(path);
        f = new("first");
    endfunction
    
    `uvm_object_utils_begin(second)
    `uvm_field_object(f, UVM_DEFAULT);
    `uvm_object_utils_end
endclass

module testbench;
    second s1, s2, s3;
    
    initial begin
        s1 = new("s1");
        s2 = new("s2");
        
        // copy implements deep copy
        s1.f.randomize();
        s2.copy(s1);
        s1.print();
        s2.print();
        
        // only s2 data will change since it
        // has a different handle from s1 when copied
        s2.f.data = 12;
        s1.print();
        s2.print();
        
        // clone also implements deep copy
        $cast(s3, s1.clone());
        s1.print();
        s3.print();
        
        // only s3 data will change since it
        // has a different handle from s1 when copied
        s3.f.data = 15;
        s1.print();
        s3.print();
    end
endmodule

// Output Logs
// -------------------------------
// Name      Type      Size  Value
// -------------------------------
// s1        second    -     @334 
//   f       first     -     @335 
//     data  integral  4     'hd  
// -------------------------------
// -------------------------------
// Name      Type      Size  Value
// -------------------------------
// s2        second    -     @336 
//   f       first     -     @338 
//     data  integral  4     'hd  
// -------------------------------
// -------------------------------
// Name      Type      Size  Value
// -------------------------------
// s1        second    -     @334 
//   f       first     -     @335 
//     data  integral  4     'hd  
// -------------------------------
// -------------------------------
// Name      Type      Size  Value
// -------------------------------
// s2        second    -     @336 
//   f       first     -     @338 
//     data  integral  4     'hc  
// -------------------------------
// -------------------------------
// Name      Type      Size  Value
// -------------------------------
// s1        second    -     @334 
//   f       first     -     @335 
//     data  integral  4     'hd  
// -------------------------------
// -------------------------------
// Name      Type      Size  Value
// -------------------------------
// s1        second    -     @339 
//   f       first     -     @341 
//     data  integral  4     'hd  
// -------------------------------
// -------------------------------
// Name      Type      Size  Value
// -------------------------------
// s1        second    -     @334 
//   f       first     -     @335 
//     data  integral  4     'hd  
// -------------------------------
// -------------------------------
// Name      Type      Size  Value
// -------------------------------
// s1        second    -     @339 
//   f       first     -     @341 
//     data  integral  4     'hf  
// -------------------------------