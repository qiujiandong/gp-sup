`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/21 10:40:10
// Design Name: 
// Module Name: srio_rx_manager
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


module srio_rx_manager#(
    parameter [15:0] C_SRIO_DEV_ID = 16'hF201,
    parameter [15:0] C_SRIO_DEST_ID = 16'h7801
    )(
    input aclk,
    input aresetn,

    output db_irq,
    output [15:0] db_info,

    input nw_mode,
    output nw_err_cross,
    output nw_err_unalign,

// treq signals
    input s_axis_treq_tvalid,
    output s_axis_treq_tready,
    input [63:0] s_axis_treq_tdata,
    input [7:0] s_axis_treq_tkeep,
    input s_axis_treq_tlast,
    input [31:0] s_axis_treq_tuser,
// end of treq signals

// tresp signals
    output m_axis_tresp_tvalid,
    input m_axis_tresp_tready,
    output [63:0] m_axis_tresp_tdata,
    output [7:0] m_axis_tresp_tkeep,
    output m_axis_tresp_tlast,
    output [31:0] m_axis_tresp_tuser,
// end of tresp signals

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

    (* mark_debug = "true" *) wire treq_tready_db;
    (* mark_debug = "true" *) wire treq_tready_nw;

    (* mark_debug = "true" *) wire nw_busy;

    assign s_axis_treq_tready = treq_tready_db | treq_tready_nw;

// db_rx_engine_inst
    db_rx_engine #(
        .C_SRIO_DEV_ID(C_SRIO_DEV_ID),
        .C_SRIO_DEST_ID(C_SRIO_DEST_ID)
    )
    db_rx_engine_inst(
        .aclk(aclk),                                // input aclk,
        .aresetn(aresetn),                          // input aresetn,

        .db_irq(db_irq),                            // output db_irq,
        .db_info(db_info),                          // output [15:0] db_info,

        .nw_busy(nw_busy),                          // input nw_busy

        .s_axis_treq_tvalid(s_axis_treq_tvalid),    // input s_axis_treq_tvalid,
        .s_axis_treq_tready(treq_tready_db),        // output s_axis_treq_tready,
        .s_axis_treq_tdata(s_axis_treq_tdata),      // input [63:0] s_axis_treq_tdata,
        .s_axis_treq_tkeep(s_axis_treq_tkeep),      // input [7:0] s_axis_treq_tkeep,
        .s_axis_treq_tlast(s_axis_treq_tlast),      // input s_axis_treq_tlast,
        .s_axis_treq_tuser(s_axis_treq_tuser),      // input [31:0] s_axis_treq_tuser,

        .m_axis_tresp_tvalid(m_axis_tresp_tvalid),  // output m_axis_tresp_tvalid,
        .m_axis_tresp_tready(m_axis_tresp_tready),  // input m_axis_tresp_tready,
        .m_axis_tresp_tdata(m_axis_tresp_tdata),    // output [63:0] m_axis_tresp_tdata,
        .m_axis_tresp_tkeep(m_axis_tresp_tkeep),    // output [7:0] m_axis_tresp_tkeep,
        .m_axis_tresp_tlast(m_axis_tresp_tlast),    // output m_axis_tresp_tlast,
        .m_axis_tresp_tuser(m_axis_tresp_tuser)     // output [31:0] m_axis_tresp_tuser,
    );
// end of db_rx_engine_inst

// nw_rx_engine_inst
    nw_rx_engine #(
        .C_SRIO_DEV_ID(C_SRIO_DEV_ID),
        .C_SRIO_DEST_ID(C_SRIO_DEST_ID)
    )
    nw_rx_engine_inst(
        .aclk(aclk),                                // input aclk,
        .aresetn(aresetn),                          // input aresetn,

        .nw_mode(nw_mode),                          // input nw_mode,
        .nw_err_cross(nw_err_cross),                // output nw_err,
        .nw_err_unalign(nw_err_unalign),            // output nw_err_noalign,

        .nw_busy(nw_busy),                          // output nw_busy

        .s_axis_treq_tvalid(s_axis_treq_tvalid),    // input s_axis_treq_tvalid,
        .s_axis_treq_tready(treq_tready_nw),        // output s_axis_treq_tready,
        .s_axis_treq_tdata(s_axis_treq_tdata),      // input [63:0] s_axis_treq_tdata,
        .s_axis_treq_tkeep(s_axis_treq_tkeep),      // input [7:0] s_axis_treq_tkeep,
        .s_axis_treq_tlast(s_axis_treq_tlast),      // input s_axis_treq_tlast,
        .s_axis_treq_tuser(s_axis_treq_tuser),      // input [31:0] s_axis_treq_tuser,

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
// end of nw_rx_engine_inst

endmodule
