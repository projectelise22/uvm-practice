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
    #10;
    `uvm_info("comp", "Ending reset for 100ns", UVM_NONE);
    // Dropping objection returns to normal uvm phase process
    phase.drop_objection(this);
  endtask
  
  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp", "Main phase started", UVM_NONE);
    #50;
    `uvm_info("comp", "Main phase ended", UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

module tb;
  initial begin
    run_test("comp");
  end
endmodule

// Output Log, reset phase will finish first, then main phase comes after
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 0: uvm_test_top [comp] Starting reset for 100ns
// # KERNEL: UVM_INFO /home/runner/testbench.sv(18) @ 10: uvm_test_top [comp] Ending reset for 100ns
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 10: uvm_test_top [comp] Main phase started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(27) @ 60: uvm_test_top [comp] Main phase ended