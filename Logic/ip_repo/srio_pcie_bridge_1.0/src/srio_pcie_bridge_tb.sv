`timescale 1ns / 1ps
`include "common.sv"
// `define EXTIN_TEST
// `define TXDB_TEST
`define TXSW_TEST
// `define RXDB_TEST
// `define RXNW_TEST

module srio_pcie_bridge_tb#(
    parameter [15:0] C_SRIO_DEV_ID = 16'hF201,
    parameter [15:0] C_SRIO_DEST_ID = 16'h7801,
    parameter AXIL_DW = 32,
    parameter AXIL_AW = 7,
    parameter USR_IRQ_DW = 16
    );

    localparam [1:0] prio = 2'b01;
    localparam [0:0] CRF = 1'b0;
    localparam [7:0] DOORB = 8'hA0;
    localparam [7:0] RESP_NODATA = 8'hD0;
    localparam [7:0] TID = 8'h55;
    

    import SimSrcGen::*;
    logic aclk;
    initial GenClk(aclk, 1, 6.4); // 156.25Mhz

    logic aresetn;
    initial GenArst(aclk, aresetn, 2, 3);

// interface signal definition
    logic msi_irq_in;
    logic [31:0] msi_info_in;
    logic msi_irq_busy;

    logic db_irq_out;
    logic [15:0] db_info_out;

    // ireq signals
    logic m_axis_ireq_tvalid;
    logic m_axis_ireq_tready;
    logic [63:0] m_axis_ireq_tdata;
    logic [7:0] m_axis_ireq_tkeep;
    logic m_axis_ireq_tlast;
    logic [31:0] m_axis_ireq_tuser;

    // iresp
    logic s_axis_iresp_tvalid;
    logic s_axis_iresp_tready;
    logic [63:0] s_axis_iresp_tdata;
    logic [7:0] s_axis_iresp_tkeep;
    logic s_axis_iresp_tlast;
    logic [31:0] s_axis_iresp_tuser;

    // treq signals
    logic s_axis_treq_tvalid;
    logic s_axis_treq_tready;
    logic [63:0] s_axis_treq_tdata;
    logic [7:0] s_axis_treq_tkeep;
    logic s_axis_treq_tlast;
    logic [31:0] s_axis_treq_tuser;

    // tresp signals
    logic m_axis_tresp_tvalid;
    logic m_axis_tresp_tready;
    logic [63:0] m_axis_tresp_tdata;
    logic [7:0] m_axis_tresp_tkeep;
    logic m_axis_tresp_tlast;
    logic [31:0] m_axis_tresp_tuser;

    // h2c stream
    logic s_axis_h2c_tvalid;
    logic s_axis_h2c_tready;
    logic [63:0] s_axis_h2c_tdata;
    logic [7:0] s_axis_h2c_tkeep;
    logic s_axis_h2c_tlast;

    // c2h stream
    logic m_axis_c2h_tvalid;
    logic m_axis_c2h_tready;
    logic [63:0] m_axis_c2h_tdata;
    logic [7:0] m_axis_c2h_tkeep;
    logic m_axis_c2h_tlast;

    // usr_irq signals
    logic [USR_IRQ_DW-1:0] usr_irq_req;
    logic [USR_IRQ_DW-1:0] usr_irq_ack;

    // axi_lite
    logic [AXIL_AW-1:0] s_axil_awaddr;
    logic [2:0] s_axil_awprot;
    logic s_axil_awvalid;
    logic s_axil_awready;

    logic [AXIL_DW-1:0] s_axil_wdata;
    logic [3:0] s_axil_wstrb;
    logic s_axil_wvalid;
    logic s_axil_wready;

    logic [1:0] s_axil_bresp;
    logic s_axil_bvalid;
    logic s_axil_bready;

    logic [AXIL_AW-1:0] s_axil_araddr;
    logic [2:0] s_axil_arprot;
    logic s_axil_arvalid;
    logic s_axil_arready;

    logic [AXIL_DW-1:0] s_axil_rdata;
    logic [1:0] s_axil_rresp;
    logic s_axil_rvalid;
    logic s_axil_rready;

    // m_axi
    logic [2 : 0] m_axi_awsize;
    logic [1 : 0] m_axi_awburst;
    logic m_axi_awlock;
    logic [3 : 0] m_axi_awcache;
    logic [2 : 0] m_axi_awprot;
    logic [3 : 0] m_axi_awqos;
    logic [7 : 0] m_axi_wstrb;
    logic [2 : 0] m_axi_arsize;
    logic [1 : 0] m_axi_arburst;
    logic m_axi_arlock;
    logic [3 : 0] m_axi_arcache;
    logic [2 : 0] m_axi_arprot;
    logic [3 : 0] m_axi_arqos;
    logic m_axi_bready;
    logic [3:0] m_axi_awid;
    logic [3:0] m_axi_arid;
    logic [1 : 0] m_axi_rresp;
    logic [1 : 0] m_axi_bresp;
    logic m_axi_bvalid;
    logic [3:0] m_axi_bid;
    logic [3:0] m_axi_rid;

    logic [31 : 0] m_axi_awaddr;
    logic [7 : 0] m_axi_awlen;
    logic m_axi_awvalid;
    logic m_axi_awready;

    logic [63 : 0] m_axi_wdata;
    logic m_axi_wlast;
    logic m_axi_wvalid;
    logic m_axi_wready;

    logic [31 : 0] m_axi_araddr;
    logic [7 : 0] m_axi_arlen;
    logic m_axi_arvalid;
    logic m_axi_arready;

    logic [63 : 0] m_axi_rdata;
    logic m_axi_rlast;
    logic m_axi_rvalid;
    logic m_axi_rready;
// end of interface signal definition

    logic [31:0] cnt;
    logic handshake_axil_ar;
    logic handshake_axil_aw;
    logic handshake_axil_w;
    logic handshake_axil_r;

    logic handshake_maxi_ar;
    logic handshake_maxi_aw;
    logic handshake_maxi_w;
    logic handshake_maxi_r;

    logic handshake_treq;
    logic handshake_ireq;
    logic handshake_iresp;
    logic handshake_tresp;

    logic handshake_h2c;

    logic [7:0] treq_handshake_cnt;
 
// random ready signal
    // input m_axis_ireq_tready,
    // input s_axil_rready,
    // input m_axis_tresp_tready,
    // input m_axis_c2h_tready,
    // input m_axi_awready,
    // input m_axi_wready,
    // input m_axi_arready,
    always_ff@(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            m_axis_ireq_tready <= 1'b0;
            s_axil_rready <= 1'b0;
            m_axis_tresp_tready <= 1'b0;
            m_axis_c2h_tready <= 1'b0;
            m_axi_awready <= 1'b0;
            m_axi_wready <= 1'b0;
            m_axi_arready <= 1'b0;
        end
        else begin
            m_axis_ireq_tready <= {$random} % 2;
            s_axil_rready <= {$random} % 2;
            m_axis_tresp_tready <= {$random} % 2;
            m_axis_c2h_tready <= {$random} % 2;
            m_axi_awready <= {$random} % 2;
            m_axi_wready <= {$random} % 2;
            m_axi_arready <= {$random} % 2;
        end
    end
// end of random signal

// constant signal
    // input [USR_IRQ_DW-1:0] usr_irq_ack,
    assign usr_irq_ack = 'b0;
    // input [2:0] s_axil_awprot,
    assign s_axil_awprot = 3'b000;
    // input [2:0] s_axil_arprot,
    assign s_axil_arprot = 3'b000;
    // input [3:0] s_axil_wstrb,
    assign s_axil_wstrb = 4'hF;
    // input s_axil_bready,
    assign s_axil_bready = 1'b1;
    // input [1 : 0] m_axi_rresp,
    assign m_axi_rresp = 2'b00;
    // input [1 : 0] m_axi_bresp,
    assign m_axi_bresp = 2'b00;
    // input m_axi_bvalid,
    assign m_axi_bvalid = 1'b0;
    // input [3:0] m_axi_bid,
    assign m_axi_bid = 'b0;
    // input [3:0] m_axi_rid,
    assign m_axi_rid = 'b0;
// end of constant signal 

// assignments
    assign handshake_axil_ar = s_axil_arvalid & s_axil_arready;
    assign handshake_axil_aw = s_axil_awvalid & s_axil_awready;
    assign handshake_axil_w = s_axil_wvalid & s_axil_wready;
    assign handshake_axil_r = s_axil_rvalid & s_axil_rready;

    assign handshake_maxi_ar = m_axi_arvalid & m_axi_arready;
    assign handshake_maxi_aw = m_axi_awvalid & m_axi_awready;
    assign handshake_maxi_w = m_axi_wvalid & m_axi_wvalid;
    assign handshake_maxi_r = m_axi_rvalid & m_axi_rready;

    assign handshake_treq = s_axis_treq_tvalid & s_axis_treq_tready;
    assign handshake_ireq = m_axis_ireq_tvalid & m_axis_ireq_tready;
    assign handshake_iresp = s_axis_iresp_tvalid & s_axis_iresp_tready;
    assign handshake_tresp = m_axis_tresp_tvalid & m_axis_tresp_tready;

    assign handshake_h2c = s_axis_h2c_tvalid & s_axis_h2c_tready;
// end of assignments

    // always_ff@ (posedge aclk or negedge aresetn) begin
    //     if(!aresetn) begin
    //     end
    //     else begin
    //     end 
    // end

// axil
`ifdef EXTIN_TEST
    // read info
    // input [AXIL_AW-1:0] s_axil_araddr,
    // input s_axil_arvalid,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axil_araddr <= 'b0;
            s_axil_arvalid <= 1'b0;
        end
        else begin
            if(cnt == 'd20) begin
                s_axil_araddr <= 7'h24;
                s_axil_arvalid <= 1'b1;
            end
            else begin
                if(handshake_axil_ar) begin
                    s_axil_araddr <= 'b0;
                    s_axil_arvalid <= 1'b0;
                end
            end
        end 
    end
    // input [AXIL_AW-1:0] s_axil_awaddr,
    assign s_axil_awaddr = 'b0;
    // input s_axil_awvalid,
    assign s_axil_awvalid = 1'b0;
    // input [AXIL_DW-1:0] s_axil_wdata,
    assign s_axil_wdata = 'b0;
    // input s_axil_wvalid,
    assign s_axil_wvalid = 1'b0;
`elsif RXDB_TEST
    // setup SRIO_MODE register
    // input [AXIL_AW-1:0] s_axil_awaddr,
    // input s_axil_awvalid,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axil_awaddr <= 'b0;
            s_axil_awvalid <= 1'b0;
        end
        else begin
            if(cnt == 'd10) begin
                s_axil_awaddr <= 7'h08;
                s_axil_awvalid <= 1'b1;
            end
            else begin
                if(handshake_axil_aw) begin
                    s_axil_awaddr <= 'b0;
                    s_axil_awvalid <= 1'b0;
                end
            end
        end 
    end
    // input [AXIL_DW-1:0] s_axil_wdata,
    // input s_axil_wvalid,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axil_wdata <= 'b0;
            s_axil_wvalid <= 1'b0;
        end
        else begin
            if(cnt == 'd10) begin
                s_axil_wdata <= 32'h00000001;
                // s_axil_wdata <= 32'h00000000;
                s_axil_wvalid <= 1'b1;
            end
            else begin
                if(handshake_axil_w) begin
                    s_axil_wdata <= 'b0;
                    s_axil_wvalid <= 1'b0;
                end
            end
        end 
    end
    // read db info when mode[0] == 1
    // input [AXIL_AW-1:0] s_axil_araddr,
    // input s_axil_arvalid,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axil_araddr <= 'b0;
            s_axil_arvalid <= 1'b0;
        end
        else begin
            if(cnt == 'd30) begin
                s_axil_araddr <= 7'h20;
                s_axil_arvalid <= 1'b1;
            end
            else begin
                if(handshake_axil_ar) begin
                    s_axil_araddr <= 'b0;
                    s_axil_arvalid <= 1'b0;
                end
            end
        end 
    end
`elsif RXNW_TEST
    // setup SRIO_MODE register
    // input [AXIL_AW-1:0] s_axil_awaddr,
    // input s_axil_awvalid,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axil_awaddr <= 'b0;
            s_axil_awvalid <= 1'b0;
        end
        else begin
            if(cnt == 'd10) begin
                s_axil_awaddr <= 7'h08;
                s_axil_awvalid <= 1'b1;
            end
            else begin
                if(handshake_axil_aw) begin
                    s_axil_awaddr <= 'b0;
                    s_axil_awvalid <= 1'b0;
                end
            end
        end 
    end
    // input [AXIL_DW-1:0] s_axil_wdata,
    // input s_axil_wvalid,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axil_wdata <= 'b0;
            s_axil_wvalid <= 1'b0;
        end
        else begin
            if(cnt == 'd10) begin
                s_axil_wdata <= 32'h00000004;
                // s_axil_wdata <= 32'h00000000;
                s_axil_wvalid <= 1'b1;
            end
            else begin
                if(handshake_axil_w) begin
                    s_axil_wdata <= 'b0;
                    s_axil_wvalid <= 1'b0;
                end
            end
        end 
    end
    // input [AXIL_AW-1:0] s_axil_araddr,
    // input s_axil_arvalid,
    assign s_axil_araddr = 'b0;
    assign s_axil_arvalid = 1'b0;
`elsif TXDB_TEST
    // input [AXIL_AW-1:0] s_axil_awaddr,
    // input s_axil_awvalid,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axil_awaddr <= 'b0;
            s_axil_awvalid <= 1'b0;
        end
        else begin
            // setup db info
            if(cnt == 'd10) begin
                s_axil_awaddr <= 7'h18;
                s_axil_awvalid <= 1'b1;
            end
            // start db
            else if(cnt == 'd20) begin
                s_axil_awaddr <= 7'h04;
                s_axil_awvalid <= 1'b1;
            end
            else begin
                if(handshake_axil_aw) begin
                    s_axil_awaddr <= 'b0;
                    s_axil_awvalid <= 1'b0;
                end
            end
        end 
    end
    // input [AXIL_DW-1:0] s_axil_wdata,
    // input s_axil_wvalid,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axil_wdata <= 'b0;
            s_axil_wvalid <= 1'b0;
        end
        else begin
            // setup db info
            if(cnt == 'd10) begin
                s_axil_wdata <= 32'hAAAA5555;
                // s_axil_wdata <= 32'h00000000;
                s_axil_wvalid <= 1'b1;
            end
            // start db
            else if(cnt == 'd20) begin
                s_axil_wdata <= 32'd1;
                s_axil_wvalid <= 1'b1;
            end
            else begin
                if(handshake_axil_w) begin
                    s_axil_wdata <= 'b0;
                    s_axil_wvalid <= 1'b0;
                end
            end
        end 
    end
    // input [AXIL_AW-1:0] s_axil_araddr,
    assign s_axil_araddr = 1'b0;
    // input s_axil_arvalid,
    assign s_axil_arvalid = 1'b0;
`elsif TXSW_TEST
    // input [AXIL_AW-1:0] s_axil_awaddr,
    // input s_axil_awvalid,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axil_awaddr <= 'b0;
            s_axil_awvalid <= 1'b0;
        end
        else begin
            // setup sw mode
            if(cnt == 'd10) begin
                s_axil_awaddr <= 7'h08;
                s_axil_awvalid <= 1'b1;
            end
            // swtup sw size
            else if(cnt == 'd20) begin
                s_axil_awaddr <= 7'h0C;
                s_axil_awvalid <= 1'b1;
            end
            // swtup sw dst
            else if(cnt == 'd30) begin
                s_axil_awaddr <= 7'h10;
                s_axil_awvalid <= 1'b1;
            end
            // swtup sw src
            else if(cnt == 'd40) begin
                s_axil_awaddr <= 7'h14;
                s_axil_awvalid <= 1'b1;
            end
            // swtup sw db info
            else if(cnt == 'd50) begin
                s_axil_awaddr <= 7'h18;
                s_axil_awvalid <= 1'b1;
            end
            // start sw
            else if(cnt == 'd60) begin
                s_axil_awaddr <= 7'h04;
                s_axil_awvalid <= 1'b1;
            end
            else begin
                if(handshake_axil_aw) begin
                    s_axil_awaddr <= 'b0;
                    s_axil_awvalid <= 1'b0;
                end
            end
        end 
    end
    // input [AXIL_DW-1:0] s_axil_wdata,
    // input s_axil_wvalid,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axil_wdata <= 'b0;
            s_axil_wvalid <= 1'b0;
        end
        else begin
            // setup sw mode
            if(cnt == 'd10) begin
                // s_axil_wdata <= 32'h00000000;
                s_axil_wdata <= 32'h00000002;
                s_axil_wvalid <= 1'b1;
            end
            // swtup sw size
            else if(cnt == 'd20) begin
                s_axil_wdata <= 32'h00009FFF;
                // s_axil_wdata <= 32'h0000001F;
                s_axil_wvalid <= 1'b1;
            end
            // swtup sw dst
            else if(cnt == 'd30) begin
                s_axil_wdata <= 32'hC0000000;
                s_axil_wvalid <= 1'b1;
            end
            // swtup sw src
            else if(cnt == 'd40) begin
                s_axil_wdata <= 32'h80000000;
                s_axil_wvalid <= 1'b1;
            end
            // swtup sw db info
            else if(cnt == 'd50) begin
                s_axil_wdata <= 32'hAAAA5555;
                s_axil_wvalid <= 1'b1;
            end
            // start sw
            else if(cnt == 'd60) begin
                s_axil_wdata <= 32'h00000002;
                s_axil_wvalid <= 1'b1;
            end
            else begin
                if(handshake_axil_w) begin
                    s_axil_wdata <= 'b0;
                    s_axil_wvalid <= 1'b0;
                end
            end
        end 
    end
    // input [AXIL_AW-1:0] s_axil_araddr,
    assign s_axil_araddr = 1'b0;
    // input s_axil_arvalid,
    assign s_axil_arvalid = 1'b0;
`endif

// external input
`ifdef EXTIN_TEST
    // input msi_irq_in, 
    // input [31:0] msi_info_in,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            msi_irq_in <= 1'b0;
            msi_info_in <= 'b0;
        end
        else begin
            if(cnt == 'd10) begin
                msi_irq_in <= 1'b1;
                msi_info_in <= 32'h55555555;
            end
            else begin
                msi_irq_in <= 1'b0;
                msi_info_in <= 'b0;
            end
        end 
    end
`else
    assign msi_irq_in = 1'b0;
    assign msi_info_in = 'b0;
`endif

    // [7:0] treq_handshake_cnt
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            treq_handshake_cnt <= 'b0;
        end
        else begin
            if(handshake_treq) begin
                treq_handshake_cnt <= treq_handshake_cnt + 'b1;
            end
        end
    end

    // input [7:0] s_axis_treq_tkeep,
    assign s_axis_treq_tkeep = 8'hFF;
    // input [31:0] s_axis_treq_tuser,
    assign s_axis_treq_tuser = {C_SRIO_DEST_ID, C_SRIO_DEV_ID};

// RXDB test
`ifdef RXDB_TEST
    // input s_axis_treq_tvalid,
    // input [63:0] s_axis_treq_tdata,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axis_treq_tdata <= 'b0;
            s_axis_treq_tvalid <= 1'b0;
        end
        else begin
            if(cnt == 'd20) begin
                s_axis_treq_tdata <= {TID, DOORB, 1'b0, prio, CRF, 12'b0, 16'h5555, 16'b0};
                s_axis_treq_tvalid <= 1'b1;
            end
            else begin
                if(handshake_treq) begin
                    s_axis_treq_tdata <= 'b0;
                    s_axis_treq_tvalid <= 1'b0;
                end
            end
        end
    end
    assign s_axis_treq_tlast = s_axis_treq_tvalid;
`elsif RXNW_TEST
    // input s_axis_treq_tvalid,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axis_treq_tvalid <= 1'b0;
        end
        else begin
            if(cnt == 'd20) begin
                s_axis_treq_tvalid <= 1'b1;
            end
            else if(treq_handshake_cnt == 8'd32 && handshake_treq) begin
                s_axis_treq_tvalid <= 1'b0;
            end
        end
    end

    // input [63:0] s_axis_treq_tdata,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axis_treq_tdata <= 'b0;
        end
        else begin
            if(cnt == 'd20) begin
                s_axis_treq_tdata <= {8'h00, 8'h54, 4'h2, 8'hFF, 4'h0, 32'hC0000000};
            end
            else if(handshake_treq) begin
                s_axis_treq_tdata <= {$random, $random};
            end
        end
    end

    // input s_axis_treq_tlast,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axis_treq_tlast <= 1'b0;
        end
        else begin
            if(treq_handshake_cnt == 8'd31 && handshake_treq) begin
                s_axis_treq_tlast <= 1'b1;
            end
            else if(handshake_treq) begin
                s_axis_treq_tlast <= 1'b0;
            end
        end
    end
`else
    // input s_axis_treq_tvalid,
    assign s_axis_treq_tvalid = 1'b0;
    // input [63:0] s_axis_treq_tdata,
    assign s_axis_treq_tdata = 'b0;
    // input s_axis_treq_tlast,
    assign s_axis_treq_tlast = 1'b0;
`endif

    // input [7:0] s_axis_iresp_tkeep,
    assign s_axis_iresp_tkeep = 8'hFF;
    // input [31:0] s_axis_iresp_tuser,
    assign s_axis_iresp_tuser = {C_SRIO_DEST_ID, C_SRIO_DEV_ID};

// TX test
`ifdef TXDB_TEST
    // input s_axis_iresp_tvalid,
    // input [63:0] s_axis_iresp_tdata,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axis_iresp_tvalid <= 1'b0;
            s_axis_iresp_tdata <= 'b0;
        end
        else begin
            if(m_axis_ireq_tdata[55:48] == 8'hA0 && handshake_ireq) begin
                s_axis_iresp_tvalid <= 1'b1;
                s_axis_iresp_tdata <= {TID, RESP_NODATA, 48'd0};
            end 
            else if(handshake_iresp) begin
                s_axis_iresp_tvalid <= 1'b0;
                s_axis_iresp_tdata <= 'b0;
            end
        end 
    end
    assign s_axis_iresp_tlast = s_axis_iresp_tvalid;
    
    // input s_axis_h2c_tvalid,
    assign s_axis_h2c_tvalid = 1'b0;
    // input [63:0] s_axis_h2c_tdata,
    assign s_axis_h2c_tdata = 'b0;
    // input [7:0] s_axis_h2c_tkeep,
    assign s_axis_h2c_tkeep = 'b0;
    // input s_axis_h2c_tlast,
    assign s_axis_h2c_tlast = 1'b0;

    // input m_axi_rlast,
    assign m_axi_rlast = 1'b0;
    // input m_axi_rvalid,
    assign m_axi_rvalid = 1'b0;
    // input [63 : 0] m_axi_rdata,
    assign m_axi_rdata = 'b0;
`elsif TXSW_TEST
    // input s_axis_iresp_tvalid,
    // input [63:0] s_axis_iresp_tdata,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axis_iresp_tvalid <= 1'b0;
            s_axis_iresp_tdata <= 'b0;
        end
        else begin
            if(m_axis_ireq_tdata[55:48] == 8'hA0 && handshake_ireq) begin
                s_axis_iresp_tvalid <= 1'b1;
                s_axis_iresp_tdata <= {TID, RESP_NODATA, 48'd0};
            end 
            else if(handshake_iresp) begin
                s_axis_iresp_tvalid <= 1'b0;
                s_axis_iresp_tdata <= 'b0;
            end
        end 
    end
    assign s_axis_iresp_tlast = s_axis_iresp_tvalid;

    // input s_axis_h2c_tvalid,
    // input [63:0] s_axis_h2c_tdata,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            s_axis_h2c_tvalid <= 1'b0;
            s_axis_h2c_tdata <= {$random, $random};
        end
        else begin
            if(!s_axis_h2c_tvalid) begin
                s_axis_h2c_tvalid <= {$random} % 2;
            end
            else if(handshake_h2c) begin
                s_axis_h2c_tvalid <= 1'b0;
                s_axis_h2c_tdata <= {$random, $random};
            end
        end 
    end
    
    // input [7:0] s_axis_h2c_tkeep,
    assign s_axis_h2c_tkeep = 8'hFF;
    // input s_axis_h2c_tlast,
    assign s_axis_h2c_tlast = 1'b0;

    // input m_axi_rvalid,
    // input [63 : 0] m_axi_rdata,
    always_ff@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            m_axi_rvalid <= 1'b0;
            m_axi_rdata <= {$random, $random};
        end
        else begin
            if(!m_axi_rvalid) begin
                m_axi_rvalid <= {$random} % 2;
            end
            else if(handshake_maxi_r) begin
                m_axi_rvalid <= 1'b0;
                m_axi_rdata <= {$random, $random};
            end
        end 
    end

    // input m_axi_rlast,
    assign m_axi_rlast = 1'b0;
`else
    // input s_axis_iresp_tvalid,
    assign s_axis_iresp_tvalid = 1'b0;
    // input [63:0] s_axis_iresp_tdata,
    assign s_axis_iresp_tdata = 'b0;
    // input s_axis_iresp_tlast,
    assign s_axis_iresp_tlast = 1'b0;

    // input s_axis_h2c_tvalid,
    assign s_axis_h2c_tvalid = 1'b0;
    // input [63:0] s_axis_h2c_tdata,
    assign s_axis_h2c_tdata = 'b0;
    // input [7:0] s_axis_h2c_tkeep,
    assign s_axis_h2c_tkeep = 'b0;
    // input s_axis_h2c_tlast,
    assign s_axis_h2c_tlast = 1'b0;

    // input m_axi_rlast,
    assign m_axi_rlast = 1'b0;
    // input m_axi_rvalid,
    assign m_axi_rvalid = 1'b0;
    // input [63 : 0] m_axi_rdata,
    assign m_axi_rdata = 'b0;
`endif
    
    // cnt
    always_ff @( posedge aclk or negedge aresetn ) begin
        if(!aresetn) begin
            cnt <= 'b0;
        end
        else begin
            cnt <= cnt + 'b1;
        end
    end

    srio_pcie_bridge#(
        .C_SRIO_DEV_ID(C_SRIO_DEV_ID),
        .C_SRIO_DEST_ID(C_SRIO_DEST_ID),
        .AXIL_DW(AXIL_DW),
        .AXIL_AW(AXIL_AW),
        .USR_IRQ_DW(USR_IRQ_DW)
    )
    srio_pcie_bridge_inst(
        .aclk(aclk),                                // input aclk,
        .aresetn(aresetn),                          // input aresetn,

        // msi irq from user designed peripheral
        .msi_irq_in(msi_irq_in),                    // input msi_irq_in,
        .msi_info_in(msi_info_in),                  // input [31:0] msi_info_in,
        .msi_irq_busy(msi_irq_busy),                // output msi_irq_busy,

        .db_irq_out(db_irq_out),                    // output db_irq_out,
        .db_info_out(db_info_out),                  // output [15:0] db_info_out,

// ireq signals
        .m_axis_ireq_tvalid(m_axis_ireq_tvalid),    // output m_axis_ireq_tvalid,
        .m_axis_ireq_tready(m_axis_ireq_tready),    // input m_axis_ireq_tready,
        .m_axis_ireq_tdata(m_axis_ireq_tdata),      // output [63:0] m_axis_ireq_tdata,
        .m_axis_ireq_tkeep(m_axis_ireq_tkeep),      // output [7:0] m_axis_ireq_tkeep,
        .m_axis_ireq_tlast(m_axis_ireq_tlast),      // output m_axis_ireq_tlast,
        .m_axis_ireq_tuser(m_axis_ireq_tuser),      // output [31:0] m_axis_ireq_tuser,
// end of ireq signals

// iresp signals
        .s_axis_iresp_tvalid(s_axis_iresp_tvalid),  // input s_axis_iresp_tvalid,
        .s_axis_iresp_tready(s_axis_iresp_tready),  // output s_axis_iresp_tready,
        .s_axis_iresp_tdata(s_axis_iresp_tdata),    // input [63:0] s_axis_iresp_tdata,
        .s_axis_iresp_tkeep(s_axis_iresp_tkeep),    // input [7:0] s_axis_iresp_tkeep,
        .s_axis_iresp_tlast(s_axis_iresp_tlast),    // input s_axis_iresp_tlast,
        .s_axis_iresp_tuser(s_axis_iresp_tuser),    // input [31:0] s_axis_iresp_tuser,
// end of iresp signals

// treq signals
        .s_axis_treq_tvalid(s_axis_treq_tvalid),    // input s_axis_treq_tvalid,
        .s_axis_treq_tready(s_axis_treq_tready),    // output s_axis_treq_tready,
        .s_axis_treq_tdata(s_axis_treq_tdata),      // input [63:0] s_axis_treq_tdata,
        .s_axis_treq_tkeep(s_axis_treq_tkeep),      // input [7:0] s_axis_treq_tkeep,
        .s_axis_treq_tlast(s_axis_treq_tlast),      // input s_axis_treq_tlast,
        .s_axis_treq_tuser(s_axis_treq_tuser),      // input [31:0] s_axis_treq_tuser,
// end of treq signals

// tresp signals
        .m_axis_tresp_tvalid(m_axis_tresp_tvalid),  // output m_axis_tresp_tvalid,
        .m_axis_tresp_tready(m_axis_tresp_tready),  // input m_axis_tresp_tready,
        .m_axis_tresp_tdata(m_axis_tresp_tdata),    // output [63:0] m_axis_tresp_tdata,
        .m_axis_tresp_tkeep(m_axis_tresp_tkeep),    // output [7:0] m_axis_tresp_tkeep,
        .m_axis_tresp_tlast(m_axis_tresp_tlast),    // output m_axis_tresp_tlast,
        .m_axis_tresp_tuser(m_axis_tresp_tuser),    // output [31:0] m_axis_tresp_tuser,
// end of tresp signals

// h2c stream
        .s_axis_h2c_tvalid(s_axis_h2c_tvalid),      // input s_axis_h2c_tvalid,
        .s_axis_h2c_tready(s_axis_h2c_tready),      // output s_axis_h2c_tready,
        .s_axis_h2c_tdata(s_axis_h2c_tdata),        // input [63:0] s_axis_h2c_tdata,
        .s_axis_h2c_tkeep(s_axis_h2c_tkeep),        // input [7:0] s_axis_h2c_tkeep,
        .s_axis_h2c_tlast(s_axis_h2c_tlast),        // input s_axis_h2c_tlast,
// end of h2c stream

// c2h stream
        .m_axis_c2h_tvalid(m_axis_c2h_tvalid),      // output m_axis_c2h_tvalid,
        .m_axis_c2h_tready(m_axis_c2h_tready),      // input m_axis_c2h_tready,
        .m_axis_c2h_tdata(m_axis_c2h_tdata),        // output [63:0] m_axis_c2h_tdata,
        .m_axis_c2h_tkeep(m_axis_c2h_tkeep),        // output [7:0] m_axis_c2h_tkeep,
        .m_axis_c2h_tlast(m_axis_c2h_tlast),        // output m_axis_c2h_tlast,
// end of c2h stream

// usr_irq signals
        .usr_irq_req(usr_irq_req),                  // output [USR_IRQ_DW-1:0] usr_irq_req,
        .usr_irq_ack(usr_irq_ack),                  // input [USR_IRQ_DW-1:0] usr_irq_ack,
// end of usr_irq signals

// AXI4-Lite control signals
        .s_axil_awprot(s_axil_awprot),              // input [2:0] s_axil_awprot,
        .s_axil_wstrb(s_axil_wstrb),                // input [3:0] s_axil_wstrb,
        .s_axil_arprot(s_axil_arprot),              // input [2:0] s_axil_arprot,
        .s_axil_rresp(s_axil_rresp),                // output [1:0] s_axil_rresp,

        .s_axil_bresp(s_axil_bresp),                // output [1:0] s_axil_bresp,
        .s_axil_bvalid(s_axil_bvalid),              // output s_axil_bvalid,
        .s_axil_bready(s_axil_bready),              // input s_axil_bready,

        .s_axil_awaddr(s_axil_awaddr),              // input [AXIL_AW-1:0] s_axil_awaddr,
        .s_axil_awvalid(s_axil_awvalid),            // input s_axil_awvalid,
        .s_axil_awready(s_axil_awready),            // output s_axil_awready,

        .s_axil_wdata(s_axil_wdata),                // input [AXIL_DW-1:0] s_axil_wdata,
        .s_axil_wvalid(s_axil_wvalid),              // input s_axil_wvalid,
        .s_axil_wready(s_axil_wready),              // output s_axil_wready,

        .s_axil_araddr(s_axil_araddr),              // input [AXIL_AW-1:0] s_axil_araddr,
        .s_axil_arvalid(s_axil_arvalid),            // input s_axil_arvalid,
        .s_axil_arready(s_axil_arready),            // output s_axil_arready,

        .s_axil_rdata(s_axil_rdata),                // output [AXIL_DW-1:0] s_axil_rdata,
        .s_axil_rvalid(s_axil_rvalid),              // output s_axil_rvalid,
        .s_axil_rready(s_axil_rready),              // input s_axil_rready,
// end of AXI4-Lite control signals

// axi master interface
        // output [C_m_axi_AWUSER_WIDTH-1 : 0] m_axi_awuser,
        // output [C_m_axi_WUSER_WIDTH-1 : 0] m_axi_wuser,
        // input [C_m_axi_BUSER_WIDTH-1 : 0] m_axi_buser,
        // output [C_m_axi_ARUSER_WIDTH-1 : 0] m_axi_aruser,
        // input [C_m_axi_RUSER_WIDTH-1 : 0] m_axi_ruser,

        .m_axi_awsize(m_axi_awsize),                // output [2 : 0] m_axi_awsize,
        .m_axi_awburst(m_axi_awburst),              // output [1 : 0] m_axi_awburst,
        .m_axi_awlock(m_axi_awlock),                // output m_axi_awlock,
        .m_axi_awcache(m_axi_awcache),              // output [3 : 0] m_axi_awcache,
        .m_axi_awprot(m_axi_awprot),                // output [2 : 0] m_axi_awprot,
        .m_axi_awqos(m_axi_awqos),                  // output [3 : 0] m_axi_awqos,
        .m_axi_wstrb(m_axi_wstrb),                  // output [7 : 0] m_axi_wstrb,
        .m_axi_arsize(m_axi_arsize),                // output [2 : 0] m_axi_arsize,
        .m_axi_arburst(m_axi_arburst),              // output [1 : 0] m_axi_arburst,
        .m_axi_arlock(m_axi_arlock),                // output m_axi_arlock,
        .m_axi_arcache(m_axi_arcache),              // output [3 : 0] m_axi_arcache,
        .m_axi_arprot(m_axi_arprot),                // output [2 : 0] m_axi_arprot,
        .m_axi_arqos(m_axi_arqos),                  // output [3 : 0] m_axi_arqos,
        .m_axi_bready(m_axi_bready),                // output m_axi_bready,
        .m_axi_awid(m_axi_awid),                    // output [3:0] m_axi_awid,
        .m_axi_arid(m_axi_arid),                    // output [3:0] m_axi_arid,
        .m_axi_rresp(m_axi_rresp),                  // input [1 : 0] m_axi_rresp,
        .m_axi_bresp(m_axi_bresp),                  // input [1 : 0] m_axi_bresp,
        .m_axi_bvalid(m_axi_bvalid),                // input m_axi_bvalid,
        .m_axi_bid(m_axi_bid),                      // input [3:0] m_axi_bid,
        .m_axi_rid(m_axi_rid),                      // input [3:0] m_axi_rid,
        // aw
        .m_axi_awaddr(m_axi_awaddr),                // output [31 : 0] m_axi_awaddr,
        .m_axi_awlen(m_axi_awlen),                  // output [7 : 0] m_axi_awlen,
        .m_axi_awvalid(m_axi_awvalid),              // output m_axi_awvalid,
        .m_axi_awready(m_axi_awready),              // input m_axi_awready,
        // w
        .m_axi_wdata(m_axi_wdata),                  // output [63 : 0] m_axi_wdata,
        .m_axi_wlast(m_axi_wlast),                  // output m_axi_wlast,
        .m_axi_wvalid(m_axi_wvalid),                // output m_axi_wvalid,
        .m_axi_wready(m_axi_wready),                 // input m_axi_wready
        // ar
        .m_axi_araddr(m_axi_araddr),                // output [31 : 0] m_axi_araddr,
        .m_axi_arlen(m_axi_arlen),                  // output [7 : 0] m_axi_arlen,
        .m_axi_arvalid(m_axi_arvalid),              // output m_axi_arvalid,
        .m_axi_arready(m_axi_arready),              // input m_axi_arready,
        // r
        .m_axi_rdata(m_axi_rdata),                  // input [63 : 0] m_axi_rdata,
        .m_axi_rlast(m_axi_rlast),                  // input m_axi_rlast,
        .m_axi_rvalid(m_axi_rvalid),                // input m_axi_rvalid,
        .m_axi_rready(m_axi_rready)                 // output m_axi_rready
// end of axi master interface
    );

endmodule