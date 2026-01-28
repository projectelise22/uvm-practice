`include "uvm_macros.svh"
import uvm_pkg::*;

class drv extends uvm_driver;
  `uvm_component_utils(drv);
  
  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction
  
  task run();
    // simulation continues when called:
    `uvm_info("DRV", "This message reports from driver", UVM_HIGH);
    `uvm_warning("DRV", "This is a warning message from driver");
    `uvm_error("DRV", "This is an error message from driver");
    #10;
    // simulation stops, $finish will be called
    `uvm_fatal("DRV", "This is a fatal message from driver");
    #10;
    `uvm_fatal("DRV1", "This is a fatal message from driver");
  endtask
endclass

module tb;
  drv tb_drv;
  
  initial begin
    tb_drv = new("DRV", null);
    // shows other reporting mechanism: warning, error, fatal
    tb_drv.set_report_verbosity_level(UVM_HIGH);
    // tb_drv.run();
    
    // override by severity
    // changing from fatal to error
    // should report as ERROR and not call $finish
    // tb_drv.set_report_severity_override(UVM_FATAL, UVM_ERROR);
    // tb_drv.run();
    
    // override by severity id
    // changing from fatal drv to error drv
    // should report as error while drv1 remains as fatal
    tb_drv.set_report_severity_id_override(UVM_FATAL, "DRV", UVM_ERROR);
    tb_drv.run();    
    // Log result:
    // # KERNEL: UVM_INFO /home/runner/testbench.sv(13) @ 0: DRV [DRV] This message reports from driver
    // # KERNEL: UVM_WARNING /home/runner/testbench.sv(14) @ 0: DRV [DRV] This is a warning message from driver
    // # KERNEL: UVM_ERROR /home/runner/testbench.sv(15) @ 0: DRV [DRV] This is an error message from driver
    // # KERNEL: UVM_ERROR /home/runner/testbench.sv(18) @ 10: DRV [DRV] This is a fatal message from driver
    // # KERNEL: UVM_FATAL /home/runner/testbench.sv(20) @ 20: DRV [DRV1] This is a fatal message from driver
  end
endmodule