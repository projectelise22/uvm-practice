`include "uvm_macros.svh"
import uvm_pkg::*;

class env extends uvm_env;
  `uvm_component_utils(env);
  int data;
  
  function new(string path="env", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db#(int)::get(null, "uvm_test_top", "data", data))
      `uvm_info("env", $sformatf("Data: %0d", data), UVM_NONE)
    else
      `uvm_error("env", "Unable to access value");
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test);
  env e;
  
  function new(string path="test", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
    
    // to set the variables in a test like data use the following
    // set method has four arguments
    // context -> where/from which component is this set from, null means global scope (any component can access it)
    // inst_name -> who should receive it? (heirarchal path relative to context)
    // key -> name of the field
    // value -> actual data to be set and get later on
    // in the ex below, it means start looking globally, give uvm_test_top the data equal to 12
    uvm_config_db#(int )::set(null, "uvm_test_top", "data", 12);
  endfunction
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule

// Output Log
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 0: uvm_test_top.e [env] Data: 12
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 