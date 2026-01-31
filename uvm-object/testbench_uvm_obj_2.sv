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
  rand bit [3:0] a, b;
  
  // other data types
  typedef enum bit[1:0] {s0, s1, s2, s3} t_state;
  rand t_state state;

  real r_temp = 1.21;
  string s_temp = "UVM";

  // mandatory to declare the fields inside in order to use automation methods
  `uvm_object_utils_begin(obj)
      `uvm_field_int(a, UVM_DEFAULT | UVM_BIN);
      `uvm_field_int(b, UVM_DEFAULT | UVM_DEC);
      `uvm_field_enum(t_state, state, UVM_DEFAULT);
      `uvm_field_real(r_temp, UVM_DEFAULT);
      `uvm_field_string(s_temp, "UVM");
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
    // object.print(uvm_default_tree_printer);
    // object.print(uvm_default_line_printer);
  end
endmodule

// Output Log: will display table format by default
// # KERNEL: ---------------------------
// # KERNEL: Name  Type      Size  Value
// # KERNEL: ---------------------------
// # KERNEL: OBJ   obj       -     @335 
// # KERNEL:   a   integral  4     'h6  
// # KERNEL: ---------------------------

// Output Log including other data types
// # KERNEL: ----------------------------------
// # KERNEL: Name      Type      Size  Value   
// # KERNEL: ----------------------------------
// # KERNEL: OBJ       obj       -     @335    
// # KERNEL:   a       integral  4     'b110   
// # KERNEL:   b       integral  4     'd5     
// # KERNEL:   state   t_state   2     s3      
// # KERNEL:   r_temp  real      64    1.210000
// # KERNEL:   s_temp  string    3     UVM     
// # KERNEL: ----------------------------------