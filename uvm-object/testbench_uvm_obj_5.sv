`include "uvm_macros.svh"
import uvm_pkg::*;

class first extends uvm_object;
  // declare fields
  rand bit[3:0] data;

  // constructor
  function new(string path = "first");
    super.new(path);
  endfunction

  // register class and fields
  `uvm_object_utils_begin(first)
    `uvm_field_int(data, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

module tb;
    first f1;
    first f2;

    initial begin
        f1 = new("f1");

        // need to construct second class to use copy()
        f2 = new("f2");

        // copy f1 to f2
        f1.randomize();
        f2.copy(f1);
        f1.print();
        f2.print();
    end
endmodule