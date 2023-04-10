`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/21 10:40:10
// Design Name: 
// Module Name: sw_tx_engine
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


module sw_tx_engine#(
    parameter [15:0] C_SRIO_DEV_ID = 16'hF201,
    parameter [15:0] C_SRIO_DEST_ID = 16'h7801
    )(
    input aclk,
    input aresetn,

    input sw_start,
    input sw_mode,
    input [4:0] sw_size,
    input [31:0] sw_addr,
    output sw_done,

// ireq signals
    output m_axis_ireq_tvalid,
    input m_axis_ireq_tready,
    output [63:0] m_axis_ireq_tdata,
    output m_axis_ireq_tlast,
// end of ireq signals

// h2c stream
    input s_axis_h2c_tvalid,
    output s_axis_h2c_tready,
    input [63:0] s_axis_h2c_tdata,
    input [7:0] s_axis_h2c_tkeep,
    input s_axis_h2c_tlast,
// end of h2c stream

// axi master interface
    // r
    input [63 : 0] m_axi_rdata,
    input m_axi_rlast,
    input m_axi_rvalid,
    output m_axi_rready
// end of axi master interface
    );

    localparam [2:0] S_IDLE = 3'b000;
    localparam [2:0] S_HEAD = 3'b001;
    localparam [2:0] S_DATA = 3'b010;

    localparam [7:0] SWRITE = 8'h60;
    localparam [1:0] prio = 2'b01;
    localparam [0:0] CRF = 1'b0;

// definition
    reg ireq_tvalid;
    reg [63:0] ireq_tdata;
    reg ireq_tlast;
    reg h2c_tready;
    reg axi_rready;

    reg [4:0] beat_cnt;
    reg [4:0] total_beat_cnt;

    reg [2:0] cstate;
    reg [2:0] nstate;

    wire handshake_ireq;
// end of definition

// assignments
    assign m_axis_ireq_tvalid = ireq_tvalid;
    assign m_axis_ireq_tdata = ireq_tdata;
    assign m_axis_ireq_tlast = ireq_tlast;
    assign s_axis_h2c_tready = h2c_tready;
    assign m_axi_rready = axi_rready; 

    assign handshake_ireq = m_axis_ireq_tvalid & m_axis_ireq_tready;
    assign sw_done = handshake_ireq & m_axis_ireq_tlast;
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
                if(sw_start) begin
                    nstate = S_HEAD;
                end
            end 
            S_HEAD: begin
                if(handshake_ireq) begin
                    nstate = S_DATA;
                end
            end
            S_DATA: begin
                if(sw_done) begin
                    nstate = S_IDLE;
                end
            end
            default: begin
                nstate = S_IDLE;
            end
        endcase
    end
// end of state machine

    // reg [4:0] total_beat_cnt;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            total_beat_cnt <= 'b0;
        end
        else begin
            if(sw_start) begin
                total_beat_cnt <= sw_size;
            end
        end
    end

    // reg [4:0] beat_cnt;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            beat_cnt <= 'b0;
        end
        else begin
            if(cstate == S_DATA && beat_cnt < total_beat_cnt && handshake_ireq) begin
                beat_cnt <= beat_cnt + 5'd1;
            end
            else if(nstate == S_IDLE) begin
                beat_cnt <= 'b0;
            end
        end
    end

    // reg ireq_tlast;
    always@ (*) begin
        ireq_tlast = 1'b0;
        if(beat_cnt == total_beat_cnt && ireq_tvalid && cstate == S_DATA) begin
            ireq_tlast = 1'b1;
        end
    end

    // reg ireq_tvalid;
    // reg [63:0] ireq_tdata;
    always@ (*) begin
        ireq_tvalid = 1'b0;
        ireq_tdata = 'b0;
        case (cstate)
            S_HEAD: begin
                ireq_tvalid = 1'b1;
                ireq_tdata = {8'b0, SWRITE, 1'b0, prio, CRF, 12'b0, sw_addr};
            end
            S_DATA: begin
                // mm2sw
                if(sw_mode) begin
                    ireq_tvalid = m_axi_rvalid;
                    ireq_tdata[7:0] = m_axi_rdata[63:56];
                    ireq_tdata[15:8] = m_axi_rdata[55:48];
                    ireq_tdata[23:16] = m_axi_rdata[47:40];
                    ireq_tdata[31:24] = m_axi_rdata[39:32];
                    ireq_tdata[39:32] = m_axi_rdata[31:24];
                    ireq_tdata[47:40] = m_axi_rdata[23:16];
                    ireq_tdata[55:48] = m_axi_rdata[15:8];
                    ireq_tdata[63:56] = m_axi_rdata[7:0];
                end
                // s2sw
                else begin
                    ireq_tvalid = s_axis_h2c_tvalid;
                    ireq_tdata[7:0] = s_axis_h2c_tdata[63:56];
                    ireq_tdata[15:8] = s_axis_h2c_tdata[55:48];
                    ireq_tdata[23:16] = s_axis_h2c_tdata[47:40];
                    ireq_tdata[31:24] = s_axis_h2c_tdata[39:32];
                    ireq_tdata[39:32] = s_axis_h2c_tdata[31:24];
                    ireq_tdata[47:40] = s_axis_h2c_tdata[23:16];
                    ireq_tdata[55:48] = s_axis_h2c_tdata[15:8];
                    ireq_tdata[63:56] = s_axis_h2c_tdata[7:0];
                end
            end
            default: begin
                ireq_tvalid = 1'b0;
                ireq_tdata = 'b0;
            end
        endcase
    end

    // reg h2c_tready;
    // reg axi_rready;
    always@(*) begin
        h2c_tready = 1'b0;
        axi_rready = 1'b0;
        if(cstate == S_DATA) begin
            if(sw_mode) begin
                axi_rready = m_axis_ireq_tready;
            end
            else begin
                h2c_tready = m_axis_ireq_tready;
            end
        end
    end
endmodule
