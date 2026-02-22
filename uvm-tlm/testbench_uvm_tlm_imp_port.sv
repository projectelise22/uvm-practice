`include "uvm_macros.svh"
import uvm_pkg::*;

class prod extends uvm_component;
  `uvm_component_utils(prod);

  int data=0;

  uvm_blocking_get_port#(int) receive;

  function new(string path="prod", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    receive = new("receive", this);
  endfunction

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    receive.get(data);
    `uvm_info("prod", $sformatf("Data received: %0d",data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class cons extends uvm_component;
  `uvm_component_utils(cons);

  int data = 40;

  uvm_blocking_get_imp#(int, cons) respond;

  function new(string path="cons", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    respond = new("respond", this);
  endfunction

  virtual task get(output int data_r);
    `uvm_info("cons", $sformatf("Data response: %0d", data), UVM_NONE);
    data_r = data;
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
    p.receive.connect(c.respond);
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
// # KERNEL: -------------------------------------------------
// # KERNEL: Name           Type                   Size  Value
// # KERNEL: -------------------------------------------------
// # KERNEL: uvm_test_top   test                   -     @335 
// # KERNEL:   e            env                    -     @348 
// # KERNEL:     c          cons                   -     @366 
// # KERNEL:       respond  uvm_blocking_get_imp   -     @375 
// # KERNEL:     p          prod                   -     @357 
// # KERNEL:       receive  uvm_blocking_get_port  -     @385 
// # KERNEL: -------------------------------------------------
// # KERNEL: 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(45) @ 0: uvm_test_top.e.c [cons] Data response: 40
// # KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 0: uvm_test_top.e.p [prod] Data received: 40