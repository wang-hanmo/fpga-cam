module dure_tcam
#( 
   parameter                    DEPTH = 512,     // CAM depth
   parameter                    WIDTH = 36       // CAM width
)( 
    input  logic                        clk,    // clock
    input  logic                        rst_n,  // reset
    input  logic                        wEn,    // write enable
    input  logic[$clog2(DEPTH)-1 : 0]   wAddr,  // write address
    input  logic[WIDTH-1 : 0]           wPatt,  // write pattern
    input  logic[WIDTH-1 : 0]           mPatt,  // patern to match
    output logic                        match,  // match indicator 
    output logic[$clog2(DEPTH)-1 : 0]   mAddr   // matched address
);
    localparam BLOCK_NUM = WIDTH / 18;

    logic [BLOCK_NUM-1:0][17:0] K;
    logic [BLOCK_NUM-1:0] dia;
    logic [BLOCK_NUM-1:0] dib;
    logic [BLOCK_NUM-1:0] dic;
    logic [DEPTH-1:0] we;
    logic [DEPTH-1:0][BLOCK_NUM-1:0] cin;
    logic [DEPTH-1:0][BLOCK_NUM-1:0] cout;
    logic [DEPTH-1:0] MV;
    
    logic [5:0] counter;

    for (genvar i = 0; i < DEPTH; i++) begin : gen_word_level_lutram
        for (genvar j = 0; j < BLOCK_NUM; j++) begin : gen_bit_level_lutram
            bm_18 inst_bm_block(
                .clk(clk),
                .we(we[i]),
                .addra(K[j][5:0]),
                .dia(dia[j]),
                .addrb(K[j][11:6]),
                .dib(dib[j]),
                .addrc(K[j][17:12]),
                .dic(dic[j]),
                .addrd(counter),
                .did(1'b1),
                .cin(cin[i][j]),
                .cout(cout[i][j])
            );
        end
    end

    for(genvar k = 0; k < BLOCK_NUM; k++) begin
        assign K[k] = wEn ? wPatt[(k+1)*18-1 : k*18] : mPatt[(k+1)*18-1 : k*18];
        assign dia[k] = (K[k][5:0] == counter) ? 1 : 0;
        assign dib[k] = (K[k][11:6] == counter) ? 1 : 0;
        assign dic[k] = (K[k][17:12] == counter) ? 1 : 0;
    end
    for(genvar l = 0; l < DEPTH; l++) begin
        assign we[l] = wEn & (wAddr == l);
    end
    for (genvar m = 0; m < DEPTH; m++) begin
        for (genvar n = 0; n < BLOCK_NUM; n++) begin
            assign cin[m][n] = (n == 0) ? 1'b1 : cout[m][n-1];
        end
    end

    always_ff @ (posedge clk) begin
        if(!rst_n)
            counter <= 6'd0;
        else if(wEn)
            counter <= counter + 1;
    end

    // match vector
    for (genvar p = 0; p < DEPTH; p++) begin
        assign MV[p] = cout[p][BLOCK_NUM-1];
    end
    
    // priority encoder
    pe #(
        .Width(DEPTH)
    ) inst_pe (
        .in(MV),
        .out(mAddr)
    );

    // judge whether match or not
    assign match = |MV;

endmodule