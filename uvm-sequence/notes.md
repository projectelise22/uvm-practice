1. Sequence item is the class being extended to create transactions
2. Sequencer is the uvm component sending the sequences to the driver
   - this is not usually modified during creation of tb environment components
   - it is only created in environment class or test class
3. Sequence Arbitration (when multiple sequencers want to send an item to the driver)
   - to set: <path of sequencer>.set_arbitration(<arbitration>)
   - UVM_SEQ_ARB_FIFO -> default, as the name suggests -- first in, first out
   - UVM_SEQ_ARB_WEIGHTED -> sequence with higher priority get chosen first
     -> use set_weight(<int>) method when constructed or in the build phase
     -> or add priority in test
     -> for simplicity, if 1 sequence is weighted at 7, and the other is 3, then 1st sequence has 70% of getting chosen, while the other has 30% chance
     -> if both have the same weight, it acts like a random arbitration
   - UVM_SEQ_ARB_RANDOM -> random chosen sequence
   - UVM_SEQ_ARB_STRICT_FIFO -> sequence with that send request first will be chosen until all sequences are sent
   - UVM_SEQ_ARB_STRICT_RANDOM -> random sequence chosen first will be chosen again until all sequences are sent
   