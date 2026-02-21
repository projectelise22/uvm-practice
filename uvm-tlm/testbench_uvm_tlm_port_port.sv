// Port to Port to Imp

`include "uvm_macros.svh"
import uvm_pkg::*;

class subprod extends uvm_component;
  `uvm_component_utils(subprod);

  int data = 20;

  uvm_blocking_put_port#(int) sub_port;

  function new(string path="subprod", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sub_port = new("sub_port", this);
  endfunction

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    sub_port.put(data);
    `uvm_info("subprod", $sformatf("Data sent: %0d", data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class prod extends uvm_component;
  `uvm_component_utils(prod);

  subprod s;

  uvm_blocking_put_port#(int) port;

  function new(string path="prod", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
    s = subprod::type_id::create("s", this);
  endfunction

  // Connect subprod port to prod port
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    s.sub_port.connect(port);
  endfunction
endclass

class cons extends uvm_component;
  `uvm_component_utils(cons);

  // declare put imp class
  uvm_blocking_put_imp#(int, cons) imp;

  function new(string path="cons", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  function void put(int data_r);
    `uvm_info("cons", $sformatf("Data received: %0d", data_r), UVM_NONE);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env);

  prod p;
  cons c;

  function new(string path="env", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = prod::type_id::create("p", this);
    c = cons::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect port and imp 
    p.port.connect(c.imp);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test);

  env e;

  function new(string path="test", uvm_component parent=null);
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

// Output Logs
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_root.svh(583) @ 0: reporter [UVMTOP] UVM testbench topology:
// # KERNEL: ----------------------------------------------------
// # KERNEL: Name              Type                   Size  Value
// # KERNEL: ----------------------------------------------------
// # KERNEL: uvm_test_top      test                   -     @335 
// # KERNEL:   e               env                    -     @348 
// # KERNEL:     c             cons                   -     @366 
// # KERNEL:       imp         uvm_blocking_put_imp   -     @375 
// # KERNEL:     p             prod                   -     @357 
// # KERNEL:       port        uvm_blocking_put_port  -     @385 
// # KERNEL:       s           subprod                -     @395 
// # KERNEL:         sub_port  uvm_blocking_put_port  -     @404 
// # KERNEL: ----------------------------------------------------
// # KERNEL: 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(67) @ 0: uvm_test_top.e.c [cons] Data received: 20
// # KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 0: uvm_test_top.e.p.s [subprod] Data sent: 20