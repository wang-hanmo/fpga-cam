module triple_port_g_aetcam
#( 
   parameter                    DEPTH = 64,     // CAM depth
   parameter                    WIDTH = 36      // CAM width
)( 
    input  logic                        clk,    // clock
    input  logic                        rst_n,  // reset
    input  logic                        wEn_0,    // write enable
    input  logic[$clog2(DEPTH)-1 : 0]   wAddr_0,  // write address
    input  logic[WIDTH-1 : 0]           wPatt_0,  // write pattern
    input  logic[WIDTH-1 : 0]           wMask_0,  // pattern mask    
    input  logic[WIDTH-1 : 0]           mPatt_0,  // patern to match
    output logic                        match_0,  // match indicator 
    output logic[$clog2(DEPTH)-1 : 0]   mAddr_0,  // matched address
    input  logic                        wEn_1,    // write enable
    input  logic[$clog2(DEPTH)-1 : 0]   wAddr_1,  // write address
    input  logic[WIDTH-1 : 0]           wPatt_1,  // write pattern
    input  logic[WIDTH-1 : 0]           wMask_1,  // pattern mask    
    input  logic[WIDTH-1 : 0]           mPatt_1,  // patern to match
    output logic                        match_1,  // match indicator 
    output logic[$clog2(DEPTH)-1 : 0]   mAddr_1,  // matched address
    input  logic                        wEn_2,    // write enable
    input  logic[$clog2(DEPTH)-1 : 0]   wAddr_2,  // write address
    input  logic[WIDTH-1 : 0]           wPatt_2,  // write pattern
    input  logic[WIDTH-1 : 0]           wMask_2,  // pattern mask    
    input  logic[WIDTH-1 : 0]           mPatt_2,  // patern to match
    output logic                        match_2,  // match indicator 
    output logic[$clog2(DEPTH)-1 : 0]   mAddr_2   // matched address
);

    logic[DEPTH-1 : 0] wen_0;
    logic[DEPTH-1 : 0] wen_1;
    logic[DEPTH-1 : 0] wen_2;
    logic[DEPTH-1 : 0][WIDTH-1 : 0] En_w_0;
    logic[DEPTH-1 : 0][WIDTH-1 : 0] En_w_1;
    logic[DEPTH-1 : 0][WIDTH-1 : 0] En_w_2;
    logic[DEPTH-1 : 0] M_L_0;
    logic[DEPTH-1 : 0] M_L_1;
    logic[DEPTH-1 : 0] M_L_2;

    // generate flip_flops
    for (genvar i = 0; i < DEPTH; i++) begin : gen_word_level_ff
        for (genvar j = 0; j < WIDTH; j++) begin : gen_bit_level_ff
            triple_port_g_aetcam_cell inst_g_aetcam_cell(
                .clk(clk),
                .rst_n(rst_n),
                .wen_0(wen_0[i]),
                .w_St_el_0(wPatt_0[j]),
                .w_M_el_0(wMask_0[j]),
                .wen_1(wen_1[i]),
                .w_St_el_1(wPatt_1[j]),
                .w_M_el_1(wMask_1[j]),
                .wen_2(wen_2[i]),
                .w_St_el_2(wPatt_2[j]),
                .w_M_el_2(wMask_2[j]),
                .S_w_0(mPatt_0[j]),
                .En_w_0(En_w_0[i][j]),
                .S_w_1(mPatt_1[j]),
                .En_w_1(En_w_1[i][j]),
                .S_w_2(mPatt_2[j]),
                .En_w_2(En_w_2[i][j])
            );
        end
    end

    // write address select
    for (genvar k = 0; k < DEPTH; k++) begin : write_addr_sel
        assign wen_0[k] = wEn_0 & (wAddr_0 == k);
        assign wen_1[k] = wEn_1 & (wAddr_1 == k);
        assign wen_2[k] = wEn_2 & (wAddr_2 == k);
    end

    // AND gate array for each location
    for (genvar l = 0; l < DEPTH; l++) begin : and_gate_array
        assign M_L_0[l] = &(En_w_0[l]);
        assign M_L_1[l] = &(En_w_1[l]);
        assign M_L_2[l] = &(En_w_2[l]);
    end

    // priority encoder
    pe #(
        .Width(DEPTH)
    ) inst_pe_0 (
        .in(M_L_0),
        .out(mAddr_0)
    );
    pe #(
        .Width(DEPTH)
    ) inst_pe_1 (
        .in(M_L_1),
        .out(mAddr_1)
    );
    pe #(
        .Width(DEPTH)
    ) inst_pe_2 (
        .in(M_L_2),
        .out(mAddr_2)
    );

    // judge whether match or not
    assign match_0 = |M_L_0;
    assign match_1 = |M_L_1;
    assign match_2 = |M_L_2;

endmodule