`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_component;
  `uvm_component_utils(driver);

  function new(string path="driver", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("driver", "Driver start of elaboratation phase executed", UVM_NONE);
  endfunction
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor);

  function new(string path="monitor", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("monitor", "Monitor start of elaboratation phase executed", UVM_NONE);
  endfunction
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent);

  driver  drv;
  monitor mon;

  function new(string path="agent", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = driver::type_id::create("drv", this);
    mon = monitor::type_id::create("mon", this);
  endfunction

  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("agent", "Agent start of elaboratation phase executed", UVM_NONE);
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

  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("env", "Env start of elaboratation phase executed", UVM_NONE);
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

  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("test", "Test start of elaboratation phase executed", UVM_NONE);
  endfunction
endclass

module tb;
  initial run_test("test");
endmodule

// Output Logs, shows bottom-up structure
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(13) @ 0: uvm_test_top.e.a.drv [driver] Driver start of elaboratation phase executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 0: uvm_test_top.e.a.mon [monitor] Monitor start of elaboratation phase executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(48) @ 0: uvm_test_top.e.a [agent] Agent start of elaboratation phase executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(68) @ 0: uvm_test_top.e [env] Env start of elaboratation phase executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 0: uvm_test_top [test] Test start of elaboratation phase executed
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 