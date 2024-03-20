module g_aetcam_cell
(
    input   logic clk,
    input   logic rst_n,
    input   logic wen,
    input   logic w_St_el,
    input   logic w_M_el,
    input   logic S_w,
    output  logic En_w
);

logic St_el;
logic M_el;
logic match;

always_ff @(posedge clk) begin
    if(!rst_n) begin
        St_el <= 1'b0;
        M_el  <= 1'b0;
    end
    else if(wen) begin
        St_el <= w_St_el;
        M_el  <= w_M_el;
    end
end

assign match = ~S_w ^ St_el;
assign En_w  = match | M_el;

endmodule