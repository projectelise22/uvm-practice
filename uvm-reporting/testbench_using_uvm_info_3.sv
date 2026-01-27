`include "uvm_macros.svh"
import uvm_pkg::*;

class drv extends uvm_driver;
  `uvm_component_utils(drv);
  
  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction
  
  task run();
    `uvm_info("DRV", "This message reports from driver", UVM_HIGH);
  endtask
endclass

class mon extends uvm_monitor;
  `uvm_component_utils(mon);
  
  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction
  
  task run();
    `uvm_info("MON", "This message reports from monitor", UVM_HIGH);
  endtask
endclass

class env extends uvm_env;
  `uvm_component_utils(env);
  
  drv env_drv;
  mon env_mon;
  
  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction
  
  task run();
    env_drv = new("DRV", this);
    env_mon = new("MON", this);
    env_drv.run();
    env_mon.run();
  endtask
endclass

module tb;
  env tb_env;
  
  initial begin
    tb_env = new("ENV", null);
    // set verbosity by hierarchy -- all components under env is set to this level
    tb_env.set_report_verbosity_level_hier(UVM_HIGH);
    tb_env.run();
    
    // Result: shows exact path from where the report is coming from
    // # KERNEL: UVM_INFO /home/runner/testbench.sv(12) @ 0: ENV.DRV [DRV] This message reports from driver
    // # KERNEL: UVM_INFO /home/runner/testbench.sv(24) @ 0: ENV.MON [MON] This message reports from monitor
    
  end
endmodule