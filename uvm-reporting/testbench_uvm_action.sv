`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver;
    `uvm_component_utils(driver);

    function new(string path, uvm_component parent);
        super.new(path, parent);
    endfunction

    task run();
        `uvm_info("DRV", "This is an information message from driver", UVM_NONE);
        `uvm_warning("DRV", "This is a warning message from driver");
        `uvm_error("DRV", "This is an error message from driver");
        #10;
        `uvm_error("DRV", "This is another error message from driver");
        #10;
        `uvm_fatal("DRV", "This is a fatal message from driver");
    endtask
endclass

module tb;
    driver drv;

    initial begin
        drv = new("DRV", null);

        // UVM_INFO should not display
        drv.set_report_severity_action(UVM_INFO, UVM_NO_ACTION);
      
        // Change UVM_FATAL to not terminate immediately
        drv.set_report_severity_action(UVM_FATAL, UVM_DISPLAY);
        drv.run();
      
        // UVM_INFO will display and exit after running task
        // #10;
        // drv.set_report_severity_action(UVM_INFO, UVM_DISPLAY | UVM_EXIT);
        // drv.run();

        // Set max_count for UVM_ERROR
        // simulation will terminate after reaching it, default value is 0
        drv.set_report_max_quit_count(2);
        drv.run();
    end
endmodule