module g_aetcam
#( 
   parameter                    DEPTH = 64,     // CAM depth
   parameter                    WIDTH = 36      // CAM width
)( 
    input  logic                        clk,    // clock
    input  logic                        rst_n,  // reset
    input  logic                        wEn,    // write enable
    input  logic[$clog2(DEPTH)-1 : 0]   wAddr,  // write address
    input  logic[WIDTH-1 : 0]           wPatt,  // write pattern
    input  logic[WIDTH-1 : 0]           wMask,  // pattern mask    
    input  logic[WIDTH-1 : 0]           mPatt,  // patern to match
    output logic                        match,  // match indicator 
    output logic[$clog2(DEPTH)-1 : 0]   mAddr   // matched address
);
    logic[DEPTH-1 : 0] wen;
    logic[DEPTH-1 : 0][WIDTH-1 : 0] En_w;
    logic[DEPTH-1 : 0] M_L;

    // generate flip_flops
    for (genvar i = 0; i < DEPTH; i++) begin : gen_word_level_ff
        for (genvar j = 0; j < WIDTH; j++) begin : gen_bit_level_ff
            g_aetcam_cell inst_g_aetcam_cell(
                .clk(clk),
                .rst_n(rst_n),
                .wen(wen[i]),
                .w_St_el(wPatt[j]),
                .w_M_el(wMask[j]),
                .S_w(mPatt[j]),
                .En_w(En_w[i][j])
            );
        end
    end

    // write address select
    for (genvar k = 0; k < DEPTH; k++) begin : write_addr_sel
        assign wen[k] = wEn & (wAddr == k);
    end

    // AND gate array for each location
    for (genvar l = 0; l < DEPTH; l++) begin : and_gate_array
        assign M_L[l] = &(En_w[l]);
    end

    // priority encoder
    pe #(
        .Width(DEPTH)
    ) inst_pe (
        .in(M_L),
        .out(mAddr)
    );

    // judge whether match or not
    assign match = |M_L;

endmodule