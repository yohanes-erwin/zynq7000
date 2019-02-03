// Author: Erwin Ouyang
// Date  : 14 Dec 2018

`timescale 1ns / 1ps

module axis_multiplier_tb();
    localparam T = 10;
    
    reg aclk;
    reg aresetn;
    wire s_axis_tready;
    reg [31:0] s_axis_tdata;
    reg s_axis_tvalid;
    reg s_axis_tlast;
    reg m_axis_tready;
    wire [31:0] m_axis_tdata;
    wire m_axis_tvalid;
    wire m_axis_tlast;
    reg en;
    reg [7:0] mult_const;
    wire [31:0] word_count;
    wire [31:0] frame_count;

    axis_multiplier dut
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tlast(m_axis_tlast),
        .en(en),
        .mult_const(mult_const),
        .word_count(word_count),
        .frame_count(frame_count)
    );
    
    always
    begin
        aclk = 0;
        #(T/2);
        aclk = 1;
        #(T/2);
    end

    initial
    begin
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        m_axis_tready = 1;
        en = 0;
        mult_const = 0;
        
        // *** Reset ***
        aresetn = 0;
        #T;
        aresetn = 1;
        #T
        
        // *** Configure multiplier ***
        en = 1;
        mult_const = 5;
        
        // *** Send 1, 2, 3 to multiplier ***
        s_axis_tvalid = 1;
        s_axis_tdata = 1;
        #(T*2);
        s_axis_tdata = 2;
        #(T*2);
        s_axis_tdata = 3;
        s_axis_tlast = 1;
        #(T*2);
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        
        // *** Send 4, 5 to multiplier ***
        s_axis_tvalid = 1;
        s_axis_tdata = 4;
        #(T*2);
        s_axis_tdata = 5;
        s_axis_tlast = 1;
        #(T*2);
        s_axis_tvalid = 0;
        s_axis_tlast = 0;     
    end

endmodule
