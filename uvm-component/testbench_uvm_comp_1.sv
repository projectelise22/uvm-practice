`include "uvm_macros.svh"
import uvm_pkg::*;

class component extends uvm_component;
  // register to factory
  `uvm_component_utils(component);
  
  // constructor
  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction
  
  // build_phase method
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("component", "Build phase message", UVM_NONE);
  endfunction
endclass

module tb;
  initial begin
    // no need to instantiate component class
    // just invoke run_test with the class name as argument
    // in real tb, test is top of heirarchy and name of test will be run
    run_test("component");
  end

  // the following will log a warning that build_phase is called explicitly
  component c;
  initial begin
    #10;
    c = component::type_id::create("c", null);
    c.build_phase(null);
  end

  // Output Log
  // # KERNEL: UVM_WARNING @ 10: c [UVM_DEPRECATED] build()/build_phase() has been called explicitly, outside of the phasing system. This usage of build is deprecated and may lead to unexpected behavior.
  // # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 10: c [component] Build phase message
endmodule