// Expressing drain time
// Buffer time of phase before moving to the next phase
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
    // Add drain time
    // this refers to phase where a buffer will be added
    // 200 means 200ns of drain time
    // phase done waits for the phase to end before implementing drain time
    phase.phase_done.set_drain_time(this, 200);
    phase.raise_objection(this);
    `uvm_info("comp", "Main phase started", UVM_NONE);
    #50;
    `uvm_info("comp", "Main phase ended", UVM_NONE);
    phase.drop_objection(this);
  endtask

  virtual task post_main_phase(uvm_phase phase);
    `uvm_info("comp", "Info to check if drain is implemented correctly...", UVM_NONE);
  endtask
endclass

module tb;
  initial begin
    run_test("comp");
  end
endmodule

// Output logs additional 200ns added after main phase ended
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(13) @ 0: uvm_test_top [comp] Reset phase started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(15) @ 50: uvm_test_top [comp] Reset phase ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 50: uvm_test_top [comp] Main phase started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(28) @ 100: uvm_test_top [comp] Main phase ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(33) @ 300: uvm_test_top [comp] Info to check if drain is implemented correctly...