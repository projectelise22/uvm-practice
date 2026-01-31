`include "uvm_macros.svh"
import uvm_pkg::*;

class obj extends uvm_object;
  // register the class
  // commenting this since we will declare 
  // multiple fields by using begin .. end
  // `uvm_object_utils(obj);
  
  // create construct
  // only needs 1 argument
  function new(string path="OBJ");
    super.new(path);
  endfunction
  
  // pseudorandom generation, register to uvm
  // depending on field macro
  // `uvm_field_*(field, flag)
  rand bit [3:0] a;

  // mandatory to declare the fields inside in order to use automation methods
  `uvm_object_utils_begin(obj)
      `uvm_field_int(a, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

module tb;
  obj object;
  
  initial begin
    object = new();
    object.randomize();
    // The following is not needed, you can already use automation method(print)
    // since field is registered via field macro:
    // `uvm_info("TB_TOP", $sformatf("Random value from object: %0d", object.a), UVM_NONE);
    object.print();
  end
endmodule

// Output Log: will display table format
// # KERNEL: ---------------------------
// # KERNEL: Name  Type      Size  Value
// # KERNEL: ---------------------------
// # KERNEL: OBJ   obj       -     @335 
// # KERNEL:   a   integral  4     'h6  
// # KERNEL: ---------------------------