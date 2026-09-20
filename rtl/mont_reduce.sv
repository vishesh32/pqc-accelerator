module mont_reduce (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        in_valid,
    input  logic [23:0] x,
    output logic        out_valid,
    output logic [11:0] z
);

    
    // constants -- localparam for things that never change
    localparam logic [11:0] Q         = 12'd3329;
    localparam logic [15:0] Q_NEG_INV = 16'd3327;  // -q^-1 mod 2^16, pairs with ADD

    // stage 1 registers 
    logic [23:0] x_s1;       // x delayed one cycle
    logic [15:0] m_s1;       // m computed in stage 1

    // stage 2 register
    logic [27:0] t_s2; 

    // validity tracking shift register
    logic [2:0]  v;           // v[0]=after stage1, v[1]=after stage2, v[2]=output

    // stage 1: combinational portion
    logic [15:0] x_low;
    logic [31:0] m_full;
    logic [15:0] m;
    logic [27:0] mq;
    assign mq = m_s1 * Q;   // 16x12 = max 218,166,015, fits in 28 bits

    assign x_low  = x[15:0];
    assign m_full = x_low * Q_NEG_INV;   // 16x16 = 32 bit product
    assign m      = m_full[15:0];         // bottom 16 bits = mod 2^16

    // all three pipeline registers in one always_ff
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_s1 <= 24'd0;
            m_s1 <= 16'd0;
            t_s2 <= 28'd0;
            z    <= 12'd0;
            v    <= 3'd0;
        end else begin
            // stage 1: register x and m
            x_s1 <= x;
            m_s1 <= m;

            // stage 2: compute and register t
            t_s2 <= {4'b0, x_s1} + mq;  

            // stage 3: shift and conditional subtract
            if (t_s2[27:16] >= Q) begin
                z <= t_s2[27:16] - Q;
            end else begin
                z <= t_s2[27:16];
            end

            // validity pipeline
            v[0] <= in_valid;
            v[1] <= v[0];
            v[2] <= v[1];
        end
    end

    assign out_valid = v[2];

endmodule
