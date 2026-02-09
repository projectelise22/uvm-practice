`include "uvm_macros.svh"
import uvm_pkg::*;

class a extends uvm_component;
  `uvm_component_utils(a);

  function new(string path="a", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("a", "Build phase message from a", UVM_NONE);
  endfunction
endclass

class b extends uvm_component;
  `uvm_component_utils(b);

  function new(string path="b", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("b", "Build phase message from b", UVM_NONE);
  endfunction
endclass

class c extends uvm_component;
  `uvm_component_utils(c);

  a i_a;
  b i_b;

  function new(string path="c", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    i_a = a::type_id::create("i_a", this);
    i_b = b::type_id::create("i_b", this);
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass

module tb;
  // a and b are child of c and c is a child of uvm_top
  initial begin
    run_test("c");
  end
endmodule

// Output Log
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test c...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(13) @ 0: uvm_test_top.i_a [a] Build phase message from a
// # KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 0: uvm_test_top.i_b [b] Build phase message from b
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_root.svh(583) @ 0: reporter [UVMTOP] UVM testbench topology:
// # KERNEL: -------------------------------
// # KERNEL: Name          Type  Size  Value
// # KERNEL: -------------------------------
// # KERNEL: uvm_test_top  c     -     @335 
// # KERNEL:   i_a         a     -     @348 
// # KERNEL:   i_b         b     -     @357 
// # KERNEL: -------------------------------