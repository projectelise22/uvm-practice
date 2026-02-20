`include "uvm_macros.svh"
import uvm_pkg::*;

class comp extends uvm_component;
  `uvm_component_utils(comp);
  
  function new(string path="comp", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual task reset_phase(uvm_phase phase);
    // Raising objection tells the simulation to start the process after it
    // otherwise if not included it will not run the following tasks
    // "this" means the phase raising the objection
    phase.raise_objection(this);
    `uvm_info("comp", "Starting reset for 100ns", UVM_NONE);
    #100;
    `uvm_info("comp", "Ending reset for 100ns", UVM_NONE);
    // Dropping objection returns to normal uvm phase process
    phase.drop_objection(this);
  endtask
endclass

module tb;
  initial begin
    run_test("comp");
  end
endmodule

// Output Log
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 0: uvm_test_top [comp] Starting reset for 100ns
// # KERNEL: UVM_INFO /home/runner/testbench.sv(18) @ 100: uvm_test_top [comp] Ending reset for 100ns
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_report_server.svh(869) @ 100: reporter [UVM/REPORT/SERVER] 