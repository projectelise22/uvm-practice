`include "uvm_macros.svh"
import uvm_pkg::*;

class obj extends uvm_object;
  // register the class
  `uvm_object_utils(obj);
  
  // create construct
  // only needs 1 argument
  function new(string path="OBJ");
    super.new(path);
  endfunction
  
  //pseudorandom generation by user
  rand bit [3:0] a;
endclass

module tb;
  obj object;
  
  initial begin
    object = new();
    object.randomize();
    `uvm_info("TB_TOP", $sformatf("Random value from object: %0d", object.a), UVM_NONE);
  end
endmodule