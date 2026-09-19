`timescale 1ns/1ps
module tb_cyclic_lamp;
    reg        clk, rst;
    wire [2:0] light;

    // 10 clocks per color 
    cyclic_lamp #(.clk_freq(10), .hold_sec(1)) dut (
        .clk(clk),
        .rst(rst),
        .light(light)
    );


    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        #22 rst = 1'b0;      // release reset between clock edges
        #500 $finish;
    end

    initial begin
        $monitor("%0t  rst=%b  RGY=%b", $time, rst, light);
    end
endmodule