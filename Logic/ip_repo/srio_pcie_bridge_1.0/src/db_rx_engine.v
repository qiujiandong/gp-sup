`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/21 10:40:10
// Design Name: 
// Module Name: db_rx_engine
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


module db_rx_engine #(
    parameter [15:0] C_SRIO_DEV_ID = 16'hF201,
    parameter [15:0] C_SRIO_DEST_ID = 16'h7801
    )(
    input aclk,
    input aresetn,

    output db_irq, // single cycle irq signal
    output [15:0] db_info,

    input nw_busy,

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
    output [31:0] m_axis_tresp_tuser
// end of tresp signals
    );

    localparam [7:0] RESP_NODATA = 8'hD0;
    localparam [0:0] CRF = 1'b0; //critical request flow

    reg db_irq_i;
    reg [15:0] db_info_i;

    reg treq_tready;
    reg tresp_tvalid;
    reg [63:0] tresp_tdata;
    reg [7:0] tresp_tkeep;
    reg tresp_tlast;
    reg [31:0] tresp_tuser;

    (* mark_debug = "true" *) wire is_doorbell;
    (* mark_debug = "true" *) wire doorbell_valid;
    (* mark_debug = "true" *) wire [15:0] doorbell_info;
    wire [7:0] src_tid;
    wire [1:0] prio_req;
    wire [1:0] prio_resp;

    // wire handshake_treq;
    (* mark_debug = "true" *) wire handshake_treq_db;
    (* mark_debug = "true" *) wire handshake_tresp;
    (* mark_debug = "true" *) wire doorbell_nack;

    assign s_axis_treq_tready = treq_tready;
    assign m_axis_tresp_tvalid = tresp_tvalid;
    assign m_axis_tresp_tdata = tresp_tdata;
    assign m_axis_tresp_tkeep = tresp_tkeep;
    assign m_axis_tresp_tlast = tresp_tlast;
    assign m_axis_tresp_tuser = tresp_tuser;

    assign db_irq = db_irq_i;
    assign db_info = db_info_i;

    // check packet header field and NW is not busy
    assign is_doorbell = (s_axis_treq_tdata[55:48] == 8'hA0 && !nw_busy)? 1'b1:1'b0;
    assign doorbell_valid = s_axis_treq_tvalid & is_doorbell;
    assign doorbell_info = s_axis_treq_tdata[31:16];
    assign src_tid = s_axis_treq_tdata[63:56];
    assign prio_req = s_axis_treq_tdata[46:45];
    assign prio_resp = prio_req + 2'b1;

    // assign handshake_treq = s_axis_treq_tvalid & s_axis_treq_tready;
    assign handshake_treq_db = s_axis_treq_tready & doorbell_valid;
    assign handshake_tresp = m_axis_tresp_tvalid & m_axis_tresp_tready;
    assign doorbell_nack = m_axis_tresp_tvalid & ~m_axis_tresp_tready;

    // treq_tready
    always@(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            treq_tready <= 1'b0;
        end
        else begin
            if(doorbell_valid) begin
                if(!s_axis_treq_tready && doorbell_valid && !doorbell_nack) begin
                    treq_tready <= 1'b1;
                end
                else if(handshake_treq_db) begin
                    treq_tready <= 1'b0;
                end
            end
        end
    end

    // reg db_irq_i;
    // reg [15:0] db_info_i;
    always@(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            db_irq_i <= 1'b0;
            db_info_i <= 'b0;
        end
        else begin
            if(handshake_treq_db) begin
                db_irq_i <= 1'b1;
                db_info_i <= doorbell_info;
            end
            else begin
                db_irq_i <= 1'b0;
                db_info_i <= 'b0;
            end
        end
    end
    

    // doorbell response
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            tresp_tvalid <= 1'b0;
            tresp_tdata <= 64'b0;
            tresp_tkeep <= 8'b0;
            tresp_tlast <= 1'b0;
            tresp_tuser <= 32'b0;
        end
        else begin
            if(handshake_treq_db) begin
                tresp_tvalid <= 1'b1;
                tresp_tdata <= {src_tid, RESP_NODATA, 1'b0, prio_resp, CRF, 44'b0 };
                tresp_tkeep <= 8'hFF;
                tresp_tlast <= 1'b1;
                tresp_tuser <= {C_SRIO_DEV_ID, C_SRIO_DEST_ID};
            end
            else if(handshake_tresp) begin
                tresp_tvalid <= 1'b0;
                tresp_tdata <= 64'b0;
                tresp_tkeep <= 8'b0;
                tresp_tlast <= 1'b0;
                tresp_tuser <= 32'b0;
            end
        end
    end
// end of doorbell response

    
endmodule
