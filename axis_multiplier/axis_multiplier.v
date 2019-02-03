// Author: Erwin Ouyang
// Date  : 13 Dec 2018

`timescale 1ns / 1ps

module axis_multiplier
    (
	    // ### Clock and reset signals #########################################
        input wire         aclk,
        input wire         aresetn,
        // ### AXI4-stream slave signals #######################################
        output wire        s_axis_tready,
        input wire [31:0]  s_axis_tdata,
        input wire         s_axis_tvalid,
        input wire         s_axis_tlast,
        // ### AXI4-stream master signals ######################################
        input wire         m_axis_tready,
        output wire [31:0] m_axis_tdata,
        output wire        m_axis_tvalid,
        output wire        m_axis_tlast,
        // ### Custom signals ##################################################
        input wire         en,
        input wire [7:0]   mult_const,
        output wire [31:0] word_count,
        output wire [31:0] frame_count
    );
    
    localparam S_READ_INPUT = 2'h0,
               S_WRITE_OUTPUT = 2'h1;
    
    reg [1:0] _cs, _ns;
    reg [23:0] cnt_words_cv, cnt_words_nv;
    reg [23:0] cnt_frames_cv, cnt_frames_nv;
    reg [31:0] mult_cv, mult_nv;
    reg m_axis_tlast_cv, m_axis_tlast_nv;
    wire s_axis_tready_i;
    wire [31:0] m_axis_tdata_i;
    wire m_axis_tvalid_i;
    wire m_axis_tlast_i;

    assign s_axis_tready = (en) ? s_axis_tready_i : m_axis_tready;
    assign m_axis_tdata = (en) ? m_axis_tdata_i : s_axis_tdata;
    assign m_axis_tvalid = (en) ? m_axis_tvalid_i : s_axis_tvalid;
    assign m_axis_tlast = (en) ? m_axis_tlast_i : s_axis_tlast;
    
    assign s_axis_tready_i = (_cs == S_WRITE_OUTPUT) ? 0 : 1;
    assign m_axis_tdata_i = mult_cv;
    assign m_axis_tvalid_i = (_cs == S_WRITE_OUTPUT) ? 1 : 0;
    assign m_axis_tlast_i = m_axis_tlast_cv;
    
    assign word_count = cnt_words_cv;
    assign frame_count = cnt_frames_cv;

    always @(posedge aclk)
    begin
        if (!aresetn)
        begin
            _cs <= S_READ_INPUT;
            cnt_words_cv <= 0;
            cnt_frames_cv <= 0;
            mult_cv <= 0;
            m_axis_tlast_cv <= 0;
        end
        else
        begin
            _cs <= _ns;
            cnt_words_cv <= cnt_words_nv;
            cnt_frames_cv <= cnt_frames_nv;
            mult_cv <= mult_nv;
            m_axis_tlast_cv <= m_axis_tlast_nv;
        end
    end

    always @(*)
    begin    
        _ns = _cs;
        cnt_words_nv = cnt_words_cv;
        cnt_frames_nv = cnt_frames_cv;
        mult_nv = mult_cv;
        m_axis_tlast_nv = m_axis_tlast_cv;       
        if (en)
        begin
            case (_cs)
                S_READ_INPUT:
                begin
                    if (s_axis_tvalid)
                    begin
                        _ns = S_WRITE_OUTPUT;
                        // Multiplication
                        mult_nv = mult_const * s_axis_tdata;
                        // *** Increment counter ***
                        cnt_words_nv = cnt_words_cv + 1;
                        if (s_axis_tlast)
                            cnt_frames_nv = cnt_frames_cv + 1;     
                        m_axis_tlast_nv = s_axis_tlast;
                    end                   
                end
                S_WRITE_OUTPUT:
                begin
                    if (m_axis_tready)
                    begin
                        _ns = S_READ_INPUT;
                        m_axis_tlast_nv = s_axis_tlast;
                    end
                end
            endcase
        end
    end
    
endmodule
