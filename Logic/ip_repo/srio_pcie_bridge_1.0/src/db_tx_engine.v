`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/21 10:40:10
// Design Name: 
// Module Name: db_tx_engine
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


module db_tx_engine #(
    parameter [15:0] C_SRIO_DEV_ID = 16'hF201,
    parameter [15:0] C_SRIO_DEST_ID = 16'h7801
    )(
    input aclk,
    input aresetn,

    (* mark_debug = "true" *) input db_start, // single cycle enable signal
    (* mark_debug = "true" *) input [15:0] db_info,
    (* mark_debug = "true" *) output db_done, // single cycle enable signal

// ireq signals
    output m_axis_ireq_tvalid,
    input m_axis_ireq_tready,
    output [63:0] m_axis_ireq_tdata,
    output m_axis_ireq_tlast,
// end of ireq signals

// iresp signals
    input s_axis_iresp_tvalid,
    output s_axis_iresp_tready,
    input [63:0] s_axis_iresp_tdata,
    input [7:0] s_axis_iresp_tkeep,
    input s_axis_iresp_tlast
// end of iresp signals
    );

    localparam [1:0] prio = 2'b01;
    localparam [0:0] CRF = 1'b0;
    localparam [7:0] DOORB = 8'hA0;
    localparam [7:0] RESP_NODATA = 8'hD0;
    localparam [7:0] TID = 8'h55;

    reg ireq_tvalid;
    reg [63:0] ireq_tdata;
    reg ireq_tlast;
    reg iresp_tready;

    wire handshake_ireq;
    wire handshake_iresp;

    wire is_db_resp;
    wire db_resp_valid;

    assign m_axis_ireq_tvalid = ireq_tvalid;
    assign m_axis_ireq_tdata = ireq_tdata;
    assign m_axis_ireq_tlast = ireq_tlast;
    assign s_axis_iresp_tready = iresp_tready;

    assign handshake_ireq = m_axis_ireq_tvalid & m_axis_ireq_tready;
    assign handshake_iresp = s_axis_iresp_tvalid & s_axis_iresp_tready;

    assign is_db_resp = (s_axis_iresp_tdata[63:48] == {TID, RESP_NODATA})? 1'b1:1'b0;
    assign db_resp_valid = is_db_resp & s_axis_iresp_tvalid;

    assign db_done = handshake_iresp;

    // reg ireq_tvalid;
    // reg [63:0] ireq_tdata;
    // reg ireq_tlast;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            ireq_tvalid <= 1'b0;
            ireq_tdata <= 'b0;
            ireq_tlast <= 1'b0;
        end
        else begin
            if(db_start) begin
                ireq_tvalid <= 1'b1;
                ireq_tdata <= {TID, DOORB, 1'b0, prio, CRF, 12'b0, db_info, 16'b0};
                ireq_tlast <= 1'b1;
            end
            else if(handshake_ireq) begin
                ireq_tvalid <= 1'b0;
                ireq_tdata <= 'b0;
                ireq_tlast <= 1'b0;
            end
        end
    end

    // reg iresp_tready;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            iresp_tready <= 1'b0;
        end
        else begin
            if(!iresp_tready && db_resp_valid) begin
                iresp_tready <= 1'b1;
            end
            else if(handshake_ireq) begin
                iresp_tready <= 1'b0;
            end
        end
    end

endmodule
