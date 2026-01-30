`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver;
    `uvm_component_utils(driver);

    function new(string path, uvm_component parent);
      super.new(path, parent);
    endfunction

    task run();
      `uvm_warning("DRV", "Message 1 from driver");
      `uvm_warning("DRV", "Message 2 from driver");
      `uvm_warning("DRV", "Message 3 from driver");
      `uvm_warning("DRV", "Message 4 from driver");
    endtask
endclass

module tb;
    driver drv;

    initial begin
      drv = new("DRV", null);

      // override warning severity action
      drv.set_report_severity_action(UVM_WARNING, UVM_DISPLAY | UVM_COUNT);

      // set maximum warning count and invoke drv.run()
      drv.set_report_max_quit_count(4);
      drv.run();
    end
endmodule