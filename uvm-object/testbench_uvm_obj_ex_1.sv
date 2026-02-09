`include "uvm_macros.svh"
import uvm_pkg::*;

class my_object extends uvm_object;
  // fields
  rand logic [1:0] a;
  rand logic [3:0] b;
  rand logic [7:0] c;

  // constructor
  function new(string path = "my_object");
    super.new(path);
  endfunction

  // register to factory
  `uvm_object_utils_begin(my_object)
    `uvm_field_int(a, UVM_DEC);
    `uvm_field_int(b, UVM_DEC);
    `uvm_field_int(c, UVM_DEC);
  `uvm_object_utils_end

  task run();
    this.randomize();
    this.print();
  endtask
endclass

module tb;
  my_object obj1, obj2, obj3;
  int status;
  
  initial begin
    obj1 = my_object::type_id::create("obj1");
    obj2 = my_object::type_id::create("obj2");
    obj3 = my_object::type_id::create("obj3");
    
    // Compare fail
    obj1.run();
    obj2.run();
    status = obj1.compare(obj2);
    `uvm_info("tb_top", $sformatf("Status: %0d", status), UVM_NONE);
    
    // Compare pass
    obj3.copy(obj1);
    obj3.print();
    status = obj1.compare(obj3);
    `uvm_info("tb_top", $sformatf("Status: %0d", status), UVM_NONE);
  end
endmodule