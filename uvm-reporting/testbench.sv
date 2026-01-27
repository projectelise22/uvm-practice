`include "uvm_macros.svh"
import uvm_pkg::*;

module tb;
  
  // Without automation, displaying data in uvm_info
  // use $sformatf
  int data = 20;
  initial begin
    `uvm_info("TB_TOP", $sformatf("Value of data : %0d",data), UVM_NONE);
  end
  
  // Check verbosity of uvm classes
  // use method get_report_verbosity_level to find the value
  // use method set_report_verbosity_level to set the value
  initial begin
    $display("Verbosity level of UVM_TOP: %0d", uvm_top.get_report_verbosity_level);
    
    #10;
    `uvm_info("TB_TOP", "Checking verbosity level to MEDIUM...", UVM_MEDIUM);
    // the following will not be printed
    `uvm_info("TB_TOP", "Checking verbosity level to HIGH...", UVM_HIGH);
    
    #10;
    uvm_top.set_report_verbosity_level(UVM_HIGH);
    $display("Verbosity level of UVM_TOP: %0d", uvm_top.get_report_verbosity_level);
    // the following will not be printed
    `uvm_info("TB_TOP", "Checking verbosity level to MEDIUM again...", UVM_MEDIUM);
    `uvm_info("TB_TOP", "Checking verbosity level to HIGH again...", UVM_HIGH);
  end
endmodule