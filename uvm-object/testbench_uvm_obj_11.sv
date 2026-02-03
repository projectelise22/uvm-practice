`include "uvm_macros.svh"
import uvm_pkg::*;

// Original class
class first extends uvm_object;
    rand bit[3:0] data;
    
    function new(string path="first");
        super.new(path);
    endfunction
    
    `uvm_object_utils_begin(first)
    `uvm_field_int(data, UVM_DEFAULT);
    `uvm_object_utils_end
endclass

// Updated class
class first_mod extends first;
    rand bit ack;
    
    function new(string path="first_mod");
        super.new(path);
    endfunction
    
    `uvm_object_utils_begin(first_mod)
    `uvm_field_int(ack, UVM_DEFAULT);
    `uvm_object_utils_end
endclass

class comp extends uvm_component;
    `uvm_component_utils(comp);
    
    first f;
    
    function new(string path="comp", 
                 uvm_component parent=null);
        super.new(path, parent);
        f = first::type_id::create("f");
        f.randomize();
        f.print();
    endfunction
endclass

module testbench;
    comp c1;
    
    initial begin
        // Use the following to use first_mod class instead
        // of updating the instantiated class in the component class
        // - the following is only accessible if class is constructed using create method and not new
        c1.set_type_override_by_type(first::get_type, first_mod::get_type);
        c1 = comp::type_id::create("c1", null);
    end
endmodule

// Output Logs
// ------------------------------
// Name    Type       Size  Value
// ------------------------------
// f       first_mod  -     @343 
//   data  integral   4     'h6  
//   ack   integral   1     'h1  
// ------------------------------