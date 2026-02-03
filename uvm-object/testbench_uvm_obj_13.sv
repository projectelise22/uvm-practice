`include "uvm_macros.svh"
import uvm_pkg::*;

class obj extends uvm_object;
  // class factory registration
  `uvm_object_utils(obj);
  
  // constructor
  function new(string path="obj");
    super.new(path);
  endfunction
  
  // fields
  rand bit[3:0] a;
  rand bit[4:0] b;
  
  // do_print method
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    
    printer.print_field_int("a", a, $bits(a), UVM_DEC);
    printer.print_field_int("b", b, $bits(b), UVM_DEC);
  endfunction
  
  // do_copy method
  function void do_copy(uvm_object rhs);
    obj temp;
    
    // makes sure that rhs is the same type as temp for proper copy
    // temp points to same handle as rhs
    $cast(temp, rhs); 
    super.do_copy(rhs); 
    
    // Update the data of this class
    this.a = temp.a;
    this.b = temp.b;
  endfunction
  
  // do_compare method
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    obj temp;
    int status;
    
    $cast(temp, rhs);
    status = super.do_compare(rhs, comparer) && (a == temp.a) && (b == temp.b);
    
    return status;
  endfunction
endclass

module tb;
  obj o1, o2, o3;
  int status;
  
  initial begin
    o1 = obj::type_id::create("o1");
    o2 = obj::type_id::create("o2");
    o3 = obj::type_id::create("o3");
    
    o1.randomize();
    o2.randomize();
    o1.print();
    o2.print();
    status = o2.compare(o1);
    `uvm_info("tb_top", $sformatf("Status value: %0d", status), UVM_NONE);
    
    o3.copy(o1);
    o3.print();
    status = o3.compare(o1);
    `uvm_info("tb_top", $sformatf("Status value: %0d", status), UVM_NONE);
  end
endmodule

// Output Log
// # KERNEL: ---------------------------
// # KERNEL: Name  Type      Size  Value
// # KERNEL: ---------------------------
// # KERNEL: o1    obj       -     @335 
// # KERNEL:   a   integral  4     'd6  
// # KERNEL:   b   integral  5     'd5  
// # KERNEL: ---------------------------
// # KERNEL: ---------------------------
// # KERNEL: Name  Type      Size  Value
// # KERNEL: ---------------------------
// # KERNEL: o2    obj       -     @336 
// # KERNEL:   a   integral  4     'd2  
// # KERNEL:   b   integral  5     'd0  
// # KERNEL: ---------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(65) @ 0: reporter [tb_top] Status value: 0
// # KERNEL: ---------------------------
// # KERNEL: Name  Type      Size  Value
// # KERNEL: ---------------------------
// # KERNEL: o3    obj       -     @337 
// # KERNEL:   a   integral  4     'd6  
// # KERNEL:   b   integral  5     'd5  
// # KERNEL: ---------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(70) @ 0: reporter [tb_top] Status value: 1