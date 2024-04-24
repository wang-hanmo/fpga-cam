module dual_port_g_aetcam_cell
(
    input   logic clk,
    input   logic rst_n,
    input   logic wen_0,
    input   logic w_St_el_0,
    input   logic w_M_el_0,
    input   logic wen_1,
    input   logic w_St_el_1,
    input   logic w_M_el_1,
    input   logic S_w_0,
    output  logic En_w_0,
    input   logic S_w_1,
    output  logic En_w_1
);

logic St_el;
logic M_el;
logic match_0, match_1;

always_ff @(posedge clk) begin
    if(!rst_n) begin
        St_el <= 1'b0;
        M_el  <= 1'b0;
    end
    else if(wen_0) begin
        St_el <= w_St_el_0;
        M_el  <= w_M_el_0;
    end
    else if(wen_1) begin
        St_el <= w_St_el_1;
        M_el  <= w_M_el_1;
    end
end

assign match_0 = ~S_w_0 ^ St_el;
assign En_w_0  = match_0 | M_el;
assign match_1 = ~S_w_1 ^ St_el;
assign En_w_1  = match_1 | M_el;

endmodule