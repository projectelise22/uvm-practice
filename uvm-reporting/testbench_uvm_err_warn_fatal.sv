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
  endtask
endclass

module tb;
  drv tb_drv;
  
  initial begin
    tb_drv = new("DRV", null);
    tb_drv.set_report_verbosity_level(UVM_HIGH);
    tb_drv.run();
  end
endmodule