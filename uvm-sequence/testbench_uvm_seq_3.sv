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

  // instead of using each method from file testbench...seq_2.sv
  // use `uvm_do which calls the same process below
  virtual task body();
    repeat (5) begin
      `uvm_do(tr);
      `uvm_info(get_name(), "Sending sequence item to sequencer...", UVM_NONE);
      tr.print(uvm_default_line_printer);
    end
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
        seq_item_port.get_next_item(tr);
        `uvm_info(get_name(), "Getting sequence item...", UVM_NONE);
        tr.print(uvm_default_line_printer);
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
  seq_1 s1;

  function new(string path="env", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("a", this);
    s1 = seq_1::type_id::create("s1");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    s1.start(a.sqr);
    phase.drop_objection(this);
  endtask
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
// # KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 0: uvm_test_top.e.a.drv [drv] Getting sequence item...
// # KERNEL: tr: (transaction@558) { a: 'h4  b: 'h7  y: 'h0  begin_time: 0  depth: 'd2  parent sequence (name): s1  parent sequence (full name): uvm_test_top.e.a.sqr.s1  sequencer: uvm_test_top.e.a.sqr  } 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(35) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Sending sequence item to sequencer...
// # KERNEL: tr: (transaction@558) { a: 'h4  b: 'h7  y: 'h0  begin_time: 0  end_time: 0  depth: 'd2  parent sequence (name): s1  parent sequence (full name): uvm_test_top.e.a.sqr.s1  sequencer: uvm_test_top.e.a.sqr  } 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 0: uvm_test_top.e.a.drv [drv] Getting sequence item...
// # KERNEL: tr: (transaction@567) { a: 'h5  b: 'h4  y: 'h0  begin_time: 0  depth: 'd2  parent sequence (name): s1  parent sequence (full name): uvm_test_top.e.a.sqr.s1  sequencer: uvm_test_top.e.a.sqr  } 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(35) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Sending sequence item to sequencer...
// # KERNEL: tr: (transaction@567) { a: 'h5  b: 'h4  y: 'h0  begin_time: 0  end_time: 0  depth: 'd2  parent sequence (name): s1  parent sequence (full name): uvm_test_top.e.a.sqr.s1  sequencer: uvm_test_top.e.a.sqr  } 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 0: uvm_test_top.e.a.drv [drv] Getting sequence item...
// # KERNEL: tr: (transaction@572) { a: 'ha  b: 'h5  y: 'h0  begin_time: 0  depth: 'd2  parent sequence (name): s1  parent sequence (full name): uvm_test_top.e.a.sqr.s1  sequencer: uvm_test_top.e.a.sqr  } 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(35) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Sending sequence item to sequencer...
// # KERNEL: tr: (transaction@572) { a: 'ha  b: 'h5  y: 'h0  begin_time: 0  end_time: 0  depth: 'd2  parent sequence (name): s1  parent sequence (full name): uvm_test_top.e.a.sqr.s1  sequencer: uvm_test_top.e.a.sqr  } 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 0: uvm_test_top.e.a.drv [drv] Getting sequence item...
// # KERNEL: tr: (transaction@577) { a: 'h3  b: 'ha  y: 'h0  begin_time: 0  depth: 'd2  parent sequence (name): s1  parent sequence (full name): uvm_test_top.e.a.sqr.s1  sequencer: uvm_test_top.e.a.sqr  } 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(35) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Sending sequence item to sequencer...
// # KERNEL: tr: (transaction@577) { a: 'h3  b: 'ha  y: 'h0  begin_time: 0  end_time: 0  depth: 'd2  parent sequence (name): s1  parent sequence (full name): uvm_test_top.e.a.sqr.s1  sequencer: uvm_test_top.e.a.sqr  } 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 0: uvm_test_top.e.a.drv [drv] Getting sequence item...
// # KERNEL: tr: (transaction@584) { a: 'h0  b: 'h3  y: 'h0  begin_time: 0  depth: 'd2  parent sequence (name): s1  parent sequence (full name): uvm_test_top.e.a.sqr.s1  sequencer: uvm_test_top.e.a.sqr  } 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(35) @ 0: uvm_test_top.e.a.sqr@@s1 [s1] Sending sequence item to sequencer...
// # KERNEL: tr: (transaction@584) { a: 'h0  b: 'h3  y: 'h0  begin_time: 0  end_time: 0  depth: 'd2  parent sequence (name): s1  parent sequence (full name): uvm_test_top.e.a.sqr.s1  sequencer: uvm_test_top.e.a.sqr  } 
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_objection.svh(1271) @ 0: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 