// Send and receive data to and from consumer
`include "uvm_macros.svh"
import uvm_pkg::*;

class prod extends uvm_component;
  `uvm_component_utils(prod);

  int data_s = 5;
  int data_r = 0;

  // args are datatypes of data sent, and data received
  uvm_blocking_transport_port#(int, int) port;

  function new(string path="prod", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    port.transport(data_s, data_r);
    `uvm_info("prod", $sformatf("Data sent: %0d", data_s), UVM_NONE);
    `uvm_info("prod", $sformatf("Data received: %0d", data_r), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class cons extends uvm_component;
  `uvm_component_utils(cons);

  int data_s = 10;
  int data_r = 0;

  // args are datatypes of data sent, data received, endpoint of implementation
  uvm_blocking_transport_imp#(int, int, cons) imp;

  function new(string path="prod", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual task transport(input int data_r, output int data_s);
    data_s = this.data_s;
    `uvm_info("cons", $sformatf("Data sent: %0d", data_s), UVM_NONE);
    `uvm_info("cons", $sformatf("Data received: %0d", data_r), UVM_NONE);
  endtask
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
    p.port.connect(c.imp);
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

// Output Logs
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_root.svh(583) @ 0: reporter [UVMTOP] UVM testbench topology:
// # KERNEL: ------------------------------------------------------
// # KERNEL: Name          Type                         Size  Value
// # KERNEL: ------------------------------------------------------
// # KERNEL: uvm_test_top  test                         -     @335 
// # KERNEL:   e           env                          -     @348 
// # KERNEL:     c         cons                         -     @366 
// # KERNEL:       imp     uvm_blocking_transport_imp   -     @375 
// # KERNEL:     p         prod                         -     @357 
// # KERNEL:       port    uvm_blocking_transport_port  -     @385 
// # KERNEL: ------------------------------------------------------
// # KERNEL: 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 0: uvm_test_top.e.c [cons] Data sent: 10
// # KERNEL: UVM_INFO /home/runner/testbench.sv(53) @ 0: uvm_test_top.e.c [cons] Data received: 5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 0: uvm_test_top.e.p [prod] Data sent: 5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(27) @ 0: uvm_test_top.e.p [prod] Data received: 10