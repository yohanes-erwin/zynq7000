`timescale 1ns / 1ps

module simulation_wrapper_tb();
    localparam T = 10;
    
    reg aclk;
    reg aresetn;
    wire [31:0] m_axis_tdata;
    wire m_axis_tlast;
    reg m_axis_tready;
    wire m_axis_tvalid;
    reg [31:0] s_axis_tdata;
    reg s_axis_tlast;
    wire s_axis_tready;
    reg s_axis_tvalid;
    
    integer i;
    
    simulation_wrapper uut
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid)
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
        // *** Initial value ***
        m_axis_tready = 1;
        s_axis_tdata = 0;
        s_axis_tlast = 0;
        s_axis_tvalid = 0;
        
        // *** Reset ***
        aresetn = 0;
        #T;
        aresetn = 1;
        #T;
        
        // Wait until s_axis_tready is one
        #(T*10);
        
        // *** Send data to AXIS FIFO ***
        s_axis_tvalid = 1;
        for (i = 0; i <= 15; i = i+1)
        begin
            s_axis_tdata = i;
            if (i == 15)
                s_axis_tlast = 1;
            #T;
        end
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
    end
    
endmodule
