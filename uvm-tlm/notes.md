1. uvm_config_db -> for data setting before simulation (directory of settings)
   - used for passing interfaces
   - one time configuration
   tlm -> for handling data between tb blocks, handling multiple transactions
   - event driven data
2. In SV, we can handle data between blocks by using mailbox and semaphore but with the help of UVM, this
   can be done by using TLM ports
3. Sequence -> Driver: SEQ_TLM_PORT
   Monitor -> Scoreboard: UVM_ANALYSIS_PORT
4. Port -> initiates the transactions (sender)
   - marked as square port in block diagram
   Export -> responds to transactions (receiver)
   - marked as circle port in block diagram
5. When direction of data is same to the direction of a sender request to receiver, we use put operation.
   Otherwise, we use get operation. If direction of data goes to both, we use transport operation.
6. Classes used for put operation where port is the sender, export is the receiver, imp is for connecting both,
   and parameter as the data/transaction type sent:
   - uvm_blocking_put_port#(parameter);
   - uvm_blocking_put_export#(parameter);
   - uvm_blocking_put_imp#(parameter);
7. Think of this for the above classes
   - put is the faucet, export is the pipe, imp is the water tank
   - somewhere someone sends data(put), someone forwards the request(export), someone implements it(imp)
   - an error occurs if you only use put and export, because uvm will try to find a real put implementation