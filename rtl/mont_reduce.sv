module mont_reduce (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        in_valid,
    input  logic [23:0] x,
    output logic        out_valid,
    output logic [11:0] z
);
    localparam logic [11:0] Q         = 12'd3329;
    localparam logic [15:0] Q_NEG_INV = 16'd3327;

    logic [23:0] x_s1;
    logic [15:0] m_s1;

    /* verilator lint_off UNUSED */
    logic [27:0] t_s2;    // [15:0] discarded by >>16 -- intentional
    /* verilator lint_on UNUSED */

    logic [2:0]  v;
    logic [15:0] x_low;

    /* verilator lint_off UNUSED */
    logic [31:0] m_full;  // [31:16] discarded by mod 2^16 -- intentional
    /* verilator lint_on UNUSED */

    logic [15:0] m;
    logic [27:0] mq;

    assign mq    = m_s1 * Q;
    assign x_low = x[15:0];
    assign m_full = x_low * Q_NEG_INV;
    assign m      = m_full[15:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_s1 <= 24'd0;
            m_s1 <= 16'd0;
            t_s2 <= 28'd0;
            z    <= 12'd0;
            v    <= 3'd0;
        end else begin
            x_s1 <= x;
            m_s1 <= m;
            t_s2 <= {4'b0, x_s1} + mq;
            if (t_s2[27:16] >= Q) begin
                z <= t_s2[27:16] - Q;
            end else begin
                z <= t_s2[27:16];
            end
            v[0] <= in_valid;
            v[1] <= v[0];
            v[2] <= v[1];
        end
    end

    assign out_valid = v[2];

endmodule
