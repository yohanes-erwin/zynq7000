// Author: Erwin Ouyang
// Date  : 15 Dec 2018

`timescale 1ns / 1ps

module axi_s2mm_interface
	(
        // ### Clock and reset signals #########################################
        input  wire        aclk,
        input  wire        aresetn,
        // ### AXI4-lite slave signals #########################################
        // *** Write address signals ***
        output wire        s_axi_awready,
        input  wire [31:0] s_axi_awaddr,
        input  wire        s_axi_awvalid,
        // *** Write data signals ***
        output wire        s_axi_wready,
        input  wire [31:0] s_axi_wdata,
        input  wire [3:0]  s_axi_wstrb,
        input  wire        s_axi_wvalid,
        // *** Write response signals ***
        input  wire        s_axi_bready,
        output wire [1:0]  s_axi_bresp,
        output wire        s_axi_bvalid,
        // *** Read address signals ***
        output wire        s_axi_arready,
        input  wire [31:0] s_axi_araddr,
        input  wire        s_axi_arvalid,
        // *** Read data signals ***    
        input  wire        s_axi_rready,
        output wire [31:0] s_axi_rdata,
        output wire [1:0]  s_axi_rresp,
        output wire        s_axi_rvalid,
        // ### AXI4-stream slave signals #######################################
        output wire        s_axis_tready,
        input wire [31:0]  s_axis_tdata,
        input wire         s_axis_tvalid,
        input wire         s_axis_tlast,
        // ### User signals ####################################################
        input  wire [31:0] cnt_words,
        input  wire [31:0] cnt_frames
    );

    // ### Register map ########################################################
    // 0x00: result ready
    //       bit 0 = READY (R/W)
    // 0x04: number of procesed words  
    //       bit 31~0 = WORDS[23:0] (R)
    // 0x08: number of procesed frames  
    //       bit 31~0 = FRAMES[23:0] (R)
    // 0x0c: data register 0
    //       bit 31~0 = DATA0[31:0] (R/W)
    // 0x10: data register 1
    //       bit 31~0 = DATA1[31:0] (R/W)
    // 0x14: data register 2
    //       bit 31~0 = DATA2[31:0] (R/W)
    // 0x18: data register 3
    //       bit 31~0 = DATA3[31:0] (R/W)  
	localparam C_ADDR_BITS = 8;
    // *** Address ***
	localparam C_ADDR_CTRL = 8'h00,
               C_ADDR_WORDS = 8'h04,
               C_ADDR_FRAMES = 8'h08,
               C_ADDR_DATA0 = 8'h0c,
               C_ADDR_DATA1 = 8'h10,
               C_ADDR_DATA2 = 8'h14,
               C_ADDR_DATA3 = 8'h18;
    // *** AXI write FSM ***
    localparam S_WRIDLE = 2'd0,
               S_WRDATA = 2'd1,
               S_WRRESP = 2'd2;
    // *** AXI read FSM ***
    localparam S_RDIDLE = 2'd0,
               S_RDDATA = 2'd1;    
    // *** AXIS FSM ***
    localparam S_IDLE = 2'h0,
               S_READ_STREAM = 2'h1,
               S_BUSY = 2'h2;    

	// *** AXI write ***
	reg [1:0] wstate_cs, wstate_ns;
	reg [C_ADDR_BITS-1:0] waddr;
	wire [31:0] wmask;
	wire aw_hs, w_hs;
	// *** AXI read ***
	reg [1:0] rstate_cs, rstate_ns;
	wire [C_ADDR_BITS-1:0] raddr;
	reg [31:0] rdata;
	wire ar_hs;
    // *** Control registers ***
    reg [0:0] ctrl_reg;
    reg [31:0] data_reg [0:3];
    // *** AXIS ***
    reg [1:0] s2mmstate_cs, s2mmstate_ns;
    reg [1:0] rd_ptr_cv, rd_ptr_nv;
    reg done_cv, done_nv;

	// ### AXI write ###########################################################
	assign s_axi_awready = (wstate_cs == S_WRIDLE);
	assign s_axi_wready = (wstate_cs == S_WRDATA);
	assign s_axi_bresp = 2'b00;    // OKAY
	assign s_axi_bvalid = (wstate_cs == S_WRRESP);
	assign wmask = {{8{s_axi_wstrb[3]}}, {8{s_axi_wstrb[2]}}, {8{s_axi_wstrb[1]}}, {8{s_axi_wstrb[0]}}};
	assign aw_hs = s_axi_awvalid & s_axi_awready;
	assign w_hs = s_axi_wvalid & s_axi_wready;

	// *** Write state register ***
	always @(posedge aclk)
	begin
		if (!aresetn)
			wstate_cs <= S_WRIDLE;
		else
			wstate_cs <= wstate_ns;
	end
	
	// *** Write state next ***
	always @(*)
	begin
		case (wstate_cs)
			S_WRIDLE:
				if (s_axi_awvalid)
					wstate_ns = S_WRDATA;
				else
					wstate_ns = S_WRIDLE;
			S_WRDATA:
				if (s_axi_wvalid)
					wstate_ns = S_WRRESP;
				else
					wstate_ns = S_WRDATA;
			S_WRRESP:
				if (s_axi_bready)
					wstate_ns = S_WRIDLE;
				else
					wstate_ns = S_WRRESP;
			default:
				wstate_ns = S_WRIDLE;
		endcase
	end
	
	// *** Write address register ***
	always @(posedge aclk)
	begin
		if (aw_hs)
			waddr <= s_axi_awaddr[C_ADDR_BITS-1:0];
	end

	// ### AXI read ############################################################
	assign s_axi_arready = (rstate_cs == S_RDIDLE);
	assign s_axi_rdata = rdata;
	assign s_axi_rresp = 2'b00;    // OKAY
	assign s_axi_rvalid = (rstate_cs == S_RDDATA);
	assign ar_hs = s_axi_arvalid & s_axi_arready;
	assign raddr = s_axi_araddr[C_ADDR_BITS-1:0];
	
	// *** Read state register ***
	always @(posedge aclk)
	begin
		if (!aresetn)
			rstate_cs <= S_RDIDLE;
		else
			rstate_cs <= rstate_ns;
	end

	// *** Read state next ***
	always @(*) 
	begin
		case (rstate_cs)
			S_RDIDLE:
				if (s_axi_arvalid)
					rstate_ns = S_RDDATA;
				else
					rstate_ns = S_RDIDLE;
			S_RDDATA:
				if (s_axi_rready)
					rstate_ns = S_RDIDLE;
				else
					rstate_ns = S_RDDATA;
			default:
				rstate_ns = S_RDIDLE;
		endcase
	end
	
	// *** Read data register ***
	always @(posedge aclk)
	begin
	    if (!aresetn)
	        rdata <= 0;
		else if (ar_hs)
			case (raddr)
				C_ADDR_CTRL: 
					rdata <= ctrl_reg[0:0];
				C_ADDR_WORDS:
                    rdata <= cnt_words[31:0];
                C_ADDR_FRAMES:
                    rdata <= cnt_frames[31:0];
                C_ADDR_DATA0:
                    rdata <= data_reg[0];
                C_ADDR_DATA1:
                    rdata <= data_reg[1];
                C_ADDR_DATA2:
                    rdata <= data_reg[2];
                C_ADDR_DATA3:
                    rdata <= data_reg[3]; 		
			endcase
	end
    
    // ### Control register ####################################################
    always @(posedge aclk)
    begin
        if (!aresetn)
            ctrl_reg[0] <= 0;
        else if (w_hs && waddr == C_ADDR_CTRL && s_axi_wdata[0])
            ctrl_reg[0] <= 0;
        else if (done_nv)
            ctrl_reg[0] <= 1;
    end

	always @(posedge aclk)
	begin
	    if (!aresetn)
	    begin
            data_reg[0] <= 0;
            data_reg[1] <= 0;
            data_reg[2] <= 0;
            data_reg[3] <= 0;
        end
		else if (s_axis_tvalid)
		begin
            data_reg[rd_ptr_cv] <= s_axis_tdata;
        end
	end

    // ### AXIS ################################################################
    assign s_axis_tready = (s2mmstate_cs == S_BUSY) ? 0 : 1;

    // *** AXIS state register ***
    always @(posedge aclk)
    begin
        if (!aresetn)
        begin
            s2mmstate_cs <= S_IDLE;
            rd_ptr_cv <= 0;
            done_cv <= 0;
        end
        else
        begin
            s2mmstate_cs <= s2mmstate_ns;
            rd_ptr_cv <= rd_ptr_nv;
            done_cv <= done_nv;
        end 
    end
    
    // *** AXIS state next ***
    always @(*)
    begin
        s2mmstate_ns = s2mmstate_cs;
        rd_ptr_nv = rd_ptr_cv;
        done_nv = done_cv;
        case (s2mmstate_cs)
            S_IDLE:
            begin
                if (s_axis_tvalid)
                begin
                    if (s_axis_tlast)
                    begin
                        s2mmstate_ns = S_BUSY;
                        rd_ptr_nv = 0;
                        done_nv = 1;
                    end
                    else
                    begin
                        s2mmstate_ns = S_READ_STREAM;
                        rd_ptr_nv = rd_ptr_cv + 1;
                    end
                end
            end
            S_READ_STREAM:
            begin
                if (s_axis_tvalid)
                begin
                    if (s_axis_tlast)
                    begin
                        s2mmstate_ns = S_BUSY;
                        rd_ptr_nv = 0;
                        done_nv = 1;
                    end
                    else
                    begin
                        rd_ptr_nv = rd_ptr_cv + 1;
                    end
                end
            end
            S_BUSY:
            begin
                if (!ctrl_reg[0])
                begin
                    s2mmstate_ns = S_IDLE;
                    done_nv = 0;
                end
            end
        endcase
    end
    
endmodule
