// locking and unlocking sequences

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
    repeat (3) begin
      `uvm_info(get_name(), "Start sequence", UVM_NONE);
      `uvm_do(tr);
      // tr.print(uvm_default_line_printer);
      `uvm_info(get_name(), "End sequence", UVM_NONE);
    end
  endtask
endclass

class seq_2 extends uvm_sequence#(transaction);
  `uvm_object_utils(seq_1);

  transaction tr;

  function new(string inst="seq_1");
    super.new(inst);
  endfunction

  // instead of using each method from file testbench...seq_2.sv
  // use `uvm_do which calls the same process below
  virtual task body();
    repeat (3) begin
      `uvm_info(get_name(), "Start sequence", UVM_NONE);
      `uvm_do(tr);
      // tr.print(uvm_default_line_printer);
      `uvm_info(get_name(), "End sequence", UVM_NONE);
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
        // `uvm_info(get_name(), "Getting sequence item...", UVM_NONE);
        // tr.print(uvm_default_line_printer);
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
  seq_2 s2;

  function new(string path="test", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
    s1 = seq_1::type_id::create("s1");
    s2 = seq_2::type_id::create("s2");
  endfunction

  virtual task run_phase(uvm_phase phase);
    // e.a.sqr.set_arbitration(UVM_SEQ_ARB_WEIGHTED);
    phase.raise_objection(this);
    fork
      s1.start(e.a.sqr, null, 3);
      s2.start(e.a.sqr, null, 7); // sequencer, parent, priority
    join
    phase.drop_objection(this);
  endtask
endclass

module tb;
  initial run_test("test");
endmodule

// Output Logs
