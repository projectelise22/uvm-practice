`include "uvm_macros.svh"
import uvm_pkg::*;

// transaction class to create structure of data to be sent
class transaction extends uvm_sequence_item;
  rand bit[3:0] a;
  rand bit[3:0] b;
  bit [4:0] y;
  
  function new(string inst="transaction");
    super.new(inst);
  endfunction
  
  `uvm_object_utils_begin(transaction);
  `uvm_field_int(a, UVM_DEFAULT);
  `uvm_field_int(b, UVM_DEFAULT);
  `uvm_field_int(y, UVM_DEFAULT);
  `uvm_object_utils_end;
endclass

// sequence class to be passed by the sequencer to driver using the transaction
class generator extends uvm_sequence#(transaction);
  `uvm_object_utils(generator);
  
  transaction tr;
  
  function new(string inst="generator");
    super.new(inst);
  endfunction
  
  virtual task body();
    tr = transaction::type_id::create("tr");
    repeat (5) begin
      start_item(tr);
      tr.randomize();
      `uvm_info(get_name(), $sformatf("a: %0d, b: %0d", tr.a, tr.b), UVM_NONE);
      finish_item(tr);
    end
  endtask
endclass

// driver class to get the transaction and drive it to the DUT through an interface
class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver);
  
  transaction tr;
  virtual adder_if a_if;
  
  function new(string path="driver", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    if(!uvm_config_db#(virtual adder_if)::get(this, "", "a_if", a_if))
      `uvm_error(get_name(), "No interface found");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(tr);
      a_if.a <= tr.a;
      a_if.b <= tr.b;
      `uvm_info(get_name(), $sformatf("a: %0d, b: %0d", tr.a, tr.b), UVM_NONE);
      seq_item_port.item_done();
      #10;
    end
  endtask
endclass

// monitor class to broadcast the transactions to and from the DUT
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor);
  
  uvm_analysis_port#(transaction) send;
  transaction tr;
  virtual adder_if a_if;
  
  function new(string path="monitor", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send = new("send", this);
    tr = transaction::type_id::create("tr");
    if(!uvm_config_db#(virtual adder_if)::get(this, "", "a_if", a_if))
      `uvm_error(get_name(), "No interface found");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      #10;
      tr.a = a_if.a;
      tr.b = a_if.b;
      tr.y = a_if.y;
      send.write(tr);
      `uvm_info(get_name(), $sformatf("a: %0d, b: %0d, y: %0d", tr.a, tr.b, tr.y), UVM_NONE);
    end
  endtask
  
endclass

// scoreboard class to receive the broadcasted transactions and check against 
// expected data
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard);
  
  uvm_analysis_imp#(transaction, scoreboard) receive;
  
  function new(string path="scoreboard", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    receive = new("receive", this);
  endfunction
  
  virtual function void write(transaction tr);
    int exp = tr.a + tr.b;
    assert(exp == tr.y)
      `uvm_info(get_name(), $sformatf("Test passed a: %0d, b: %0d, y_act: %0d, y_exp: %0d", tr.a, tr.b, tr.y, exp), UVM_NONE)
    else
      `uvm_error(get_name(), $sformatf("Test failed a: %0d, b: %0d, y_act: %0d, y_exp: %0d", tr.a, tr.b, tr.y, exp));
  endfunction
endclass

// agent class to group the sequencer, driver, monitor together
// and to connect the driver port to the sequencer export
class agent extends uvm_agent;
  `uvm_component_utils(agent);
  
  uvm_sequencer#(transaction) sqr;
  driver drv;
  monitor mon;
  
  function new(string path="agent", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = uvm_sequencer#(transaction)::type_id::create("sqr", this);
    drv = driver::type_id::create("drv", this);
    mon = monitor::type_id::create("mon", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass

// env class to instantiate the agent and scoreboard together
class environment extends uvm_env;
  `uvm_component_utils(environment);
  
  agent agt;
  scoreboard scb;
  
  function new(string path="environment", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = agent::type_id::create("agt", this);
    scb = scoreboard::type_id::create("scb", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.send.connect(scb.receive);
  endfunction
endclass

// test class to create and start the sequence
class test extends uvm_test;
  `uvm_component_utils(test);
  
  environment env;
  generator gen;
  
  function new(string path="test", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = environment::type_id::create("env", this);
    gen = new("gen");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    gen.start(env.agt.sqr);
    #20;
    phase.drop_objection(this);
  endtask
endclass

// testbench to instantiate the dut, if, and tb env
module tb;
  
  // if
  adder_if a_if();

  // dut
  adder i_adder(.a(a_if.a),
                .b(a_if.b),
                .y(a_if.y));
  
  // configure interface then run test
  initial begin
    uvm_config_db#(virtual adder_if)::set(null, "*", "a_if", a_if);
    run_test("test");
  end
  
  // waveform
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule

// Output Logs
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 0: uvm_test_top.env.agt.sqr@@gen [gen] a: 8, b: 9
// # KERNEL: UVM_INFO /home/runner/testbench.sv(65) @ 0: uvm_test_top.env.agt.drv [drv] a: 8, b: 9
// # KERNEL: UVM_INFO /home/runner/testbench.sv(124) @ 10: uvm_test_top.env.scb [scb] Test passed a: 8, b: 9, y_act: 17, y_exp: 17
// # KERNEL: UVM_INFO /home/runner/testbench.sv(99) @ 10: uvm_test_top.env.agt.mon [mon] a: 8, b: 9, y: 17
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 10: uvm_test_top.env.agt.sqr@@gen [gen] a: 5, b: 2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(65) @ 10: uvm_test_top.env.agt.drv [drv] a: 5, b: 2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(124) @ 20: uvm_test_top.env.scb [scb] Test passed a: 5, b: 2, y_act: 7, y_exp: 7
// # KERNEL: UVM_INFO /home/runner/testbench.sv(99) @ 20: uvm_test_top.env.agt.mon [mon] a: 5, b: 2, y: 7
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 20: uvm_test_top.env.agt.sqr@@gen [gen] a: 15, b: 4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(65) @ 20: uvm_test_top.env.agt.drv [drv] a: 15, b: 4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(124) @ 30: uvm_test_top.env.scb [scb] Test passed a: 15, b: 4, y_act: 19, y_exp: 19
// # KERNEL: UVM_INFO /home/runner/testbench.sv(99) @ 30: uvm_test_top.env.agt.mon [mon] a: 15, b: 4, y: 19
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 30: uvm_test_top.env.agt.sqr@@gen [gen] a: 6, b: 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(65) @ 30: uvm_test_top.env.agt.drv [drv] a: 6, b: 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(124) @ 40: uvm_test_top.env.scb [scb] Test passed a: 6, b: 15, y_act: 21, y_exp: 21
// # KERNEL: UVM_INFO /home/runner/testbench.sv(99) @ 40: uvm_test_top.env.agt.mon [mon] a: 6, b: 15, y: 21
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 40: uvm_test_top.env.agt.sqr@@gen [gen] a: 10, b: 3
// # KERNEL: UVM_INFO /home/runner/testbench.sv(65) @ 40: uvm_test_top.env.agt.drv [drv] a: 10, b: 3
// # KERNEL: UVM_INFO /home/runner/testbench.sv(124) @ 50: uvm_test_top.env.scb [scb] Test passed a: 10, b: 3, y_act: 13, y_exp: 13
// # KERNEL: UVM_INFO /home/runner/testbench.sv(99) @ 50: uvm_test_top.env.agt.mon [mon] a: 10, b: 3, y: 13