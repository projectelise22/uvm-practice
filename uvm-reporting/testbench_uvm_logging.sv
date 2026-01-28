`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver;
    `uvm_component_utils(driver);

    function new(string path, uvm_component parent);
        super.new(path, parent);
    endfunction

    task run();
        `uvm_info("DRV", "This is an information from driver", UVM_NONE);
        `uvm_warning("DRV", "This is a warning from driver");
        `uvm_error("DRV", "This is an error from driver");
        #10;
        `uvm_error("DRV", "This is another error from driver");
    endtask
endclass

module tb;
    driver drv;
    int file;

    initial begin
        file = $fopen("log.txt", "w");

        drv = new("DRV", null);
        drv.set_report_default_file(file);

        // To add logs for specific severity
        // drv.set_report_severity_file(UVM_ERROR, error_log);

        drv.set_report_severity_action(UVM_INFO, UVM_DISPLAY|UVM_LOG);
        drv.set_report_severity_action(UVM_WARNING, UVM_DISPLAY|UVM_LOG);
        drv.set_report_severity_action(UVM_ERROR, UVM_DISPLAY|UVM_LOG);
        drv.run();
      
        #10;
        $fclose(file);
    end
endmodule
