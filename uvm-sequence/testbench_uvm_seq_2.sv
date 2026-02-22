`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
  // fields
  rand bit [3:0] a;
  rand bit [3:0] b;
       bit [4:0] y;
  
  function new(string inst="transaction");
    super.new(inst);
  endfunction

  `uvm_object_utils_begin(transaction)
    `uvm_field_int(a, UVM_DEFAULT)
    `uvm_field_int(b, UVM_DEFAULT)
    `uvm_field_int(y, UVM_DEFAULT)
  `uvm_object_utils_end
endclass

class seq_1 extends uvm_sequence#(transaction);
  `uvm_object_utils(seq_1);

  transaction tr;

  function new(string inst="seq_1");
    super.new(inst);
  endfunction

  virtual task pre_body();
    `uvm_info(get_name(), "Sequence pre-body executed.", UVM_NONE);
  endtask

  virtual task body();
    `uvm_info(get_name(), "Sequence started, creating an item.", UVM_NONE);
    tr = transaction::type_id::create("tr");
    `uvm_info(get_name(), "Waiting grant from driver", UVM_NONE);
    wait_for_grant();
    `uvm_info(get_name(), "Grant received, randomizing data", UVM_NONE);
    assert(tr.randomize());
    tr.print();
    `uvm_info(get_name(), "Send data to sequencer", UVM_NONE);
    send_request(tr);
    `uvm_info(get_name(), "Wait for item_done from driver", UVM_NONE);
    wait_for_item_done();
    `uvm_info(get_name(), "Sequence ended", UVM_NONE);
  endtask

  virtual task post_body();
    `uvm_info(get_name(), "Sequence post-body executed.", UVM_NONE);
  endtask
endclass

class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver);

  transaction tr;

  function new(string path="driver", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
        `uvm_info(get_name(), "Sending grant for sequence", UVM_NONE);
        seq_item_port.get_next_item(tr);
        `uvm_info(get_name(), "Applying transaction to DUT", UVM_NONE);
        `uvm_info(get_name(), "Sending item_done for sequence", UVM_NONE);
        seq_item_port.item_done();
    end
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent);

  driver drv;
  uvm_sequencer#(transaction) sqr;

  function new(string path="agent", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = driver::type_id::create("drv", this);
    sqr = uvm_sequencer#(transaction)::type_id::create("sqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env);

  agent a;

  function new(string path="env", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("a", this);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test);

  env e;
  seq_1 s1;

  function new(string path="test", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
    s1 = seq_1::type_id::create("s1");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    s1.start(e.a.sqr);
    phase.drop_objection(this);
  endtask
endclass

module tb;
  initial run_test("test");
endmodule

// Output Logs
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(70) @ 0: uvm_test_top.e.a.drv [drv] Sending grant for sequence
// # KERNEL: UVM_INFO /home/runner/testbench.sv(31) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Sequence pre-body executed.
// # KERNEL: UVM_INFO /home/runner/testbench.sv(35) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Sequence started, creating an item.
// # KERNEL: UVM_INFO /home/runner/testbench.sv(37) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Waiting grant from driver
// # KERNEL: UVM_INFO /home/runner/testbench.sv(39) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Grant received, randomizing data
// # KERNEL: ------------------------------
// # KERNEL: Name  Type         Size  Value
// # KERNEL: ------------------------------
// # KERNEL: tr    transaction  -     @564 
// # KERNEL:   a   integral     4     'he  
// # KERNEL:   b   integral     4     'hd  
// # KERNEL:   y   integral     5     'h0  
// # KERNEL: ------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Send data to sequencer
// # KERNEL: UVM_INFO /home/runner/testbench.sv(44) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Wait for item_done from driver
// # KERNEL: UVM_INFO /home/runner/testbench.sv(72) @ 0: uvm_test_top.e.a.drv [drv] Applying transaction to DUT
// # KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 0: uvm_test_top.e.a.drv [drv] Sending item_done for sequence
// -------------------- can be noticed that wait_for_item_done is non-blocking
// # KERNEL: UVM_INFO /home/runner/testbench.sv(70) @ 0: uvm_test_top.e.a.drv [drv] Sending grant for sequence
// # KERNEL: UVM_INFO /home/runner/testbench.sv(46) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Sequence ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Sequence post-body executed.
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_objection.svh(1271) @ 0: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase 