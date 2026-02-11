`include "uvm_macros.svh"
import uvm_pkg::*;

class comp1 extends uvm_component;
  `uvm_component_utils(comp1);
  
  int data1 = 0;
  
  function new(input string path="comp1", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(int)::get(this, "", "data", data1))
      `uvm_error("comp1", "Data not accessible!");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp1", $sformatf("Data received by comp1: %0d", data1), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class comp2 extends uvm_component;
  `uvm_component_utils(comp2);
  
  int data2 = 0;
  
  function new(input string path="comp2", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(int)::get(this, "", "data", data2))
      `uvm_error("comp2", "Data not accessible!");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp2", $sformatf("Data received by comp2: %0d", data2), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent);
  
  function new(input string inst="agent", uvm_component c);
    super.new(inst, c);
  endfunction
  
  comp1 c1;
  comp2 c2;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    c1 = comp1::type_id::create("c1", this);
    c2 = comp2::type_id::create("c2", this);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env);
  
  function new(input string inst="env", uvm_component c);
    super.new(inst, c);
  endfunction
  
  agent a;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("agent", this);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test);
  
  function new(input string inst="test", uvm_component c);
    super.new(inst, c);
  endfunction
  
  env e;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("env", this);
  endfunction
endclass

module tb;
  int data = 256;
  
  initial begin
    // asterisk means all under agent
    uvm_config_db#(int)::set(null, "uvm_test_top.env.agent*", "data", data);
    run_test("test");
  end
endmodule

// Output Log if instance is not changed
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_ERROR /home/runner/testbench.sv(16) @ 0: uvm_test_top.ENV.AGENT.comp1 [comp1] Data not accessible!
// # KERNEL: UVM_ERROR /home/runner/testbench.sv(38) @ 0: uvm_test_top.ENV.AGENT.comp2 [comp2] Data not accessible!
// # KERNEL: UVM_FATAL @ 0: reporter [BUILDERR] stopping due to build errors

// Output Log if instance is changed to correct path for both comp1 and comp2
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 0: uvm_test_top.env.agent.c2 [comp2] Data received by comp2: 256
// # KERNEL: UVM_INFO /home/runner/testbench.sv(21) @ 0: uvm_test_top.env.agent.c1 [comp1] Data received by comp1: 256
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_objection.svh(1271) @ 0: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 