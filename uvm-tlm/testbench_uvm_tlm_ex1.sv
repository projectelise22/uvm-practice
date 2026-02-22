`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
 
  bit [3:0] a = 12;
  bit [4:0] b = 24;
  int c = 256;
  
  function new(string inst = "transaction");
    super.new(inst);
  endfunction
  
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(a, UVM_DEFAULT | UVM_DEC);
  `uvm_field_int(b, UVM_DEFAULT | UVM_DEC);
  `uvm_field_int(c, UVM_DEFAULT | UVM_DEC); 
  `uvm_object_utils_end
endclass

class compa extends uvm_component;
  `uvm_component_utils(compa);

  // data to send
  transaction tr;

  // declare put port class
  uvm_blocking_put_port#(transaction) send;

  function new(string path="compa", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = new("tr");
    send = new("send", this);
  endfunction

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    send.put(tr);
    `uvm_info("compa", "Sending data: ", UVM_NONE);
    tr.print();
    phase.drop_objection(this);
  endtask
endclass

class compb extends uvm_component;
  `uvm_component_utils(compb);

  // declare put imp class
  uvm_blocking_put_imp#(transaction, compb) imp;

  function new(string path="compb", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  function void put(transaction tr_r);
    `uvm_info("compb", "Receiving data: ", UVM_NONE);
    tr_r.print();
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env);

  compa a;
  compb b;

  function new(string path="env", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = compa::type_id::create("p", this);
    b = compb::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect port and imp 
    a.send.connect(b.imp);
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

// Output Logs
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(65) @ 0: uvm_test_top.e.c [compb] Receiving data: 
// # KERNEL: ------------------------------
// # KERNEL: Name  Type         Size  Value
// # KERNEL: ------------------------------
// # KERNEL: tr    transaction  -     @385 
// # KERNEL:   a   integral     4     12   
// # KERNEL:   b   integral     5     24   
// # KERNEL:   c   integral     32    'd256
// # KERNEL: ------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 0: uvm_test_top.e.p [compa] Sending data: 
// # KERNEL: ------------------------------
// # KERNEL: Name  Type         Size  Value
// # KERNEL: ------------------------------
// # KERNEL: tr    transaction  -     @385 
// # KERNEL:   a   integral     4     12   
// # KERNEL:   b   integral     5     24   
// # KERNEL:   c   integral     32    'd256
// # KERNEL: ------------------------------