module ntt_butterfly (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        in_valid,
    input  logic [11:0] a,
    input  logic [11:0] b,
    input  logic [11:0] zeta,    // public constant, Montgomery domain
    output logic        out_valid,
    output logic [11:0] a_out,
    output logic [11:0] b_out
);

/* verilator lint_off UNUSED */
logic [27:0] t_s2;
logic [31:0] m_full;
/* verilator lint_on UNUSED */


// wires connecting butterfly to the reducer
logic [23:0] bz_product;   // b * zeta, 24-bit product
logic [11:0] t;             // reducer output
logic        t_valid;       // reducer's out_valid

assign bz_product = b * zeta; 
mont_reduce mont_reducer (        
    .clk      (clk),
    .rst_n    (rst_n),
    .in_valid (in_valid),
    .x        (bz_product),
    .out_valid(t_valid),
    .z        (t)
);

//shift register for a
logic [11:0] a_dly [0:3];

// final butterfly 
logic [12:0] a_sum; // 13-bit sum to avoid overflow
assign a_sum = a_dly[3] + t;

logic [12:0] b_sum; // 13-bit difference to avoid underflow
assign b_sum = a_dly[3] + 13'd3329 - t;

always_ff @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
    a_dly[0] <= 12'd0;
    a_dly[1] <= 12'd0;
    a_dly[2] <= 12'd0;
    a_dly[3] <= 12'd0;
    a_out <= 12'd0;
    b_out <= 12'd0;
    out_valid <= 1'b0;
    end else begin
// shift reg
a_dly[0] <= a;
a_dly[1] <= a_dly[0];
a_dly[2] <= a_dly[1];
a_dly[3] <= a_dly[2];

out_valid <= t_valid;

// a' = a + t mod q
a_out <= (a_sum  >= 13'd3329) ? a_sum[11:0]  - 12'd3329 : a_sum[11:0];

// b' = a - t mod q  (using a + q - t to stay unsigned)
b_out <= (b_sum  >= 13'd3329) ? b_sum[11:0]  - 12'd3329 : b_sum[11:0];


end
end
endmodule
