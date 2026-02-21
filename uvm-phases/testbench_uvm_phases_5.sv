`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver;
  `uvm_component_utils(driver);
  
  function new(string path="driver", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("driver", "Starting reset for 10ns", UVM_NONE);
    #10;
    `uvm_info("driver", "Ending reset for 10ns", UVM_NONE);
    phase.drop_objection(this);
  endtask
  
  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("driver", "Main phase started", UVM_NONE);
    #50;
    `uvm_info("driver", "Main phase ended", UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor);
  
  function new(string path="monitor", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("mon", "Starting reset for 30ns", UVM_NONE);
    #30;
    `uvm_info("mon", "Ending reset for 30ns", UVM_NONE);
    phase.drop_objection(this);
  endtask
  
  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("mon", "Main phase started", UVM_NONE);
    #30;
    `uvm_info("mon", "Main phase ended", UVM_NONE);
    phase.drop_objection(this);
  endtask
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
  initial begin
    run_test("test");
  end
endmodule

// Output Logs
// Main phases will not start until all reset phases are completed
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(37) @ 0: uvm_test_top.e.mon [mon] Starting reset for 30ns
// # KERNEL: UVM_INFO /home/runner/testbench.sv(13) @ 0: uvm_test_top.e.drv [driver] Starting reset for 10ns
// # KERNEL: UVM_INFO /home/runner/testbench.sv(15) @ 10: uvm_test_top.e.drv [driver] Ending reset for 10ns
// # KERNEL: UVM_INFO /home/runner/testbench.sv(39) @ 30: uvm_test_top.e.mon [mon] Ending reset for 30ns
// # KERNEL: UVM_INFO /home/runner/testbench.sv(45) @ 30: uvm_test_top.e.mon [mon] Main phase started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(21) @ 30: uvm_test_top.e.drv [driver] Main phase started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(47) @ 60: uvm_test_top.e.mon [mon] Main phase ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 80: uvm_test_top.e.drv [driver] Main phase ended