// Author: Erwin Ouyang
// Date  : 12 Dec 2018

`timescale 1ns / 1ps

module shift_register
    (
        input  wire       clk, rst_n,
        input  wire       dir, din, en,
        output wire [3:0] q
    );
    
    reg [3:0] sreg_cv, sreg_nv;
    
    always @(posedge clk)
    begin
        if (!rst_n)
            sreg_cv <= 0;
        else
            sreg_cv <= sreg_nv;
    end
    
    always @*
    begin
        sreg_nv = sreg_cv;
        if (en)
            if (!dir)
                sreg_nv = {sreg_cv[2:0], din}; 
            else
                sreg_nv = {din, sreg_cv[3:1]};
    end
    
    assign q = sreg_cv;
    
endmodule
