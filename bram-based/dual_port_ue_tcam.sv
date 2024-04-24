module dual_port_ue_tcam
#( 
   parameter                    DEPTH = 512,     // CAM depth
   parameter                    WIDTH = 36,      // CAM width
   parameter                    L = 4,           // vertical partition
   parameter                    N = 4            // horizontal partition
)( 
    input  logic                        clk,    // clock
    input  logic                        rst_n,  // reset
    input  logic                        wEn_0,  // write enable
    input  logic[$clog2(DEPTH)-1 : 0]   wAddr_0,// write address
    input  logic[WIDTH-1 : 0]           wPatt_0,// write pattern
    input  logic[DEPTH/L-1 : 0]         wKbit_0,// Address coding
    input  logic[WIDTH-1 : 0]           mPatt_0,// patern to match
    output logic                        match_0,// match indicator 
    output logic[$clog2(DEPTH)-1 : 0]   mAddr_0,// matched address
    input  logic                        wEn_1,  // write enable
    input  logic[$clog2(DEPTH)-1 : 0]   wAddr_1,// write address
    input  logic[WIDTH-1 : 0]           wPatt_1,// write pattern
    input  logic[DEPTH/L-1 : 0]         wKbit_1,// Address coding
    input  logic[WIDTH-1 : 0]           mPatt_1,// patern to match
    output logic                        match_1,// match indicator 
    output logic[$clog2(DEPTH)-1 : 0]   mAddr_1 // matched address
);
    localparam SW_WIDTH = WIDTH / N;    // subword width
    localparam SA_DEPTH = DEPTH / L;    // sub-address range depth

    logic [L-1:0] hp_wen_0;
    logic [L-1:0] hp_wen_1;
    logic [N-1:0][SW_WIDTH-1:0] hp_addr_0;
    logic [N-1:0][SW_WIDTH-1:0] hp_addr_1;
    logic [SA_DEPTH-1:0] hp_din_0;
    logic [SA_DEPTH-1:0] hp_din_1;
    logic [L-1:0][N-1:0][SA_DEPTH-1:0] hp_dout_0;
    logic [L-1:0][N-1:0][SA_DEPTH-1:0] hp_dout_1;

    logic [L-1:0][SA_DEPTH-1:0] pma_0;
    logic [L-1:0][SA_DEPTH-1:0] pma_1;
    logic [L*SA_DEPTH-1:0] pma_join_0;
    logic [L*SA_DEPTH-1:0] pma_join_1;

    // generate Block RAM
    for (genvar i = 0; i < L; i++) begin : gen_layer
        for (genvar j = 0; j < N; j++) begin : gen_sram_unit
            dual_port_bram #(
                .Depth(2**SW_WIDTH),
                .Width(SA_DEPTH)
            ) inst_sram_unit (
                .clk(clk), 
                .en_0(1'b1),
                .wen_0(hp_wen_0[i]),
                .addr_0(hp_addr_0[j]),
                .din_0(hp_din_0),
                .dout_0(hp_dout_0[i][j]),
                .en_1(1'b1),
                .wen_1(hp_wen_1[i]),
                .addr_1(hp_addr_1[j]),
                .din_1(hp_din_1),
                .dout_1(hp_dout_1[i][j])
            );
        end
    end

    // input generation
    for (genvar k = 0; k < L; k++) begin : layer_input
        assign hp_wen_0[k] = wEn_0 & (wAddr_0[$clog2(DEPTH)-1: $clog2(SA_DEPTH)] == k);
        assign hp_wen_1[k] = wEn_1 & (wAddr_1[$clog2(DEPTH)-1: $clog2(SA_DEPTH)] == k);
    end
    for (genvar l = 0; l < N; l++) begin : sram_unit_input
        assign hp_addr_0[l] = wEn_0 ? wPatt_0[(l+1)*SW_WIDTH-1 : l*SW_WIDTH] : mPatt_0[(l+1)*SW_WIDTH-1 : l*SW_WIDTH];
        assign hp_addr_1[l] = wEn_1 ? wPatt_1[(l+1)*SW_WIDTH-1 : l*SW_WIDTH] : mPatt_1[(l+1)*SW_WIDTH-1 : l*SW_WIDTH];
    end
    // assign hp_din = 1 << wAddr[$clog2(SA_DEPTH)-1 : 0];
    assign hp_din_0 = wKbit_0;
    assign hp_din_1 = wKbit_1;

    // output generation
    always_comb begin
        for (integer m = 0; m < L; m++) begin : layer_output
            pma_0[m] = {(SA_DEPTH){1'b1}};
            pma_1[m] = {(SA_DEPTH){1'b1}};
            // k-bit AND operation
            for (integer n = 0; n < N; n++) begin : sram_unit_output
                pma_0[m] = pma_0[m] & hp_dout_0[m][n];
                pma_1[m] = pma_1[m] & hp_dout_1[m][n];
            end
        end
    end
    
    for (genvar p = 0; p < L; p++) begin
        assign pma_join_0[(p+1)*SA_DEPTH-1 : p*SA_DEPTH] = pma_0[p];
        assign pma_join_1[(p+1)*SA_DEPTH-1 : p*SA_DEPTH] = pma_1[p];
    end
    
    // priority encoder
    pe #(
        .Width(L*SA_DEPTH)
    ) inst_pe_0 (
        .in(pma_join_0),
        .out(mAddr_0)
    );
    pe #(
        .Width(L*SA_DEPTH)
    ) inst_pe_1 (
        .in(pma_join_1),
        .out(mAddr_1)
    );

    // judge whether match or not
    assign match_0 = |pma_join_0;
    assign match_1 = |pma_join_1;

endmodule