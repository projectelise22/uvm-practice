// Expressing timeouts
`include "uvm_macros.svh"
import uvm_pkg::*;

class comp extends uvm_component;
  `uvm_component_utils(comp);

  function new(string path="comp", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp", "Reset phase started", UVM_NONE);
    #50;
    `uvm_info("comp", "Reset phase ended", UVM_NONE);
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
    // args: time in ns to end simulation, 0 means no other component can override this timeout
    uvm_top.set_timeout(80, 0);
    run_test("comp");
  end
endmodule

// Output logs
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(14) @ 0: uvm_test_top [comp] Reset phase started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 50: uvm_test_top [comp] Reset phase ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(22) @ 50: uvm_test_top [comp] Main phase started
// # KERNEL: UVM_FATAL ./uvm-1.2/src/base/uvm_phase.svh(1508) @ 80: reporter [PH_TIMEOUT] Explicit timeout of 80 hit, indicating a probable testbench issue