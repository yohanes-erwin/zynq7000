`timescale 1ns / 1ps

module simulation_wrapper_tb();
    localparam T = 10;
    
    reg aclk;
    reg aresetn;
    wire s_axi_mm2s_arready;
    reg [31:0] s_axi_mm2s_araddr;
    reg s_axi_mm2s_arvalid; 
    wire s_axi_mm2s_awready;
    reg [31:0] s_axi_mm2s_awaddr;
    reg s_axi_mm2s_awvalid;  
    reg s_axi_mm2s_bready;
    wire [1:0] s_axi_mm2s_bresp;
    wire s_axi_mm2s_bvalid;
    reg s_axi_mm2s_rready;
    wire [31:0] s_axi_mm2s_rdata;
    wire [1:0] s_axi_mm2s_rresp;
    wire s_axi_mm2s_rvalid;
    wire s_axi_mm2s_wready;
    reg [31:0] s_axi_mm2s_wdata;
    reg [3:0] s_axi_mm2s_wstrb;
    reg s_axi_mm2s_wvalid;
    wire s_axi_s2mm_arready;
    reg [31:0] s_axi_s2mm_araddr;
    reg s_axi_s2mm_arvalid; 
    wire s_axi_s2mm_awready;
    reg [31:0] s_axi_s2mm_awaddr;
    reg s_axi_s2mm_awvalid;  
    reg s_axi_s2mm_bready;
    wire [1:0] s_axi_s2mm_bresp;
    wire s_axi_s2mm_bvalid;
    reg s_axi_s2mm_rready;
    wire [31:0] s_axi_s2mm_rdata;
    wire [1:0] s_axi_s2mm_rresp;
    wire s_axi_s2mm_rvalid;
    wire s_axi_s2mm_wready;
    reg [31:0] s_axi_s2mm_wdata;
    reg [3:0] s_axi_s2mm_wstrb;
    reg s_axi_s2mm_wvalid;

    simulation_wrapper dut
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axi_mm2s_araddr(s_axi_mm2s_araddr),
        .s_axi_mm2s_arready(s_axi_mm2s_arready),
        .s_axi_mm2s_arvalid(s_axi_mm2s_arvalid),
        .s_axi_mm2s_awaddr(s_axi_mm2s_awaddr),
        .s_axi_mm2s_awready(s_axi_mm2s_awready),
        .s_axi_mm2s_awvalid(s_axi_mm2s_awvalid),
        .s_axi_mm2s_bready(s_axi_mm2s_bready),
        .s_axi_mm2s_bresp(s_axi_mm2s_bresp),
        .s_axi_mm2s_bvalid(s_axi_mm2s_bvalid),
        .s_axi_mm2s_rdata(s_axi_mm2s_rdata),
        .s_axi_mm2s_rready(s_axi_mm2s_rready),
        .s_axi_mm2s_rresp(s_axi_mm2s_rresp),
        .s_axi_mm2s_rvalid(s_axi_mm2s_rvalid),
        .s_axi_mm2s_wdata(s_axi_mm2s_wdata),
        .s_axi_mm2s_wready(s_axi_mm2s_wready),
        .s_axi_mm2s_wstrb(s_axi_mm2s_wstrb),
        .s_axi_mm2s_wvalid(s_axi_mm2s_wvalid),
        .s_axi_s2mm_araddr(s_axi_s2mm_araddr),
        .s_axi_s2mm_arready(s_axi_s2mm_arready),
        .s_axi_s2mm_arvalid(s_axi_s2mm_arvalid),
        .s_axi_s2mm_awaddr(s_axi_s2mm_awaddr),
        .s_axi_s2mm_awready(s_axi_s2mm_awready),
        .s_axi_s2mm_awvalid(s_axi_s2mm_awvalid),
        .s_axi_s2mm_bready(s_axi_s2mm_bready),
        .s_axi_s2mm_bresp(s_axi_s2mm_bresp),
        .s_axi_s2mm_bvalid(s_axi_s2mm_bvalid),
        .s_axi_s2mm_rdata(s_axi_s2mm_rdata),
        .s_axi_s2mm_rready(s_axi_s2mm_rready),
        .s_axi_s2mm_rresp(s_axi_s2mm_rresp),
        .s_axi_s2mm_rvalid(s_axi_s2mm_rvalid),
        .s_axi_s2mm_wdata(s_axi_s2mm_wdata),
        .s_axi_s2mm_wready(s_axi_s2mm_wready),
        .s_axi_s2mm_wstrb(s_axi_s2mm_wstrb),
        .s_axi_s2mm_wvalid(s_axi_s2mm_wvalid)
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
        s_axi_mm2s_awaddr = 0;
        s_axi_mm2s_awvalid = 0;
        s_axi_mm2s_wstrb = 0;
        s_axi_mm2s_wdata = 0;
        s_axi_mm2s_wvalid = 0;
        s_axi_mm2s_bready = 1;
        s_axi_mm2s_araddr = 0;
        s_axi_mm2s_arvalid = 0;
        s_axi_mm2s_rready = 1;
        s_axi_s2mm_awaddr = 0;
        s_axi_s2mm_awvalid = 0;
        s_axi_s2mm_wstrb = 0;
        s_axi_s2mm_wdata = 0;
        s_axi_s2mm_wvalid = 0;
        s_axi_s2mm_bready = 1;
        s_axi_s2mm_araddr = 0;
        s_axi_s2mm_arvalid = 0;
        s_axi_s2mm_rready = 1;
        
        // *** Reset ***
        aresetn = 0;
        #(T*5);
        aresetn = 1;
        #(T*5);
        
        // *** Multiply 1 word ***
        axi_mm2s_write(8'h00, 12'h905);    // EN = 1, WORD = 1, CONST = 5
        axi_mm2s_write(8'h04, 4'h1);       // DATA0 = 1
        #(T*5);                            // Wait until ready
        axi_s2mm_read(8'h00);              // Read ready flag
        axi_s2mm_read(8'h0c);              // Read DATA0 result
        axi_s2mm_write(8'h00, 4'h1);       // Clear ready flag
        axi_s2mm_read(8'h00);              // Read ready flag
        
        // *** Multiply 4 words ***
        axi_mm2s_write(8'h00, 12'hc08);    // EN = 1, WORD = 4, CONST = 8
        axi_mm2s_write(8'h04, 4'h1);       // DATA0 = 1
        axi_mm2s_write(8'h08, 4'h2);       // DATA1 = 2
        axi_mm2s_write(8'h0c, 4'h3);       // DATA2 = 3
        axi_mm2s_write(8'h10, 4'h4);       // DATA3 = 4
        #(T*10);                           // Wait until ready
        axi_s2mm_read(8'h00);              // Read ready flag
        axi_s2mm_read(8'h0c);              // Read DATA0 result
        axi_s2mm_read(8'h10);              // Read DATA1 result
        axi_s2mm_read(8'h14);              // Read DATA2 result
        axi_s2mm_read(8'h18);              // Read DATA3 result
        axi_s2mm_write(8'h00, 4'h1);       // Clear ready flag
        axi_s2mm_read(8'h00);              // Read ready flag
        
        // *** Read status ***
        axi_s2mm_read(8'h04);              // Read number of multiplied words
        axi_s2mm_read(8'h08);              // Read number of multiplied frames
    end

    task axi_mm2s_write;
        input [31:0] awaddr;
        input [31:0] wdata; 
        begin
            // *** Write address ***
            s_axi_mm2s_awaddr = awaddr;
            s_axi_mm2s_awvalid = 1;
            #T;
            s_axi_mm2s_awvalid = 0;
            // *** Write data ***
            s_axi_mm2s_wdata = wdata;
            s_axi_mm2s_wstrb = 4'hf;
            s_axi_mm2s_wvalid = 1; 
            #T;
            s_axi_mm2s_wvalid = 0;
            #T;
        end
    endtask
    
    task axi_mm2s_read;
        input [31:0] araddr;
        begin
            // *** Read address ***
            s_axi_mm2s_araddr = araddr;
            s_axi_mm2s_arvalid = 1;
            #T;
            s_axi_mm2s_arvalid = 0;
            #T;
        end
    endtask

    task axi_s2mm_write;
        input [31:0] awaddr;
        input [31:0] wdata; 
        begin
            // *** Write address ***
            s_axi_s2mm_awaddr = awaddr;
            s_axi_s2mm_awvalid = 1;
            #T;
            s_axi_s2mm_awvalid = 0;
            // *** Write data ***
            s_axi_s2mm_wdata = wdata;
            s_axi_s2mm_wstrb = 4'hf;
            s_axi_s2mm_wvalid = 1; 
            #T;
            s_axi_s2mm_wvalid = 0;
            #T;
        end
    endtask
    
    task axi_s2mm_read;
        input [31:0] araddr;
        begin
            // *** Read address ***
            s_axi_s2mm_araddr = araddr;
            s_axi_s2mm_arvalid = 1;
            #T;
            s_axi_s2mm_arvalid = 0;
            #T;
        end
    endtask
    
endmodule
