module ue_tcam
#( 
   parameter                    DEPTH = 512,     // CAM depth
   parameter                    WIDTH = 36,      // CAM width
   parameter                    L = 4,           // vertical partition
   parameter                    N = 4            // horizontal partition
)( 
    input  logic                        clk,    // clock
    input  logic                        rst_n,  // reset
    input  logic                        wEn,    // write enable
    input  logic[$clog2(DEPTH)-1 : 0]   wAddr,  // write address
    input  logic[WIDTH-1 : 0]           wPatt,  // write pattern
    input  logic[DEPTH/L-1 : 0]         wKbit,  // Address coding
    input  logic[WIDTH-1 : 0]           mPatt,  // patern to match
    output logic                        match,  // match indicator 
    output logic[$clog2(DEPTH)-1 : 0]   mAddr   // matched address
);
    localparam SW_WIDTH = WIDTH / N;    // subword width
    localparam SA_DEPTH = DEPTH / L;    // sub-address range depth

    logic [L-1:0] hp_wen;
    logic [N-1:0][SW_WIDTH-1:0] hp_addr;
    logic [SA_DEPTH-1:0] hp_din;
    logic [L-1:0][N-1:0][SA_DEPTH-1:0] hp_dout;

    logic [L-1:0][SA_DEPTH-1:0] pma;
    logic [L*SA_DEPTH-1:0] pma_join;

    // generate Block RAM
    for (genvar i = 0; i < L; i++) begin : gen_layer
        for (genvar j = 0; j < N; j++) begin : gen_sram_unit
            bram #(
                .Depth(2**SW_WIDTH),
                .Width(SA_DEPTH)
            ) inst_sram_unit (
                .clk(clk), 
                .en(1'b1),
                .wen(hp_wen[i]),
                .addr(hp_addr[j]),
                .din(hp_din),
                .dout(hp_dout[i][j])
            );
        end
    end

    // input generation
    for (genvar k = 0; k < L; k++) begin : layer_input
        assign hp_wen[k] = wEn & (wAddr[$clog2(DEPTH)-1: $clog2(SA_DEPTH)] == k);
    end
    for (genvar l = 0; l < N; l++) begin : sram_unit_input
        assign hp_addr[l] = wEn ? wPatt[(l+1)*SW_WIDTH-1 : l*SW_WIDTH] : mPatt[(l+1)*SW_WIDTH-1 : l*SW_WIDTH];
    end
    // assign hp_din = 1 << wAddr[$clog2(SA_DEPTH)-1 : 0];
    assign hp_din = wKbit;

    // output generation
    always_comb begin
        for (integer m = 0; m < L; m++) begin : layer_output
            pma[m] = {(SA_DEPTH){1'b1}};
            // k-bit AND operation
            for (integer n = 0; n < N; n++) begin : sram_unit_output
                pma[m] = pma[m] & hp_dout[m][n];
            end
        end
    end
    
    for (genvar p = 0; p < L; p++) begin
        assign pma_join[(p+1)*SA_DEPTH-1 : p*SA_DEPTH] = pma[p];
    end
    
    // priority encoder
    pe #(
        .Width(L*SA_DEPTH)
    ) inst_pe (
        .in(pma_join),
        .out(mAddr)
    );

    // judge whether match or not
    assign match = |pma_join;

endmodule