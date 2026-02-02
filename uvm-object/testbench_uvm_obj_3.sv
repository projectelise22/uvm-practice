`include "uvm_macros.svh"
import uvm_pkg::*;

class parent extends uvm_object;

    function new(string path="parent");
        super.new(path);
    endfunction

    rand bit[3:0] data;

    `uvm_object_utils_begin(parent)
        `uvm_field_int(data, UVM_DEFAULT);
    `uvm_object_utils_end
endclass

class child extends uvm_object;
    parent p;

    function new(string path = "child");
        super.new(path);
        p = new("parent");
    endfunction

    `uvm_object_utils_begin(child)
        `uvm_field_object(p, UVM_DEFAULT);
    `uvm_object_utils_end
endclass

module tb;
    child c;

    initial begin
      c = new("child");
      // need to randomize parent field since the rand data is declared in this class
      // if only c.randomize(), it will take effect only on child's fields
      c.p.randomize();
      c.print();
    end
endmodule
