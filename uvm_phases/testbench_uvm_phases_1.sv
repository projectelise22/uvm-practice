`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver;
  `uvm_component_utils(driver);
  
  function new(string path="driver", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("driver", "Driver build phase", UVM_NONE);
  endfunction
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor);
  
  function new(string path="monitor", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("monitor", "Monitor build phase", UVM_NONE);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env);
  
  driver drv;
  monitor mon;
  
  function new(string path="env", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = driver::type_id::create("drv", this);
    mon = monitor::type_id::create("mon", this);
    `uvm_info("env", "Env build phase", UVM_NONE);
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
    `uvm_info("env", "Test build phase", UVM_NONE);
  endfunction  
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule

// Output Log
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(60) @ 0: uvm_test_top [env] Test build phase
// # KERNEL: UVM_INFO /home/runner/testbench.sv(44) @ 0: uvm_test_top.e [env] Env build phase
// # KERNEL: UVM_INFO /home/runner/testbench.sv(13) @ 0: uvm_test_top.e.drv [driver] Driver build phase
// # KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 0: uvm_test_top.e.mon [monitor] Monitor build phase
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 
// # KERNEL: --- UVM Report Summary ---
// # KERNEL: 
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    6
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [driver]     1
// # KERNEL: [env]     2
// # KERNEL: [monitor]     1