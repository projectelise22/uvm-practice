// PORT PUT TO EXPORT TO IMP PUT 
`include "uvm_macros.svh"
import uvm_pkg::*;

class producer extends uvm_component;
  `uvm_component_utils(producer);

  // data to send
  int data = 12;

  // declare put port class
  uvm_blocking_put_port#(int) send;

  function new(string path="producer", uvm_component parent=null);
    super.new(path, parent);
    send = new("send", this);
  endfunction

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    send.put(data);
    `uvm_info("producer", $sformatf("Data sent: %0d", data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class consumer extends uvm_component;
  `uvm_component_utils(consumer);

  // declare put export class
  uvm_blocking_put_export#(int) receive;
  uvm_blocking_put_imp#(int, consumer) imp;

  function new(string path="consumer", uvm_component parent=null);
    super.new(path, parent);
    receive = new("receive", this);
    imp = new("imp", this);
  endfunction

  // Actual method used, since imp is declared in consumer as endpoint
  // consumer must have the actual put method.
  // When producer calls put.port(data), uvm routes it to consumer.put(data)
  // because imp binds the TLM call to this function
  task put(int data_r);
    `uvm_info("consumer", $sformatf("Data received: %0d", data_r), UVM_NONE);
  endtask
endclass

class env extends uvm_env;
  `uvm_component_utils(env);

  producer p;
  consumer c;

  function new(string path="env", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer::type_id::create("p", this);
    c = consumer::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect port and export
    // connect export and imp 
    p.send.connect(c.receive);
    c.receive.connect(c.imp);
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
endclass

module tb;
  initial run_test("test");
endmodule

// Not using imp shows the following log
// # KERNEL: UVM_ERROR @ 0: uvm_test_top.e.c.receive [Connection Error] connection count of 0 does not meet required minimum of 1
// # KERNEL: UVM_ERROR @ 0: uvm_test_top.e.p.send [Connection Error] connection count of 0 does not meet required minimum of 1

// Output Logs with imp
// - added imp class
// - added connection from export to imp
// - added send.put to send data in producer class
// - added actual put implementation in consumer class
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(44) @ 0: uvm_test_top.e.c [consumer] Data received: 12
// # KERNEL: UVM_INFO /home/runner/testbench.sv(21) @ 0: uvm_test_top.e.p [producer] Data sent: 12