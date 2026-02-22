// Producer port to Consumer export to Subconsumer imp
`include "uvm_macros.svh"
import uvm_pkg::*;

class prod extends uvm_component;
  `uvm_component_utils(prod);

  int data = 30;

  uvm_blocking_put_port#(int) send;

  function new(string path="prod", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send = new("send", this);
  endfunction

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    send.put(data);
    `uvm_info("prod", $sformatf("Data sent: %0d", data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class subcons extends uvm_component;
  `uvm_component_utils(subcons);

  uvm_blocking_put_imp#(int, subcons) receive;

  function new(string path="subcons", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    receive = new("receive", this);
  endfunction

  task put (int data_r);
    `uvm_info("subcons", $sformatf("Data received: %0d", data_r), UVM_NONE);
  endtask
endclass

class cons extends uvm_component;
  `uvm_component_utils(cons);

  subcons s;
  uvm_blocking_put_export#(int) pass;

  function new(string path="cons", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    pass = new("pass", this);
    s = subcons::type_id::create("s", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    pass.connect(s.receive);
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
    p.send.connect(c.pass);
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
// # KERNEL: -----------------------------------------------------
// # KERNEL: Name             Type                     Size  Value
// # KERNEL: -----------------------------------------------------
// # KERNEL: uvm_test_top     test                     -     @335 
// # KERNEL:   e              env                      -     @348 
// # KERNEL:     c            cons                     -     @366 
// # KERNEL:       pass       uvm_blocking_put_export  -     @375 
// # KERNEL:       s          subcons                  -     @385 
// # KERNEL:         receive  uvm_blocking_put_imp     -     @394 
// # KERNEL:     p            prod                     -     @357 
// # KERNEL:       send       uvm_blocking_put_port    -     @404 
// # KERNEL: -----------------------------------------------------
// # KERNEL: 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(44) @ 0: uvm_test_top.e.c.s [subcons] Data received: 30
// # KERNEL: UVM_INFO /home/runner/testbench.sv(24) @ 0: uvm_test_top.e.p [prod] Data sent: 30
