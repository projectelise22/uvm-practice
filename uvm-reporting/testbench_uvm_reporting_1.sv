`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver;
  `uvm_component_utils(driver);
  
  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction
  
  task run();
    `uvm_info("DRV", "This is an information from the driver", UVM_NONE);
    `uvm_info("DRV", "This is another information from the driver", UVM_DEBUG);
  endtask
endclass

module tb;
  driver drv;
  int tb_verbosity, drv_verbosity;
  
  initial begin
    drv = new("DRV", null);
    // Should only display first information
    drv.run();
    
    // Should display both information
    // Verbosity level should be both 500
    #10;
    uvm_top.set_report_verbosity_level_hier(UVM_DEBUG);
    tb_verbosity = uvm_top.get_report_verbosity_level();
    drv_verbosity = drv.get_report_verbosity_level();
    `uvm_info("TB_TOP", $sformatf("tb top verbosity level: %0d",tb_verbosity), UVM_DEBUG);
    `uvm_info("TB_TOP", $sformatf("driver verbosity level: %0d",drv_verbosity), UVM_DEBUG);
  end
endmodule