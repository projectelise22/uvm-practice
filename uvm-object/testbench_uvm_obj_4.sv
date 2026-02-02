`include "uvm_macros.svh"
import uvm_pkg::*;

class array extends uvm_object;
    // declare your arrays
    int arr1[3] = {1, 2, 3}; // static
    int arr2[];              // dynamic
    int arr3[$];             // queue
    int arr4[int];           // associative

    // constructor
    function new(string path = "array");
        super.new(path);
    endfunction

    // register class and fields
    `uvm_object_utils_begin(array)
        `uvm_field_sarray_int(arr1, UVM_DEFAULT);
        `uvm_field_array_int(arr2, UVM_DEFAULT);
        `uvm_field_queue_int(arr3, UVM_DEFAULT);
        `uvm_field_aa_int_int(arr4, UVM_DEFAULT);
    `uvm_object_utils_end

    task run();
        arr2 = new[3];
        arr2 = {2, 2, 2};

        arr3.push_front(3);
        arr3.push_front(3);

        arr4[1] = 4;
        arr4[2] = 4;
        arr4[3] = 4;
    endtask
endclass

module tb;
    array a;

    initial begin
        a = new();
        a.run();
        a.print();
    end
endmodule

// Output Log
// # KERNEL: ----------------------------------
// # KERNEL: Name     Type          Size  Value
// # KERNEL: ----------------------------------
// # KERNEL: array    array         -     @335 
// # KERNEL:   arr1   sa(integral)  3     -    
// # KERNEL:     [0]  integral      32    'h1  
// # KERNEL:     [1]  integral      32    'h2  
// # KERNEL:     [2]  integral      32    'h3  
// # KERNEL:   arr2   da(integral)  3     -    
// # KERNEL:     [0]  integral      32    'h2  
// # KERNEL:     [1]  integral      32    'h2  
// # KERNEL:     [2]  integral      32    'h2  
// # KERNEL:   arr3   da(integral)  2     -    
// # KERNEL:     [0]  integral      32    'h3  
// # KERNEL:     [1]  integral      32    'h3  
// # KERNEL:   arr4   aa(int,int)   3     -    
// # KERNEL:     [1]  integral      32    'h4  
// # KERNEL:     [2]  integral      32    'h4  
// # KERNEL:     [3]  integral      32    'h4  
// # KERNEL: ----------------------------------