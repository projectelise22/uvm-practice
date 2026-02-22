`include "uvm_macros.svh"
import uvm_pkg::*;

class prod extends uvm_component;
  `uvm_component_utils(prod);

  string coder_name = "dolly";

  uvm_analysis_port#(string) port;

  function new(string path="prod", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    port.write(coder_name);
    `uvm_info(get_name(), $sformatf("Data broadcasted: %0s", coder_name), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class sub extends uvm_component;
  `uvm_component_utils(sub);

  uvm_analysis_imp#(string, sub) imp;

  function new(string path="sub", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual function void write(string coder_name_r);
    `uvm_info(get_name(), $sformatf("Data received: %0s", coder_name_r), UVM_NONE);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env);

  prod p;
  sub s1, s2, s3;

  function new(string path="env", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = prod::type_id::create("PROD", this);
    s1 = sub::type_id::create("SUB1", this);
    s2 = sub::type_id::create("SUB2", this);
    s3 = sub::type_id::create("SUB3", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    p.port.connect(s1.imp);
    p.port.connect(s2.imp);
    p.port.connect(s3.imp);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test);

  env e;

  function new(string path="test", uvm_component parent= null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass

module tb;
  initial run_test("test");
endmodule

// Output Logs
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO ./uvm-1.2/src/base/uvm_root.svh(583) @ 0: reporter [UVMTOP] UVM testbench topology:
// # KERNEL: --------------------------------------------
// # KERNEL: Name          Type               Size  Value
// # KERNEL: --------------------------------------------
// # KERNEL: uvm_test_top  test               -     @335 
// # KERNEL:   e           env                -     @348 
// # KERNEL:     PROD      prod               -     @357 
// # KERNEL:       port    uvm_analysis_port  -     @393 
// # KERNEL:     SUB1      sub                -     @366 
// # KERNEL:       imp     uvm_analysis_imp   -     @403 
// # KERNEL:     SUB2      sub                -     @375 
// # KERNEL:       imp     uvm_analysis_imp   -     @413 
// # KERNEL:     SUB3      sub                -     @384 
// # KERNEL:       imp     uvm_analysis_imp   -     @423 
// # KERNEL: --------------------------------------------
// # KERNEL: 
// # KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 0: uvm_test_top.e.SUB1 [SUB1] Data received: dolly
// # KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 0: uvm_test_top.e.SUB2 [SUB2] Data received: dolly
// # KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 0: uvm_test_top.e.SUB3 [SUB3] Data received: dolly
// # KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 0: uvm_test_top.e.PROD [PROD] Data broadcasted: dolly