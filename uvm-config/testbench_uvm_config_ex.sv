`include "uvm_macros.svh"
import uvm_pkg::*;

class drv extends uvm_driver;
  `uvm_component_utils(drv);
  
  virtual adder_if aif;
  
  function new(string path="drv", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // driver gets the interface set during test
    // which will have the path uvm_test_top.env.agent.drv.aif
    if(!uvm_config_db#(virtual adder_if)::get(this, "", "aif", aif))
      `uvm_error("drv", "Driver has no access to adder interface");
  endfunction;
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    for (int i = 0; i < 10; i++)
      begin
        aif.a <= $urandom;
        aif.b <= $urandom;
        #10;
      end
    phase.drop_objection(this);
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent);
  
  drv i_drv;
  
  function new(string inst="agent", uvm_component c=null);
    super.new(inst, c);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    i_drv = drv::type_id::create("drv", this);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env);
  
  agent i_agent;
  
  function new(string inst="env", uvm_component c=null);
    super.new(inst, c);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    i_agent = agent::type_id::create("agent", this);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test);
  
  env i_env;
  
  function new(string inst="test", uvm_component c=null);
    super.new(inst, c);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    i_env = env::type_id::create("env", this);
  endfunction
endclass

module tb;
  // interface instance
  adder_if aif();
  
  // dut instance
  adder i_adder(.a(aif.a),
                .b(aif.b),
                .y(aif.y)
               );
  
  // test
  initial begin
    // set interface
    uvm_config_db#(virtual adder_if)::set(null, "uvm_test_top.env.agent.drv", "aif", aif);
    run_test("test");
  end
  
  // waveform
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule