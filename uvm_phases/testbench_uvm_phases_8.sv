// Adding drain time to all main phases
`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver;
  `uvm_component_utils(driver);

  function new(string path="driver", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("driver", "Reset phase started", UVM_NONE);
    #10;
    `uvm_info("driver", "Reset phase ended", UVM_NONE);
    phase.drop_objection(this);
  endtask

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("driver", "Main phase started", UVM_NONE);
    #50;
    `uvm_info("driver", "Main phase ended", UVM_NONE);
    phase.drop_objection(this);
  endtask
  
  virtual task post_main_phase(uvm_phase phase);
    `uvm_info("driver", "Post main phase executed", UVM_NONE);
  endtask
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor);

  function new(string path="monitor", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("monitor", "Reset phase started", UVM_NONE);
    #10;
    `uvm_info("monitor", "Reset phase ended", UVM_NONE);
    phase.drop_objection(this);
  endtask

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("monitor", "Main phase started", UVM_NONE);
    #100;
    `uvm_info("monitor", "Main phase ended", UVM_NONE);
    phase.drop_objection(this);
  endtask
  
  virtual task post_main_phase(uvm_phase phase);
    `uvm_info("monitor", "Post main phase executed", UVM_NONE);
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

  // to add drain time to all main phases
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_phase main_phase;
    super.end_of_elaboration_phase(phase);

    // find phase by name and pass to a handle
    main_phase = phase.find_by_name("main", 0);
    main_phase.phase_done.set_drain_time(this, 100);
  endfunction
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule

// Output Logs
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 0: uvm_test_top.e.mon [monitor] Reset phase started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(14) @ 0: uvm_test_top.e.drv [driver] Reset phase started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(44) @ 10: uvm_test_top.e.mon [monitor] Reset phase ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 10: uvm_test_top.e.drv [driver] Reset phase ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 10: uvm_test_top.e.mon [monitor] Main phase started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(22) @ 10: uvm_test_top.e.drv [driver] Main phase started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(24) @ 60: uvm_test_top.e.drv [driver] Main phase ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 110: uvm_test_top.e.mon [monitor] Main phase ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(57) @ 210: uvm_test_top.e.mon [monitor] Post main phase executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(29) @ 210: uvm_test_top.e.drv [driver] Post main phase executed
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_report_server.svh(869) @ 210: reporter [UVM/REPORT/SERVER] 