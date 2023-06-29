`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/13 21:08:21
// Design Name: 
// Module Name: srio_pcie_bridge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module srio_pcie_bridge#(
    parameter [15:0] C_SRIO_DEV_ID = 16'hF201,
    parameter [15:0] C_SRIO_DEST_ID = 16'h7801,
    parameter AXIL_DW = 32,
    parameter AXIL_AW = 7,
    parameter USR_IRQ_DW = 16
    )(
    input aclk,
    input aresetn,

    // msi irq from user designed peripheral
    input msi_irq_in, // single cycle enable signal, valied when msi_irq_busy = 1'b0
    input [31:0] msi_info_in,
    output msi_irq_busy,

    output db_irq_out,
    output [15:0] db_info_out,

// ireq signals
    (* mark_debug = "true" *) output m_axis_ireq_tvalid,
    (* mark_debug = "true" *) input m_axis_ireq_tready,
    (* mark_debug = "true" *) output [63:0] m_axis_ireq_tdata,
    (* mark_debug = "true" *) output [7:0] m_axis_ireq_tkeep,
    (* mark_debug = "true" *) output m_axis_ireq_tlast,
    (* mark_debug = "true" *) output [31:0] m_axis_ireq_tuser,
// end of ireq signals

// iresp signals
    (* mark_debug = "true" *) input s_axis_iresp_tvalid,
    (* mark_debug = "true" *) output s_axis_iresp_tready,
    (* mark_debug = "true" *) input [63:0] s_axis_iresp_tdata,
    (* mark_debug = "true" *) input [7:0] s_axis_iresp_tkeep,
    (* mark_debug = "true" *) input s_axis_iresp_tlast,
    (* mark_debug = "true" *) input [31:0] s_axis_iresp_tuser,
// end of iresp signals

// treq signals
    (* mark_debug = "true" *) input s_axis_treq_tvalid,
    (* mark_debug = "true" *) output s_axis_treq_tready,
    (* mark_debug = "true" *) input [63:0] s_axis_treq_tdata,
    (* mark_debug = "true" *) input [7:0] s_axis_treq_tkeep,
    (* mark_debug = "true" *) input s_axis_treq_tlast,
    (* mark_debug = "true" *) input [31:0] s_axis_treq_tuser,
// end of treq signals

// tresp signals
    (* mark_debug = "true" *) output m_axis_tresp_tvalid,
    (* mark_debug = "true" *) input m_axis_tresp_tready,
    (* mark_debug = "true" *) output [63:0] m_axis_tresp_tdata,
    (* mark_debug = "true" *) output [7:0] m_axis_tresp_tkeep,
    (* mark_debug = "true" *) output m_axis_tresp_tlast,
    (* mark_debug = "true" *) output [31:0] m_axis_tresp_tuser,
// end of tresp signals

// h2c stream
    (* mark_debug = "true" *) input s_axis_h2c_tvalid,
    (* mark_debug = "true" *) output s_axis_h2c_tready,
    (* mark_debug = "true" *) input [63:0] s_axis_h2c_tdata,
    (* mark_debug = "true" *) input [7:0] s_axis_h2c_tkeep,
    (* mark_debug = "true" *) input s_axis_h2c_tlast,
// end of h2c stream

// c2h stream
    (* mark_debug = "true" *) output m_axis_c2h_tvalid,
    (* mark_debug = "true" *) input m_axis_c2h_tready,
    (* mark_debug = "true" *) output [63:0] m_axis_c2h_tdata,
    (* mark_debug = "true" *) output [7:0] m_axis_c2h_tkeep,
    (* mark_debug = "true" *) output m_axis_c2h_tlast,
// end of c2h stream

// usr_irq signals
    (* mark_debug = "true" *) output [USR_IRQ_DW-1:0] usr_irq_req,
    (* mark_debug = "true" *) input [USR_IRQ_DW-1:0] usr_irq_ack,
// end of usr_irq signals

// AXI4-Lite control signals
    input [2:0] s_axil_awprot,
    input [3:0] s_axil_wstrb,
    input [2:0] s_axil_arprot,
    output [1:0] s_axil_rresp,

    output [1:0] s_axil_bresp,
    output s_axil_bvalid,
    input s_axil_bready,

    (* mark_debug = "true" *) input [AXIL_AW-1:0] s_axil_awaddr,
    (* mark_debug = "true" *) input s_axil_awvalid,
    (* mark_debug = "true" *) output s_axil_awready,

    (* mark_debug = "true" *) input [AXIL_DW-1:0] s_axil_wdata,
    (* mark_debug = "true" *) input s_axil_wvalid,
    (* mark_debug = "true" *) output s_axil_wready,

    (* mark_debug = "true" *) input [AXIL_AW-1:0] s_axil_araddr,
    (* mark_debug = "true" *) input s_axil_arvalid,
    (* mark_debug = "true" *) output s_axil_arready,

    (* mark_debug = "true" *) output [AXIL_DW-1:0] s_axil_rdata,
    (* mark_debug = "true" *) output s_axil_rvalid,
    (* mark_debug = "true" *) input s_axil_rready,
// end of AXI4-Lite control signals

// axi master interface
    // output [C_m_axi_AWUSER_WIDTH-1 : 0] m_axi_awuser,
    // output [C_m_axi_WUSER_WIDTH-1 : 0] m_axi_wuser,
    // input [C_m_axi_BUSER_WIDTH-1 : 0] m_axi_buser,
    // output [C_m_axi_ARUSER_WIDTH-1 : 0] m_axi_aruser,
    // input [C_m_axi_RUSER_WIDTH-1 : 0] m_axi_ruser,

    output [2 : 0] m_axi_awsize,
    output [1 : 0] m_axi_awburst,
    output m_axi_awlock,
    output [3 : 0] m_axi_awcache,
    output [2 : 0] m_axi_awprot,
    output [3 : 0] m_axi_awqos,
    output [7 : 0] m_axi_wstrb,
    output [2 : 0] m_axi_arsize,
    output [1 : 0] m_axi_arburst,
    output m_axi_arlock,
    output [3 : 0] m_axi_arcache,
    output [2 : 0] m_axi_arprot,
    output [3 : 0] m_axi_arqos,
    output m_axi_bready,
    output [3:0] m_axi_awid,
    output [3:0] m_axi_arid,
    (* mark_debug = "true" *) input [1 : 0] m_axi_rresp,
    (* mark_debug = "true" *) input [1 : 0] m_axi_bresp,
    (* mark_debug = "true" *) input m_axi_bvalid,
    (* mark_debug = "true" *) input [3:0] m_axi_bid,
    (* mark_debug = "true" *) input [3:0] m_axi_rid,
    // aw
    (* mark_debug = "true" *) output [31 : 0] m_axi_awaddr,
    (* mark_debug = "true" *) output [7 : 0] m_axi_awlen,
    (* mark_debug = "true" *) output m_axi_awvalid,
    (* mark_debug = "true" *) input m_axi_awready,
    // w
    (* mark_debug = "true" *) output [63 : 0] m_axi_wdata,
    (* mark_debug = "true" *) output m_axi_wlast,
    (* mark_debug = "true" *) output m_axi_wvalid,
    (* mark_debug = "true" *) input m_axi_wready,
    // ar
    (* mark_debug = "true" *) output [31 : 0] m_axi_araddr,
    (* mark_debug = "true" *) output [7 : 0] m_axi_arlen,
    (* mark_debug = "true" *) output m_axi_arvalid,
    (* mark_debug = "true" *) input m_axi_arready,
    // r
    (* mark_debug = "true" *) input [63 : 0] m_axi_rdata,
    (* mark_debug = "true" *) input m_axi_rlast,
    (* mark_debug = "true" *) input m_axi_rvalid,
    (* mark_debug = "true" *) output m_axi_rready
// end of axi master interface
    );

// regs definition
    reg [AXIL_DW - 1:0] IDENTIFIER;
    reg [AXIL_DW - 1:0] SRIO_CSR;
    reg [AXIL_DW - 1:0] SRIO_MODE;
    reg [AXIL_DW - 1:0] SW_SIZE;
    reg [AXIL_DW - 1:0] SW_DST;
    reg [AXIL_DW - 1:0] SW_SRC;
    reg [AXIL_DW - 1:0] DB_TXINFO;
    reg [AXIL_DW - 1:0] MSI_CSR;
    reg [AXIL_DW - 1:0] MSI_INFO[15:0];

    (* mark_debug = "true" *) wire db_start; // hold until db_done
    (* mark_debug = "true" *) wire sw_start; // hold until sw_done
    (* mark_debug = "true" *) wire db_nomsi;
    (* mark_debug = "true" *) wire sw_mode;
    (* mark_debug = "true" *) wire nw_mode;
    (* mark_debug = "true" *) wire [26:0] sw_size;
    (* mark_debug = "true" *) wire [31:0] sw_dst_base_addr;
    (* mark_debug = "true" *) wire [31:0] sw_src_base_addr;
    (* mark_debug = "true" *) wire [15:0] db_info_normal;
    (* mark_debug = "true" *) wire [15:0] db_info_sw;
    (* mark_debug = "true" *) wire [15:0] msi_irq;
    (* mark_debug = "true" *) wire [15:0] msi_err;
// end of regs definition

    wire db_done;
    wire sw_done;

    wire db_irq;
    wire [15:0] db_info;

    wire nw_err_cross;
    wire nw_err_unalign;

    wire sw_err_src_unalign;
    wire sw_err_dst_unalign;

// axil signals definition
    reg axil_awready;
    reg axil_wready;
    reg [1:0] axil_bresp;
    reg axil_bvalid;

    reg [AXIL_AW-1:0] axil_araddr_q;
    reg axil_arready;
    reg axil_rvalid;
    reg [1:0] axil_rresp;
    reg [31:0] axil_rdata;
    reg axil_rlast;

    wire handshake_aw;
    wire handshake_w;
    wire handshake_b;
    wire handshake_ar;
    wire handshake_r;

    reg allow_aw;
    wire write_en;
// end of axil signals definition

// regs assignments
    assign db_start = SRIO_CSR[0];
    assign sw_start = SRIO_CSR[1];
    assign db_nomsi = SRIO_MODE[0];
    assign sw_mode = SRIO_MODE[1];
    assign nw_mode = SRIO_MODE[2];
    assign sw_size = SW_SIZE[26:0];
    assign sw_dst_base_addr = SW_DST;
    assign sw_src_base_addr = SW_SRC;
    assign db_info_normal = DB_TXINFO[15:0];
    assign db_info_sw = DB_TXINFO[31:16];
    assign msi_irq = MSI_CSR[15:0];
    assign msi_err = MSI_CSR[31:16];
// end of regs assignments

// axil assignlents
    assign s_axil_awready = axil_awready;
    assign s_axil_wready = axil_wready;
    assign s_axil_bresp = axil_bresp;
    assign s_axil_bvalid = axil_bvalid;

    assign s_axil_arready = axil_arready;
    assign s_axil_rresp = axil_rresp;
    assign s_axil_rvalid = axil_rvalid;
    assign s_axil_rdata = axil_rdata;
    assign s_axil_rlast = axil_rlast; 

    assign handshake_aw = s_axil_awvalid & s_axil_awready;
    assign handshake_w = s_axil_wvalid & s_axil_wready;
    assign handshake_b = s_axil_bvalid & s_axil_bready;
    assign handshake_ar = s_axil_arvalid & s_axil_arready;
    assign handshake_r = s_axil_rvalid & s_axil_rready;

    // write regs
    assign write_en = handshake_aw & handshake_w;
// end of axil assignments

// axi master assignments
    assign m_axi_awsize = 3'b011; // awsize = 8 bytes
    assign m_axi_awburst = 2'b01; // INCR
    assign m_axi_awlock = 1'b0;
    assign m_axi_awcache = 4'b0011; // Normal Non-cacheable Bufferable
    assign m_axi_awprot = 3'b010;
    assign m_axi_awqos = 4'b0;
    assign m_axi_wstrb = 8'hFF;
    assign m_axi_arsize = 3'b011;
    assign m_axi_arburst = 2'b01;
    assign m_axi_arlock = 1'b0;
    assign m_axi_arcache = 4'b0011; // Normal Non-cacheable Bufferable
    assign m_axi_arprot = 3'b010;
    assign m_axi_arqos = 4'b0;
    assign m_axi_bready = 1'b1;
    assign m_axi_awid = 4'd1;
    assign m_axi_arid = 4'd1;
// end of axi master assignments

    assign msi_irq_busy = msi_irq[1];

    assign db_irq_out = db_irq;
    assign db_info_out = db_info;

    assign usr_irq_req = msi_irq[USR_IRQ_DW - 1:0];

// axil signals
    integer i;
    // regs write
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin 
            IDENTIFIER <= 32'h10370918;
            SRIO_CSR <= 'b0;
            SRIO_MODE <= 'b0;
            SW_SIZE <= 'b0;
            SW_DST <= 'b0;
            SW_SRC <= 'b0;
            DB_TXINFO <= 'b0;
            MSI_CSR <= 'b0;
            for(i = 0; i < 16; i = i + 1) begin
                MSI_INFO[i] <= 'b0;
            end
        end
        else begin
            // write regs
            if(write_en) begin 
                // MSI_INFO
                if(s_axil_awaddr[AXIL_AW-1:2] >= 'd8 && s_axil_awaddr[AXIL_AW-1:2] <= 'd23) begin
                    for(i = 0; i < 4; i = i + 1) begin
                        if(s_axil_wstrb[i]) MSI_INFO[s_axil_awaddr[AXIL_AW-1:2] - 'd8][(i*8)+:8] <= s_axil_wdata[(i*8)+:8]; 
                    end
                end
                else begin
                    case (s_axil_awaddr[AXIL_AW-1:2])
                        // SRIO_CSR
                        'd1: begin
                            // try to start db or sw
                            if(s_axil_wstrb[0] && (s_axil_wdata[0] || s_axil_wdata[1])) begin
                                // usr can start db when db is not busy
                                if(!SRIO_CSR[0]) begin
                                    SRIO_CSR[0] <= s_axil_wdata[0];
                                end
                                else begin
                                    // error! try to start db when db busy
                                    if(s_axil_wdata[0]) begin
                                        SRIO_CSR[16] <= 1'b1;
                                    end
                                end
                                // usr can start sw when sw is not busy
                                if(!SRIO_CSR[1]) begin
                                    SRIO_CSR[1] <= s_axil_wdata[1];
                                end
                                else begin
                                    // error! try to start sw when sw busy
                                    if(s_axil_wdata[1]) begin
                                        SRIO_CSR[17] <= 1'b1;
                                    end
                                end
                            end
                            else if(s_axil_wstrb[2]) begin
                                /*  | num  | function 
                                 *  | 16   | db error, try to tx db when last db is not tx
                                 *  | 17   | sw error, try to tx sw when last sw is not sw
                                 *  | 18   | nw error, nw destination address corss 4k boundary
                                 *  | 19   | nw error, nw address is not align with 8 bytes
                                 *  | 20   | sw error, sw source address is not align with 256 bytes
                                 *  | 21   | sw error, sw destination address is not align with 256 bytes 
                                */
                                for(i = 16; i < 24; i = i + 1) begin
                                    if(s_axil_wdata[i]) begin
                                        SRIO_CSR[i] <= 1'b0;
                                    end
                                end
                            end
                        end
                        // SRIO_MODE
                        'd2: begin
                            if(s_axil_wstrb[0]) begin
                                SRIO_MODE[2:0] <= s_axil_wdata[2:0];
                            end
                        end
                        // SW_SIZE
                        'd3: begin
                            for(i = 0; i < 3; i = i + 1) begin
                                if(s_axil_wstrb[i]) SW_SIZE[(i*8)+:8] <= s_axil_wdata[(i*8)+:8]; 
                            end
                            if(s_axil_wstrb[3]) begin
                                SW_SIZE[26:24] <= s_axil_wdata[26:24];
                            end
                        end
                        // SW_DST
                        'd4: begin
                            for(i = 0; i < 4; i = i + 1) begin
                                if(s_axil_wstrb[i]) SW_DST[(i*8)+:8] <= s_axil_wdata[(i*8)+:8]; 
                            end
                        end
                        // SW_SRC
                        'd5: begin
                            for(i = 0; i < 4; i = i + 1) begin
                                if(s_axil_wstrb[i]) SW_SRC[(i*8)+:8] <= s_axil_wdata[(i*8)+:8]; 
                            end
                        end
                        // DB_TXINFO
                        'd6: begin
                            for(i = 0; i < 4; i = i + 1) begin
                                if(s_axil_wstrb[i]) DB_TXINFO[(i*8)+:8] <= s_axil_wdata[(i*8)+:8]; 
                            end
                        end
                        // MSI_CSR
                        'd7: begin
                            // 0 for db to msi
                            // 1 for msi_irq_in
                            // try to start msi_irq [7:2]
                            if(s_axil_wstrb[0] && (|s_axil_wdata[7:2])) begin
                                for(i = 2; i < 8; i = i + 1) begin
                                    if(!MSI_CSR[i]) begin
                                        MSI_CSR[i] <= s_axil_wdata[i];
                                    end
                                    else begin
                                        // try to start msi_irq when msi_irq is busy
                                        if(s_axil_wdata[i]) begin
                                            MSI_CSR[16 + i] <= 1'b1;
                                        end
                                    end
                                end
                            end
                            else if(s_axil_wstrb[2]) begin
                                for(i = 16; i < 24; i = i + 1) begin
                                    if(s_axil_wdata[i]) begin
                                        MSI_CSR[i] <= 1'b0;
                                    end
                                end
                            end
                            // try to start msi_irq [15:8]
                            if(s_axil_wstrb[1] && (|s_axil_wdata[15:8])) begin
                                for(i = 8; i < 16; i = i + 1) begin
                                    if(!MSI_CSR[i]) begin
                                        MSI_CSR[i] <= s_axil_wdata[i];
                                    end
                                    else begin
                                        // try to start msi_irq when msi_irq is busy
                                        if(s_axil_wdata[i]) begin
                                            MSI_CSR[16 + i] <= 1'b1;
                                        end
                                    end
                                end
                            end
                            else if(s_axil_wstrb[3]) begin
                                for(i = 24; i < 32; i = i + 1) begin
                                    if(s_axil_wdata[i]) begin
                                        MSI_CSR[i] <= 1'b0;
                                    end
                                end
                            end
                        end
                        default: begin
                        end
                    endcase
                end
            end
            else begin
                // clear db busy
                if(db_done) begin
                    SRIO_CSR[0] <= 1'b0;
                end
                // clear sw busy
                if(sw_done) begin
                    SRIO_CSR[1] <= 1'b0;
                end
                if(nw_err_cross) begin
                    SRIO_CSR[18] <= 1'b1;
                end
                if(nw_err_unalign) begin
                    SRIO_CSR[19] <= 1'b1;
                end
                if(sw_err_src_unalign) begin
                    SRIO_CSR[20] <= 1'b1;
                end
                if(sw_err_dst_unalign) begin
                    SRIO_CSR[21] <= 1'b1;
                end
                // db to msi
                if(db_irq && !db_nomsi) begin
                    if(!MSI_CSR[0]) begin
                        MSI_CSR[0] <= 1'b1;
                        MSI_INFO[0] <= {16'd0, db_info};
                    end
                    else begin
                        // try to start msi_irq when msi_irq is busy
                        MSI_CSR[16] <= 1'b1;
                    end
                end
                else begin
                    if(handshake_r && axil_araddr_q[AXIL_AW-1:2] == 'd8) begin
                        MSI_CSR[0] <= 1'b0;
                    end
                end
                // msi_irq_in
                if(msi_irq_in) begin
                    if(!MSI_CSR[1]) begin
                        MSI_CSR[1] <= 1'b1;
                        MSI_INFO[1] <= msi_info_in;
                    end
                    else begin
                        // try to start msi_irq when msi_irq is busy
                        MSI_CSR[17] <= 1'b1;
                    end
                end
                else begin
                    if(handshake_r && axil_araddr_q[AXIL_AW-1:2] == 'd9) begin
                        MSI_CSR[1] <= 1'b0;
                    end
                end
            end
        end
    end

    // regs read rvalid rresp rdata
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin 
            axil_rvalid <= 1'b0;
            axil_rresp <= 2'b0;
            axil_rdata <= 'b0;
        end
        else begin 
            if(!axil_rvalid && handshake_ar) begin
                axil_rvalid <= 1'b1;
                if(s_axil_araddr[AXIL_AW-1:2] >= 'd8 && s_axil_araddr[AXIL_AW-1:2] <= 'd23) begin
                    axil_rdata <= MSI_INFO[s_axil_araddr[AXIL_AW-1:2] - 'd8];
                end
                else begin
                    case (s_axil_araddr[AXIL_AW-1:2])
                        'd0: begin
                            axil_rdata <= IDENTIFIER;
                        end
                        'd1: begin
                            axil_rdata <= SRIO_CSR;
                        end
                        'd2: begin
                            axil_rdata <= SRIO_MODE;
                        end
                        'd3: begin
                            axil_rdata <= SW_SIZE;
                        end
                        'd4: begin
                            axil_rdata <= SW_DST;
                        end
                        'd5: begin
                            axil_rdata <= SW_SRC;
                        end
                        'd6: begin
                            axil_rdata <= DB_TXINFO;
                        end
                        'd7: begin
                            axil_rdata <= MSI_CSR;
                        end
                        default: begin
                        end
                    endcase
                end
            end
            else if(handshake_r) begin
                axil_rvalid <= 1'b0;
                axil_rdata <= 'b0;
            end
        end
    end

    // axil_araddr_q
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            axil_araddr_q <= 'b0;
        end
        else begin
            if(s_axil_arvalid) begin
                axil_araddr_q <= s_axil_araddr;
            end
            else if(handshake_r) begin
                axil_araddr_q <= 'b0;
            end
        end
    end

    // allow_aw
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            allow_aw <= 1'b1;
        end
        else begin
            if(s_axil_awvalid && s_axil_wvalid && allow_aw) begin 
                allow_aw <= 1'b0;
            end
            else if(handshake_b) begin
                allow_aw <= 1'b1;
            end
        end
    end

    // awready
    always @(posedge aclk or negedge aresetn) begin 
        if (!aresetn) begin 
            axil_awready <= 1'b0;
        end 
        else begin
            if(!axil_awready && s_axil_awvalid && s_axil_wvalid && allow_aw) begin 
                axil_awready <= 1'b1;
            end
            else begin // make awready stay only one cycle
                axil_awready <= 1'b0;
            end
        end
    end

    // wready
    always @(posedge aclk or negedge aresetn) begin 
        if(!aresetn) begin 
            axil_wready <= 1'b0;
        end
        else begin 
            if(!axil_wready && s_axil_awvalid && s_axil_wvalid && allow_aw) begin 
                axil_wready <= 1'b1;
            end
            else begin 
                axil_wready <= 1'b0;
            end
        end
    end

    // s_axil_bresp
    // s_axil_bvalid
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            axil_bresp <= 2'b0;
            axil_bvalid <= 1'b0;
        end
        else begin
            if(!axil_bvalid && write_en) begin
                axil_bvalid <= 1'b1;
            end
            else if(handshake_b) begin
                axil_bvalid <= 1'b0;
            end
        end
    end

    // s_axil_arready
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin 
            axil_arready <= 1'b0;
        end
        else begin 
            if(!axil_arready && !axil_rvalid && s_axil_arvalid) begin 
                axil_arready <= 1'b1;
            end
            else begin
                axil_arready <= 1'b0;
            end
        end
    end
// end of axil signals

// srio_tx_mgr_inst 
    srio_tx_manager #(
        .C_SRIO_DEV_ID(C_SRIO_DEV_ID),
        .C_SRIO_DEST_ID(C_SRIO_DEST_ID)
    )
    srio_tx_mgr_inst(
        .aclk(aclk),                                // input aclk,
        .aresetn(aresetn),                          // input aresetn,

        .db_start(db_start),                        // input db_start,
        .db_info_normal(db_info_normal),            // input [15:0] db_info_normal,
        .db_info_sw(db_info_sw),                    // input [15:0] db_info_sw,
        .db_done(db_done),                          // output db_done,

        .sw_start(sw_start),                        // input sw_start,
        .sw_mode(sw_mode),                          // input sw_mode,
        .sw_size(sw_size),                          // input [26:0] sw_size,
        .sw_dst_base_addr(sw_dst_base_addr),        // input [31:0] sw_dst_base_addr,
        .sw_src_base_addr(sw_src_base_addr),        // input [31:0] sw_src_base_addr,
        .sw_done(sw_done),                          // output sw_done,

        .sw_err_src_unalign(sw_err_src_unalign),    // output sw_err_src_unalign,
        .sw_err_dst_unalign(sw_err_dst_unalign),    // output sw_err_dst_unalign,

        .m_axis_ireq_tvalid(m_axis_ireq_tvalid),    // output m_axis_ireq_tvalid,
        .m_axis_ireq_tready(m_axis_ireq_tready),    // input m_axis_ireq_tready,
        .m_axis_ireq_tdata(m_axis_ireq_tdata),      // output [63:0] m_axis_ireq_tdata,
        .m_axis_ireq_tkeep(m_axis_ireq_tkeep),      // output [7:0] m_axis_ireq_tkeep,
        .m_axis_ireq_tlast(m_axis_ireq_tlast),      // output m_axis_ireq_tlast,
        .m_axis_ireq_tuser(m_axis_ireq_tuser),      // output [31:0] m_axis_ireq_tuser,

        .s_axis_iresp_tvalid(s_axis_iresp_tvalid),  // input s_axis_iresp_tvalid,
        .s_axis_iresp_tready(s_axis_iresp_tready),  // output s_axis_iresp_tready,
        .s_axis_iresp_tdata(s_axis_iresp_tdata),    // input [63:0] s_axis_iresp_tdata,
        .s_axis_iresp_tkeep(s_axis_iresp_tkeep),    // input [7:0] s_axis_iresp_tkeep,
        .s_axis_iresp_tlast(s_axis_iresp_tlast),    // input s_axis_iresp_tlast,
        .s_axis_iresp_tuser(s_axis_iresp_tuser),    // input [31:0] s_axis_iresp_tuser,

        .s_axis_h2c_tvalid(s_axis_h2c_tvalid),      // input s_axis_h2c_tvalid,
        .s_axis_h2c_tready(s_axis_h2c_tready),      // output s_axis_h2c_tready,
        .s_axis_h2c_tdata(s_axis_h2c_tdata),        // input [63:0] s_axis_h2c_tdata,
        .s_axis_h2c_tkeep(s_axis_h2c_tkeep),        // input [7:0] s_axis_h2c_tkeep,
        .s_axis_h2c_tlast(s_axis_h2c_tlast),        // input s_axis_h2c_tlast,

        .m_axi_araddr(m_axi_araddr),                // output [31 : 0] m_axi_araddr,
        .m_axi_arlen(m_axi_arlen),                  // output [7 : 0] m_axi_arlen,
        .m_axi_arvalid(m_axi_arvalid),              // output m_axi_arvalid,
        .m_axi_arready(m_axi_arready),              // input m_axi_arready,

        .m_axi_rdata(m_axi_rdata),                  // input [63 : 0] m_axi_rdata,
        .m_axi_rlast(m_axi_rlast),                  // input m_axi_rlast,
        .m_axi_rvalid(m_axi_rvalid),                // input m_axi_rvalid,
        .m_axi_rready(m_axi_rready)                 // output m_axi_rready
    );
// end of srio_tx_mgr_inst 
    
// srio_rx_mgr_inst
    srio_rx_manager #(
        .C_SRIO_DEV_ID(C_SRIO_DEV_ID),
        .C_SRIO_DEST_ID(C_SRIO_DEST_ID)
    )
    srio_rx_mgr_isnt(
        .aclk(aclk),                                // input aclk,
        .aresetn(aresetn),                          // input aresetn,

        .db_irq(db_irq),                            // output db_irq,
        .db_info(db_info),                          // output [15:0] db_info,

        .nw_mode(nw_mode),                          // input nw_mode,
        .nw_err_cross(nw_err_cross),                // output nw_err,
        .nw_err_unalign(nw_err_unalign),            // output nw_err_noalign,

        .s_axis_treq_tvalid(s_axis_treq_tvalid),    // input s_axis_treq_tvalid,
        .s_axis_treq_tready(s_axis_treq_tready),    // output s_axis_treq_tready,
        .s_axis_treq_tdata(s_axis_treq_tdata),      // input [63:0] s_axis_treq_tdata,
        .s_axis_treq_tkeep(s_axis_treq_tkeep),      // input [7:0] s_axis_treq_tkeep,
        .s_axis_treq_tlast(s_axis_treq_tlast),      // input s_axis_treq_tlast,
        .s_axis_treq_tuser(s_axis_treq_tuser),      // input [31:0] s_axis_treq_tuser,

        .m_axis_tresp_tvalid(m_axis_tresp_tvalid),  // output m_axis_tresp_tvalid,
        .m_axis_tresp_tready(m_axis_tresp_tready),  // input m_axis_tresp_tready,
        .m_axis_tresp_tdata(m_axis_tresp_tdata),    // output [63:0] m_axis_tresp_tdata,
        .m_axis_tresp_tkeep(m_axis_tresp_tkeep),    // output [7:0] m_axis_tresp_tkeep,
        .m_axis_tresp_tlast(m_axis_tresp_tlast),    // output m_axis_tresp_tlast,
        .m_axis_tresp_tuser(m_axis_tresp_tuser),    // output [31:0] m_axis_tresp_tuser,

        .m_axis_c2h_tvalid(m_axis_c2h_tvalid),      // output m_axis_c2h_tvalid,
        .m_axis_c2h_tready(m_axis_c2h_tready),      // input m_axis_c2h_tready,
        .m_axis_c2h_tdata(m_axis_c2h_tdata),        // output [63:0] m_axis_c2h_tdata,
        .m_axis_c2h_tkeep(m_axis_c2h_tkeep),        // output [7:0] m_axis_c2h_tkeep,
        .m_axis_c2h_tlast(m_axis_c2h_tlast),        // output m_axis_c2h_tlast,

        .m_axi_awaddr(m_axi_awaddr),                // output [31 : 0] m_axi_awaddr,
        .m_axi_awlen(m_axi_awlen),                  // output [7 : 0] m_axi_awlen,
        .m_axi_awvalid(m_axi_awvalid),              // output m_axi_awvalid,
        .m_axi_awready(m_axi_awready),              // input m_axi_awready,

        .m_axi_wdata(m_axi_wdata),                  // output [63 : 0] m_axi_wdata,
        .m_axi_wlast(m_axi_wlast),                  // output m_axi_wlast,
        .m_axi_wvalid(m_axi_wvalid),                // output m_axi_wvalid,
        .m_axi_wready(m_axi_wready)                 // input m_axi_wready
    );
// end of srio_rx_mgr_inst
endmodule
