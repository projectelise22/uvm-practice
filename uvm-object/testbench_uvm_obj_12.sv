`include "uvm_macros.svh"
import uvm_pkg::*;

class obj1 extends uvm_object;
  // no need to register fields, just class
  `uvm_object_utils(obj1)
  
  function new(string path="obj1");
    super.new(path);
  endfunction
  
  // fields
  bit [3:0] a = 5;
  string    b = "UVM";
  real      c = 12.34;
  
  // do_* methods should be declared exactly as they are from the library
  // check it under uvm_object.svh file
  // check how to print based on data type
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    
    // .print_field -> until 4096 bits, print_field_int -> until 64 bits
    // args; "<name to console>", source, $bits(name), radix
    // $bits -> function to check the # of bits
    printer.print_field_int("a", a, $bits(a), UVM_HEX);
    // args: "<name to console>", source
    printer.print_string("b", b);
    printer.print_real("c", c);
  endfunction
endclass

class obj2 extends uvm_object;
  // no need to register fields, just class
  `uvm_object_utils(obj2)
  
  function new(string path="obj2");
    super.new(path);
  endfunction
  
  // fields
  bit [3:0] a = 5;
  string    b = "UVM";
  real      c = 12.34;
  
  // displays in console in one line
  // does not need uvm_printer component
  virtual function string convert2string();
    string s = super.convert2string();
    
    s = {s, $sformatf("a: %0d ", a)};
    s = {s, $sformatf("b: %0s ", b)};
    s = {s, $sformatf("c: %0f ", c)};
    
    return s;
  endfunction
endclass

module tb;
  obj1 o1;
  obj2 o2;
  
  initial begin
    o1 = obj1::type_id::create("o1");
    o2 = obj2::type_id::create("o2");
    
    o1.print(); // same way as calling in field method
    // $display("%0s", o2.convert2string());
    `uvm_info("tb_top", $sformatf("%0s", o2.convert2string), UVM_NONE);
  end
endmodule