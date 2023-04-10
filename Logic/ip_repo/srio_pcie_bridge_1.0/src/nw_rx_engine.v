`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/21 10:40:10
// Design Name: 
// Module Name: nw_rx_engine
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


module nw_rx_engine #(
    parameter [15:0] C_SRIO_DEV_ID = 16'hF201,
    parameter [15:0] C_SRIO_DEST_ID = 16'h7801
    )(
    input aclk,
    input aresetn,

    input nw_mode,
    output nw_err_cross,
    output nw_err_unalign,

    (* mark_debug = "true" *) output nw_busy,

// treq signals
    input s_axis_treq_tvalid,
    output s_axis_treq_tready,
    input [63:0] s_axis_treq_tdata,
    input [7:0] s_axis_treq_tkeep,
    input s_axis_treq_tlast,
    input [31:0] s_axis_treq_tuser,
// end of treq signals

// c2h stream
    output m_axis_c2h_tvalid,
    input m_axis_c2h_tready,
    output [63:0] m_axis_c2h_tdata,
    output [7:0] m_axis_c2h_tkeep,
    output m_axis_c2h_tlast,
// end of c2h stream

// axi master interface
    // aw
    output [31 : 0] m_axi_awaddr,
    output [7 : 0] m_axi_awlen,
    output m_axi_awvalid,
    input m_axi_awready,
    // w
    output [63 : 0] m_axi_wdata,
    output m_axi_wlast,
    output m_axi_wvalid,
    input m_axi_wready
// end of axi master interface
    );

    localparam [2:0] S_IDLE = 3'b000;
    localparam [2:0] S_ERR = 3'b001;
    localparam [2:0] S_NW2MM = 3'b010;
    localparam [2:0] S_NW2S = 3'b011;

// definition
    (* mark_debug = "true" *) reg nw_err_cross_i;
    (* mark_debug = "true" *) reg nw_err_unalign_i;
    // reg nw_busy_i;

    (* mark_debug = "true" *) reg treq_tready;
    reg treq_tready_waiting_valid;

    reg c2h_tvalid;
    reg [63:0] c2h_tdata;
    reg [7:0] c2h_tkeep;
    reg c2h_tlast;

    reg [31:0] axi_awaddr;
    reg [7:0] axi_awlen;
    reg axi_awvalid;

    reg [63:0] axi_wdata;
    reg axi_wlast;
    reg axi_wvalid;

    (* mark_debug = "true" *) reg [2:0] cstate;
    (* mark_debug = "true" *) reg [2:0] nstate;

    wire handshake_aw;
    wire handshake_w;

    (* mark_debug = "true" *) wire is_nwrite;
    (* mark_debug = "true" *) wire nwrite_valid;
    (* mark_debug = "true" *) wire handshake_treq;
    (* mark_debug = "true" *) wire handshake_treq_nw;
    (* mark_debug = "true" *) wire treq_packet_end;

    (* mark_debug = "true" *) wire [31:0] base_addr;
    (* mark_debug = "true" *) wire [31:0] last_addr;
    (* mark_debug = "true" *) wire [7:0] nwrite_size;
    (* mark_debug = "true" *) wire is_cross_boundary;
    (* mark_debug = "true" *) wire is_align8bytes;
// end of definition

// assignments
    assign nw_err_cross = nw_err_cross_i;
    assign nw_err_unalign = nw_err_unalign_i;

    assign s_axis_treq_tready = treq_tready;
    assign m_axis_c2h_tvalid = c2h_tvalid;
    assign m_axis_c2h_tdata = c2h_tdata;
    assign m_axis_c2h_tkeep = c2h_tkeep;
    assign m_axis_c2h_tlast = c2h_tlast;

    assign m_axi_awaddr = axi_awaddr;
    assign m_axi_awlen = axi_awlen;
    assign m_axi_awvalid = axi_awvalid;

    assign m_axi_wdata = axi_wdata;
    assign m_axi_wvalid = axi_wvalid;
    assign m_axi_wlast = axi_wlast;

    assign handshake_aw = m_axi_awvalid & m_axi_awready;
    assign handshake_w = m_axi_wvalid & m_axi_wready;

    assign nw_busy = (cstate != S_IDLE)? 1'b1:1'b0;
    assign is_nwrite = (s_axis_treq_tdata[55:48] == 8'h54 && !nw_busy)? 1'b1:1'b0;
    assign nwrite_valid = s_axis_treq_tvalid & is_nwrite;
    assign handshake_treq = s_axis_treq_tvalid & s_axis_treq_tready;
    assign handshake_treq_nw = nwrite_valid & s_axis_treq_tready;
    assign treq_packet_end = handshake_treq & s_axis_treq_tlast;

    assign nwrite_size = s_axis_treq_tdata[43:36]; // size - 1
    assign base_addr = s_axis_treq_tdata[31:0];
    assign last_addr = base_addr + nwrite_size;
    assign is_cross_boundary = (base_addr[31:12] != last_addr[31:12] && handshake_treq_nw)? 1'b1:1'b0;
    assign is_align8bytes = (nwrite_size[2:0] == 3'b111 && base_addr[2:0] == 3'b000 && handshake_treq_nw)? 1'b1: 1'b0;
// end of assignments

// state machine
    // cstate
    always@(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            cstate <= S_IDLE;
        end
        else begin
            cstate <= nstate;
        end
    end

    // nstate
    always@(*) begin
        nstate = cstate;
        case (cstate)
            S_IDLE: begin
                // start nw
                if(handshake_treq_nw) begin
                    // nw2mm mode
                    if(nw_mode) begin
                        if(is_cross_boundary || !is_align8bytes) begin
                            nstate = S_ERR;
                        end
                        else begin
                            nstate = S_NW2MM;
                        end
                    end
                    // nw2s mode
                    else begin
                        nstate = S_NW2S;
                    end
                end
            end 
            S_ERR: begin
                if(treq_packet_end) begin
                    nstate = S_IDLE;
                end
            end
            S_NW2MM: begin
                if(treq_packet_end) begin
                    nstate = S_IDLE;
                end
            end
            S_NW2S: begin
                if(treq_packet_end) begin
                    nstate = S_IDLE;
                end
            end
            default: begin
                nstate = S_IDLE;
            end
        endcase
    end
// end of state machine

    // reg nw_err_cross_i;
    // reg nw_err_unalign_i
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            nw_err_cross_i <= 1'b0;
            nw_err_unalign_i <= 1'b0;
        end
        else begin
            if(cstate == S_IDLE && nstate == S_ERR) begin
                if(is_cross_boundary) begin
                    nw_err_cross_i <= 1'b1;
                end
                if(!is_align8bytes) begin
                    nw_err_unalign_i <= 1'b1;
                end
            end
            else begin
                nw_err_cross_i <= 1'b0;
                nw_err_unalign_i <= 1'b0;
            end
        end
    end

    // reg treq_tready_waiting_valid;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            treq_tready_waiting_valid <= 1'b0;
        end
        else begin
            if(!treq_tready_waiting_valid && nwrite_valid && !nw_busy) begin
                treq_tready_waiting_valid <= 1'b1;
            end
            else begin
                treq_tready_waiting_valid <= 1'b0;
            end
        end
    end

    // reg treq_tready;
    always@(*) begin
        case (cstate)
            S_IDLE: begin
                treq_tready = treq_tready_waiting_valid;
            end
            S_ERR: begin
                treq_tready = 1'b1;
            end
            S_NW2MM: begin
                treq_tready = m_axi_wready;
            end
            S_NW2S: begin
                treq_tready = m_axis_c2h_tready;
            end
            default: begin
                treq_tready = 1'b0;
            end
        endcase
    end

    // reg c2h_tvalid;
    // reg [63:0] c2h_tdata;
    // reg [7:0] c2h_tkeep;
    // reg c2h_tlast;
    always@(*) begin
        c2h_tlast = 1'b0;
        case (cstate)
            S_NW2S: begin
                c2h_tvalid = s_axis_treq_tvalid;
                c2h_tdata[7:0] = s_axis_treq_tdata[63:56];
                c2h_tdata[15:8] = s_axis_treq_tdata[55:48];
                c2h_tdata[23:16] = s_axis_treq_tdata[47:40];
                c2h_tdata[31:24] = s_axis_treq_tdata[39:32];
                c2h_tdata[39:32] = s_axis_treq_tdata[31:24];
                c2h_tdata[47:40] = s_axis_treq_tdata[23:16];
                c2h_tdata[55:48] = s_axis_treq_tdata[15:8];
                c2h_tdata[63:56] = s_axis_treq_tdata[7:0];
                c2h_tkeep = s_axis_treq_tkeep;
            end
            default: begin
                c2h_tvalid = 1'b0;
                c2h_tdata = 'b0;
                c2h_tkeep = 'b0;
            end
        endcase
    end

    // reg [31:0] axi_awaddr;
    // reg [7:0] axi_awlen;
    // reg axi_awvalid;
    always@(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            axi_awvalid <= 1'b0;
            axi_awaddr <= 'b0;
            axi_awlen <= 'b0;
        end
        else begin
            if(cstate == S_IDLE && nstate == S_NW2MM) begin
                axi_awvalid <= 1'b1;
                axi_awaddr <= base_addr;
                axi_awlen <= {3'b000, nwrite_size[7:3]};
            end
            else if(handshake_aw) begin
                axi_awvalid <= 1'b0;
                axi_awaddr <= 'b0;
                axi_awlen <= 'b0;
            end
        end
    end

    // reg [63:0] axi_wdata;
    // reg axi_wlast;
    // reg axi_wvalid;
    always@(*) begin
        case (cstate)
            S_NW2MM: begin
                axi_wvalid = s_axis_treq_tvalid;
                axi_wdata[7:0] = s_axis_treq_tdata[63:56];
                axi_wdata[15:8] = s_axis_treq_tdata[55:48];
                axi_wdata[23:16] = s_axis_treq_tdata[47:40];
                axi_wdata[31:24] = s_axis_treq_tdata[39:32];
                axi_wdata[39:32] = s_axis_treq_tdata[31:24];
                axi_wdata[47:40] = s_axis_treq_tdata[23:16];
                axi_wdata[55:48] = s_axis_treq_tdata[15:8];
                axi_wdata[63:56] = s_axis_treq_tdata[7:0];
                axi_wlast = s_axis_treq_tlast;
            end
            default: begin
                axi_wvalid = 1'b0;
                axi_wdata = 'b0;
                axi_wlast = 1'b0;
            end
        endcase
    end

endmodule
