`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver;
  `uvm_component_utils(driver);
  
  function new(string path="driver", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("driver", "Driver connect phase", UVM_NONE);
  endfunction
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor);
  
  function new(string path="monitor", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("monitor", "Monitor connect phase", UVM_NONE);
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
  endfunction  
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("env", "Env connect phase", UVM_NONE);
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
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("test", "Test connect phase", UVM_NONE);
  endfunction
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule

// Output Log Connect Phase behaves in a bottom-up approach
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(13) @ 0: uvm_test_top.e.drv [driver] Driver connect phase
// # KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 0: uvm_test_top.e.mon [monitor] Monitor connect phase
// # KERNEL: UVM_INFO /home/runner/testbench.sv(48) @ 0: uvm_test_top.e [env] Env connect phase
// # KERNEL: UVM_INFO /home/runner/testbench.sv(68) @ 0: uvm_test_top [test] Test connect phase