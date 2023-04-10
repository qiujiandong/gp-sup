`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/21 10:40:10
// Design Name: 
// Module Name: srio_tx_manager
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


module srio_tx_manager#(
    parameter [15:0] C_SRIO_DEV_ID = 16'hF201,
    parameter [15:0] C_SRIO_DEST_ID = 16'h7801
    )(
    input aclk,
    input aresetn,

    input db_start,
    input [15:0] db_info_normal,
    input [15:0] db_info_sw,
    output db_done,

    input sw_start,
    input sw_mode,
    input [26:0] sw_size,
    input [31:0] sw_dst_base_addr,
    input [31:0] sw_src_base_addr,
    output sw_done,

    output sw_err_src_unalign,
    output sw_err_dst_unalign,

// ireq signals
    output m_axis_ireq_tvalid,
    input m_axis_ireq_tready,
    output [63:0] m_axis_ireq_tdata,
    output [7:0] m_axis_ireq_tkeep,
    output m_axis_ireq_tlast,
    output [31:0] m_axis_ireq_tuser,
// end of ireq signals

// iresp signals
    input s_axis_iresp_tvalid,
    output s_axis_iresp_tready,
    input [63:0] s_axis_iresp_tdata,
    input [7:0] s_axis_iresp_tkeep,
    input s_axis_iresp_tlast,
    input [31:0] s_axis_iresp_tuser,
// end of iresp signals

// h2c stream
    input s_axis_h2c_tvalid,
    output s_axis_h2c_tready,
    input [63:0] s_axis_h2c_tdata,
    input [7:0] s_axis_h2c_tkeep,
    input s_axis_h2c_tlast,
// end of h2c stream

// axi master interface
    // ar
    output [31 : 0] m_axi_araddr,
    output [7 : 0] m_axi_arlen,
    output m_axi_arvalid,
    input m_axi_arready,
    // r
    input [63 : 0] m_axi_rdata,
    input m_axi_rlast,
    input m_axi_rvalid,
    output m_axi_rready
// end of axi master interface
    );

    localparam [2:0] S_IDLE = 3'b000;
    localparam [2:0] S_SWDB = 3'b001;
    localparam [2:0] S_NORMALDB = 3'b010;
    localparam [2:0] S_SW = 3'b011;

// definition
    reg [2:0] cstate;
    reg [2:0] nstate;

    reg db_start_q;
    wire db_start_en;
    reg [15:0] db_info_normal_q;
    reg normal_db_req;

    reg sw_start_q;
    wire sw_start_en;
    reg [15:0] db_info_sw_q;
    reg sw_req;
    reg [21:0] sw_full_pack_cnt;
    reg [4:0] sw_last_pack_size;
    reg sw_last_pack_done;

    reg sw_db_req;
    
    // output signal
    reg db_done_i;
    reg sw_done_i;
    wire is_sw_src_align;
    wire is_sw_dst_align;
    reg sw_err_src_unalign_i;
    reg sw_err_dst_unalign_i;

    // common signal
    wire ireq_tvalid_db;
    wire [63:0] ireq_tdata_db;
    wire ireq_tlast_db;
    wire ireq_tvalid_sw;
    wire [63:0] ireq_tdata_sw;
    wire ireq_tlast_sw;

    // dbtx module signal
    reg db_part_start;
    wire [15:0] db_part_info;
    wire db_part_done;

    // swtx module signal
    reg sw_part_start;
    reg sw_mode_q;
    reg [4:0] sw_part_size;
    reg [31:0] sw_part_addr;
    wire sw_part_done;

    // ar signal
    wire handshake_ar;
    reg ar_busy;
    reg [21:0] ar_full_burst_cnt;
    reg [4:0] ar_last_burst_len;
    reg ar_last_req_done;
    reg [31:0] axi_araddr;
    reg [7:0] axi_arlen;
    reg axi_arvalid;
// end of definition

// assignments
    assign m_axis_ireq_tkeep = 8'hFF;
    assign m_axis_ireq_tuser = {C_SRIO_DEV_ID, C_SRIO_DEST_ID};
    assign m_axis_ireq_tvalid = ireq_tvalid_db | ireq_tvalid_sw;
    assign m_axis_ireq_tdata = ireq_tdata_db | ireq_tdata_sw;
    assign m_axis_ireq_tlast = ireq_tlast_db | ireq_tlast_sw;

    assign db_done = db_done_i;
    assign sw_done = sw_done_i;
    assign is_sw_src_align = (sw_src_base_addr[7:0] == 8'd0)? 1'b1: 1'b0;
    assign is_sw_dst_align = (sw_dst_base_addr[7:0] == 8'd0)? 1'b1: 1'b0;
    assign sw_err_src_unalign = sw_err_src_unalign_i;
    assign sw_err_dst_unalign = sw_err_dst_unalign_i;

    assign m_axi_araddr = axi_araddr;
    assign m_axi_arlen = axi_arlen;
    assign m_axi_arvalid = axi_arvalid;

    assign handshake_ar = m_axi_arvalid & m_axi_arready;
// end of assignments

// state machine
    // reg [2:0] cstate;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            cstate <= S_IDLE;
        end
        else begin
            cstate <= nstate;
        end
    end
    // reg [2:0] nstate;
    always@ (*) begin
        nstate = cstate;
        case (cstate)
            S_IDLE: begin
                if(sw_db_req) begin
                    nstate = S_SWDB;
                end
                else if(normal_db_req) begin
                    nstate = S_NORMALDB;
                end
                else if(sw_req) begin
                    nstate = S_SW;
                end
            end
            S_SWDB: begin
                if(db_part_done) begin
                    nstate = S_IDLE;
                end
            end
            S_NORMALDB: begin
                if(db_part_done) begin
                    nstate = S_IDLE;
                end
            end
            S_SW: begin
                if(sw_part_done) begin
                    nstate = S_IDLE;
                end
            end
            default: begin
                nstate = S_IDLE;
            end
        endcase
    end

    // reg ar_busy;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            ar_busy <= 1'b0;
        end
        else begin
            if(sw_start_en && sw_mode) begin
                ar_busy <= 1'b1;
            end
            else if(ar_last_req_done) begin
                ar_busy <= 1'b0;
            end
        end
    end
// end of state machine

    // reg [21:0] ar_full_burst_cnt;
    // reg [4:0] ar_last_burst_len;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            ar_full_burst_cnt <= 'b0;
            ar_last_burst_len <= 'b0;
        end
        else begin
            if(sw_start_en && sw_mode) begin
                ar_full_burst_cnt <= sw_size[26:5];
                ar_last_burst_len <= sw_size[4:0];
            end
            else begin
                if(ar_full_burst_cnt > 22'd0 && handshake_ar) begin
                    ar_full_burst_cnt <= ar_full_burst_cnt - 22'd1;
                end
            end
        end
    end

    // reg ar_last_req_done;
    always@ (*) begin
        ar_last_req_done = 1'b0;
        if(ar_busy && ar_full_burst_cnt == 'b0 && handshake_ar) begin
            ar_last_req_done = 1'b1;
        end
    end

    // reg [31:0] axi_araddr;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            axi_araddr <= 'b0;
        end
        else begin
            if(sw_start_en && sw_mode) begin
                axi_araddr <= sw_src_base_addr;
            end
            else if(handshake_ar && !ar_last_req_done) begin
                axi_araddr <= axi_araddr + 32'h00000100;
            end
        end
    end

    // reg axi_arlen;
    always@(*) begin
        if(ar_full_burst_cnt > 22'd0) begin
            axi_arlen = 5'h1F;
        end
        else begin
            axi_arlen = {3'b000, ar_last_burst_len};
        end
    end

    // reg axi_arvalid;
    always@ (*) begin
        axi_arvalid = ar_busy;
    end

    // reg db_start_q;
    // wire db_start_en;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            db_start_q <= 1'b0;
        end
        else begin
            db_start_q <= db_start;
        end
    end
    assign db_start_en = ({db_start_q, db_start} == 2'b01)? 1'b1:1'b0;
    
    // reg normal_db_req;
    // reg [15:0] db_info_normal_q;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            normal_db_req <= 1'b0;
            db_info_normal_q <= 'b0;
        end
        else begin
            if(db_start_en) begin
                normal_db_req <= 1'b1;
                db_info_normal_q <= db_info_normal;
            end
            else if(nstate == S_IDLE && cstate == S_NORMALDB) begin
                normal_db_req <= 1'b0;
            end
        end
    end

    // reg sw_start_q;
    // wire sw_start_en;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            sw_start_q <= 1'b0;
        end
        else begin
            sw_start_q <= sw_start;
        end
    end
    assign sw_start_en = ({sw_start_q, sw_start} == 2'b01)? 1'b1:1'b0;
    
    // reg sw_last_pack_done;
    always@ (*) begin
        sw_last_pack_done = 1'b0;
        if(sw_req && sw_full_pack_cnt == 'b0 && sw_part_done) begin
            sw_last_pack_done = 1'b1;
        end
    end

    // lock parameters
    // reg sw_req;
    // reg [15:0] db_info_sw_q;
    // reg sw_mode_q
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            sw_req <= 1'b0;
            sw_mode_q <= 1'b0;
            db_info_sw_q <= 'b0;
        end
        else begin
            if(sw_start_en && is_sw_src_align && is_sw_dst_align) begin
                sw_req <= 1'b1;
                sw_mode_q <= sw_mode;
                db_info_sw_q <= db_info_sw;
            end
            else begin
                if(sw_last_pack_done) begin
                    sw_req <= 1'b0;
                end
            end
        end
    end

    // reg sw_db_req;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            sw_db_req <= 1'b0;
        end
        else begin
            if(sw_last_pack_done) begin
                sw_db_req <= 1'b1;
            end
            else begin
                if(cstate == S_SWDB && nstate == S_IDLE) begin
                    sw_db_req <= 1'b0;
                end
            end
        end
    end

    // reg sw_full_pack_cnt;
    // reg sw_last_pack_size;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            sw_full_pack_cnt <= 'b0;
            sw_last_pack_size <= 'b0;
        end
        else begin
            if(sw_start_en) begin
                sw_full_pack_cnt <= sw_size[26:5];
                sw_last_pack_size <= sw_size[4:0];
            end
            else begin
                if(sw_full_pack_cnt > 22'd0 && sw_part_done) begin
                    sw_full_pack_cnt <= sw_full_pack_cnt - 22'd1;
                end
            end
        end
    end

    // reg [4:0] sw_part_size;
    always@(*) begin
        if(sw_full_pack_cnt > 22'd0) begin
            sw_part_size <= 5'h1F;
        end
        else begin
            sw_part_size <= sw_last_pack_size;
        end
    end

    // reg [31:0] sw_part_addr;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            sw_part_addr <= 'b0;
        end
        else begin
            if(sw_start_en) begin
                sw_part_addr <= sw_dst_base_addr;
            end
            else begin
                if(sw_full_pack_cnt > 22'd0 && sw_part_done) begin
                    sw_part_addr <= sw_part_addr + 32'h00000100;
                end
            end
        end
    end

    
    // reg db_done_i;
    always@(*) begin
        db_done_i = 1'b0;
        if(cstate == S_NORMALDB && nstate == S_IDLE) begin
            db_done_i = 1'b1;
        end
    end

    // reg sw_done_i;
    always@(*) begin
        sw_done_i = 1'b0;
        if(cstate == S_SWDB && nstate == S_IDLE) begin
            sw_done_i = 1'b1;
        end
    end

    // reg sw_err_src_unalign_i;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            sw_err_src_unalign_i <= 1'b0;
        end
        else begin
            if(sw_start_en && !is_sw_src_align) begin
                sw_err_src_unalign_i <= 1'b1;
            end
            else begin
                sw_err_src_unalign_i <= 1'b0;
            end
        end
    end

    // reg sw_err_dst_unalign_i;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            sw_err_dst_unalign_i <= 1'b0;
        end
        else begin
            if(sw_start_en && !is_sw_dst_align) begin
                sw_err_dst_unalign_i <= 1'b1;
            end
            else begin
                sw_err_dst_unalign_i <= 1'b0;
            end
        end
    end

    // reg db_part_start;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            db_part_start <= 1'b0;
        end
        else begin
            if(cstate == S_IDLE && (nstate == S_NORMALDB || nstate == S_SWDB)) begin
                db_part_start <= 1'b1;
            end
            else begin
                db_part_start <= 1'b0;
            end
        end
    end

    // reg [15:0] db_part_info;
    assign db_part_info = (cstate == S_SWDB)? db_info_sw_q : db_info_normal_q;

    // reg sw_part_start;
    always@ (posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            sw_part_start <= 1'b0;
        end
        else begin
            if(cstate == S_IDLE && nstate == S_SW) begin
                sw_part_start <= 1'b1;
            end
            else begin
                sw_part_start <= 1'b0;
            end
        end
    end

// db_tx_engine_inst
    db_tx_engine #(
        .C_SRIO_DEV_ID(C_SRIO_DEV_ID),
        .C_SRIO_DEST_ID(C_SRIO_DEST_ID)
    )
    db_tx_engine_inst(
        .aclk(aclk),                                // input aclk,
        .aresetn(aresetn),                          // input aresetn,

        .db_start(db_part_start),                   // input db_start, single cycle enable signal
        .db_info(db_part_info),                     // input [15:0] db_info,
        .db_done(db_part_done),                     // output db_done, single cycle enable signal, indicating has received db response

        .m_axis_ireq_tvalid(ireq_tvalid_db),        // output m_axis_ireq_tvalid,
        .m_axis_ireq_tready(m_axis_ireq_tready),    // input m_axis_ireq_tready,
        .m_axis_ireq_tdata(ireq_tdata_db),          // output [63:0] m_axis_ireq_tdata,
        .m_axis_ireq_tlast(ireq_tlast_db),          // output m_axis_ireq_tlast,

        .s_axis_iresp_tvalid(s_axis_iresp_tvalid),  // input s_axis_iresp_tvalid,
        .s_axis_iresp_tready(s_axis_iresp_tready),  // output s_axis_iresp_tready,
        .s_axis_iresp_tdata(s_axis_iresp_tdata),    // input [63:0] s_axis_iresp_tdata,
        .s_axis_iresp_tkeep(s_axis_iresp_tkeep),    // input [7:0] s_axis_iresp_tkeep,
        .s_axis_iresp_tlast(s_axis_iresp_tlast)     // input s_axis_iresp_tlast,
    );
// end of db_tx_engine_inst

// sw_tx_engine_inst
    sw_tx_engine #(
        .C_SRIO_DEV_ID(C_SRIO_DEV_ID),
        .C_SRIO_DEST_ID(C_SRIO_DEST_ID)
    )
    sw_tx_engine_inst(
        .aclk(aclk),                                // input aclk,
        .aresetn(aresetn),                          // input aresetn,

        .sw_start(sw_part_start),                   // input sw_start,
        .sw_mode(sw_mode_q),                        // input sw_mode,
        .sw_size(sw_part_size),                     // input [4:0] sw_size,
        .sw_addr(sw_part_addr),                     // input [31:0] sw_addr,
        .sw_done(sw_part_done),                     // output sw_done,

        .m_axis_ireq_tvalid(ireq_tvalid_sw),        // output m_axis_ireq_tvalid,
        .m_axis_ireq_tready(m_axis_ireq_tready),    // input m_axis_ireq_tready,
        .m_axis_ireq_tdata(ireq_tdata_sw),          // output [63:0] m_axis_ireq_tdata,
        .m_axis_ireq_tlast(ireq_tlast_sw),          // output m_axis_ireq_tlast,

        .s_axis_h2c_tvalid(s_axis_h2c_tvalid),      // input s_axis_h2c_tvalid,
        .s_axis_h2c_tready(s_axis_h2c_tready),      // output s_axis_h2c_tready,
        .s_axis_h2c_tdata(s_axis_h2c_tdata),        // input [63:0] s_axis_h2c_tdata,
        .s_axis_h2c_tkeep(s_axis_h2c_tkeep),        // input [7:0] s_axis_h2c_tkeep,
        .s_axis_h2c_tlast(s_axis_h2c_tlast),        // input s_axis_h2c_tlast,

        .m_axi_rdata(m_axi_rdata),                  // input [63 : 0] m_axi_rdata,
        .m_axi_rlast(m_axi_rlast),                  // input m_axi_rlast,
        .m_axi_rvalid(m_axi_rvalid),                // input m_axi_rvalid,
        .m_axi_rready(m_axi_rready)                 // output m_axi_rready
    );
// end of sw_tx_engine_inst

endmodule
