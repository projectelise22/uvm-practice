`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver;
  `uvm_component_utils(driver); // register driver class
  
  function new(string path, uvm_component parent); // initialize construct
    super.new(path, parent);
  endfunction
  
  task run();
    `uvm_info("DRV1", "Sample reporting in a UVM class", UVM_HIGH);
    `uvm_info("DRV2", "Sample reporting in a UVM class", UVM_HIGH);
  endtask
endclass

class env extends uvm_env;
  `uvm_component_utils(env);
  
  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction
  
  task run();
    `uvm_info("ENV1", "Sample reporting in a UVM class", UVM_HIGH);
    `uvm_info("ENV2", "Sample reporting in a UVM class", UVM_HIGH);
  endtask
endclass

module tb;
  // instantiate driver, env class
  // not needed in UVM, added for using specific reporting only
  driver tb_drv;
  env tb_env;
  
  initial begin
    tb_drv = new("DRV", null);
    tb_env = new("ENV", null);
    
    // changing verbosity by ID
    // reports DRV1
    tb_drv.set_report_id_verbosity("DRV1", UVM_HIGH);
    tb_drv.run();
    #10;
    
    // reports both DRV1 and DRV2
    tb_drv.set_report_id_verbosity("DRV2", UVM_HIGH);
    tb_drv.run();
    
    #10
    // changing verbosity by component
    // reports both ENV1 and ENV2
    tb_env.set_report_verbosity_level(UVM_HIGH);
    tb_env.run();
  end

endmodule