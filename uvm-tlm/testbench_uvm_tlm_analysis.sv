// Broadcast data to multiple consumers using analysis
`include "uvm_macros.svh"
import uvm_pkg::*;

class prod extends uvm_component;
  `uvm_component_utils(prod);

  int data = 20;

  uvm_analysis_port#(int) port;

  function new(string path="prod", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    port.write(data);
    `uvm_info("prod", $sformatf("Data broadcasted: %0d", data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class cons_1 extends uvm_component;
  `uvm_component_utils(cons_1);

  uvm_analysis_imp#(int, cons_1) imp;

  function new(string path="cons_1", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual function void write(int data_r);
    `uvm_info("cons_1", $sformatf("Data received: %0d", data_r), UVM_NONE);
  endfunction
endclass

class cons_2 extends uvm_component;
  `uvm_component_utils(cons_2);

  uvm_analysis_imp#(int, cons_2) imp;

  function new(string path="cons_2", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual function void write(int data_r);
    `uvm_info("cons_2", $sformatf("Data received: %0d", data_r), UVM_NONE);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env);

  prod p;
  cons_1 c1;
  cons_2 c2;

  function new(string path="env", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = prod::type_id::create("p", this);
    c1 = cons_1::type_id::create("c1", this);
    c2 = cons_2::type_id::create("c2", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    p.port.connect(c1.imp);
    p.port.connect(c2.imp);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test);

  env e;

  function new(string path="test", uvm_component parent= null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass

module tb;
  initial run_test("test");
endmodule

// Output Log
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_root.svh(583) @ 0: reporter [UVMTOP] UVM testbench topology:
// # KERNEL: --------------------------------------------
// # KERNEL: Name          Type               Size  Value
// # KERNEL: --------------------------------------------
// # KERNEL: uvm_test_top  test               -     @335 
// # KERNEL:   e           env                -     @348 
// # KERNEL:     c1        cons_1             -     @366 
// # KERNEL:       imp     uvm_analysis_imp   -     @384 
// # KERNEL:     c2        cons_2             -     @375 
// # KERNEL:       imp     uvm_analysis_imp   -     @394 
// # KERNEL:     p         prod               -     @357 
// # KERNEL:       port    uvm_analysis_port  -     @404 
// # KERNEL: --------------------------------------------
// # KERNEL: 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(44) @ 0: uvm_test_top.e.c1 [cons_1] Data received: 20
// # KERNEL: UVM_INFO /home/runner/testbench.sv(63) @ 0: uvm_test_top.e.c2 [cons_2] Data received: 20
// # KERNEL: UVM_INFO /home/runner/testbench.sv(24) @ 0: uvm_test_top.e.p [prod] Data broadcasted: 20
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 