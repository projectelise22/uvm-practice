`include "uvm_macros.svh"
import uvm_pkg::*;

// transaction class for structure of data to be sent
class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction);

  rand logic [3:0] a;
  rand logic [3:0] b;
  rand logic [3:0] c;
  rand logic [3:0] d;
  rand logic [1:0] sel;
  logic [3:0] y;

  function new(string inst="transaction");
    super.new(inst);
  endfunction
endclass

// generator class to create sequence based on transaction
class generator extends uvm_sequence#(transaction);
  `uvm_object_utils(generator);

  transaction tr;

  function new(string inst="generator");
    super.new(inst);
  endfunction

  virtual task body();
    tr = transaction::type_id::create("tr");
    repeat(10) begin
        start_item(tr);
        tr.randomize();
        `uvm_info(get_name(), $sformatf("a: %0d, b: %0d, c: %0d, d: %0d, sel: %0d", tr.a, tr.b, tr.c, tr.d, tr.sel), UVM_NONE);
        finish_item(tr);
      end
  endtask
endclass

// driver class to send data from sequencer to dut through dut if
class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver);

  transaction tr;
  virtual mux_if m_if;

  function new(string path="driver", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual mux_if)::get(this, "", "m_if", m_if))
      `uvm_error(get_name(), "No interface found");
    tr = transaction::type_id::create("tr");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
        seq_item_port.get_next_item(tr);
        m_if.a <= tr.a;
        m_if.b <= tr.b;
        m_if.c <= tr.c;
        m_if.d <= tr.d;
        m_if.sel <= tr.sel;
        `uvm_info(get_name(), $sformatf("a: %0d, b: %0d, c: %0d, d: %0d, sel: %0d", tr.a, tr.b, tr.c, tr.d, tr.sel), UVM_NONE);
        #10;
        seq_item_port.item_done();
    end
  endtask
endclass

// monitor class to get data from dut and broadcast to scoreboard
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor);

  uvm_analysis_port#(transaction) port;
  virtual mux_if m_if;
  transaction tr;

  function new(string path="monitor", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
    if(!uvm_config_db#(virtual mux_if)::get(this, "", "m_if", m_if))
      `uvm_error(get_name(), "No interface found");
    tr = transaction::type_id::create("tr");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
        #10;
        tr.a = m_if.a;
        tr.b = m_if.b;
        tr.c = m_if.c;
        tr.d = m_if.d;
        tr.sel = m_if.sel;
        tr.y = m_if.y;
        port.write(tr);
        `uvm_info(get_name(), $sformatf("a: %0d, b: %0d, c: %0d, d: %0d, sel: %0d, y: %0d", tr.a, tr.b, tr.c, tr.d, tr.sel, tr.y), UVM_NONE);
    end
  endtask
endclass

// scoreboard class to receive data from monitor and check against expected data
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard);

  uvm_analysis_imp#(transaction, scoreboard) imp;

  function new(string path="scoreboard", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual function void write(transaction tr);
    logic [3:0] exp_data = 0;
    case(tr.sel)
      2'b00 :  exp_data = tr.a;
      2'b01 :  exp_data = tr.b;
      2'b10 :  exp_data = tr.c;
      2'b11 :  exp_data = tr.d;
    endcase

    assert(tr.y == exp_data)
      begin
      `uvm_info(get_name(), $sformatf("Test passed."), UVM_NONE);
      `uvm_info(get_name(), $sformatf("a: %0d, b: %0d, c: %0d, d: %0d, sel: %0d, y: %0d", tr.a, tr.b, tr.c, tr.d, tr.sel, tr.y), UVM_NONE);
      end
    else
      begin
      `uvm_error(get_name(), "Test failed.");
      `uvm_info(get_name(), $sformatf("a: %0d, b: %0d, c: %0d, d: %0d, sel: %0d, y: %0d", tr.a, tr.b, tr.c, tr.d, tr.sel, tr.y), UVM_NONE);
      end
  endfunction
endclass

// agent class to group sequencer, driver and monitor
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
// environment class to group agent and scoreboard
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
    agt.mon.port.connect(scb.imp);
  endfunction
endclass

// test class to add environment and start sequence
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
    gen = generator::type_id::create("gen");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    gen.start(env.agt.sqr);
    #20;
    phase.drop_objection(this);
  endtask
endclass


// testbench top to instantiate dut, if, and test
module tb;

  // if
  mux_if m_if();

  // dut
  mux i_mux(.a(m_if.a),
            .b(m_if.b),
            .c(m_if.c),
            .d(m_if.d),
            .sel(m_if.sel),
            .y(m_if.y));

  // run test
  initial begin
    uvm_config_db#(virtual mux_if)::set(null, "*", "m_if", m_if);
    run_test("test");
  end

  // waveform dump
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule