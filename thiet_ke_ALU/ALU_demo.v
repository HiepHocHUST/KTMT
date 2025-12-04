// iverilog -o ketqua ALU_demo_tb.v thiet_ke_ALU/ALU.v thiet_ke_ALU/Mux_8to1.v thiet_ke_ALU/Mux_2to1.v
// vvp ketqua.vvp
// GTKWave: gtkwave ketqua_alu.vcd
module ALU #(
    parameter DATA_WIDTH = 32,
    parameter ALU_OP_WIDTH = 4
)
(
    input  [DATA_WIDTH-1:0]   operand_a, operand_b,
    input  [ALU_OP_WIDTH-1:0] alu_op, 
    output [DATA_WIDTH-1:0]   alu_result,
    output                    zero_flag, overflow_flag
);

    // =================================================================
    // PHẦN 1: TÍNH TOÁN (EXECUTION STAGE) - CẢI TIẾN
    // =================================================================
    
    // 1. Logic xác định chế độ TRỪ (Subtraction Mode)
    // SUB (0110) hoặc SLT (0111) đều cần thực hiện phép trừ
    wire is_sub_mode;
    assign is_sub_mode = (alu_op == 4'b0110) || (alu_op == 4'b0111);

    // 2. Chuẩn bị toán hạng B cho bộ cộng (Adder Input Logic)
    // Nguyên lý Bù 2: A - B = A + (~B) + 1
    // Nếu là phép trừ: đảo bit B. Nếu cộng: giữ nguyên B.
    wire [DATA_WIDTH-1:0] operand_b_mux;
    assign operand_b_mux = is_sub_mode ? ~operand_b : operand_b;

    // 3. Bộ cộng tổng quát (Shared Adder)
    // Thực hiện: A + operand_b_mux + cin
    // cin chính là is_sub_mode (vì khi trừ cần cộng thêm 1)
    wire [DATA_WIDTH-1:0] adder_result;
    assign adder_result = operand_a + operand_b_mux + { {DATA_WIDTH-1{1'b0}}, is_sub_mode };

    // 4. Các kết quả logic khác (vẫn giữ nguyên)
    wire [DATA_WIDTH-1:0] res_and = operand_a & operand_b;
    wire [DATA_WIDTH-1:0] res_or  = operand_a | operand_b;
    wire [DATA_WIDTH-1:0] res_xor = operand_a ^ operand_b;
    wire [DATA_WIDTH-1:0] res_nor = ~(operand_a | operand_b);

    // 5. Gán kết quả từ bộ cộng sang các dây tín hiệu tương ứng
    wire [DATA_WIDTH-1:0] res_add = adder_result; // Kết quả ADD
    wire [DATA_WIDTH-1:0] res_sub = adder_result; // Kết quả SUB (chính là adder_result khi mode=1)

    // =================================================================
    // PHẦN CỜ BÁO (FLAGS) - TÍNH TRƯỚC ĐỂ DÙNG CHO SLT
    // =================================================================
    // Tính Overflow dựa trên dấu của input và output bộ cộng
    // Overflow xảy ra khi 2 số cùng dấu cộng lại ra số trái dấu
    wire sa = operand_a[DATA_WIDTH-1];
    wire sb = operand_b_mux[DATA_WIDTH-1]; // Lưu ý dùng b_mux (đã đảo nếu là trừ)
    wire sr = adder_result[DATA_WIDTH-1];
    
    // Logic Overflow chuẩn cho bộ cộng
    assign overflow_flag = ~(sa ^ sb) & (sa ^ sr);

    // Logic Zero
    // Lưu ý: Zero flag thường được tính dựa trên output cuối cùng (alu_result),
    // nhưng ở đây ta tính dựa trên kết quả phép tính logic/số học để nhất quán.
    // Ở đoạn cuối module bạn đã có assign zero_flag = (alu_result == 0) -> Giữ nguyên cái đó.

    // 6. Tính kết quả SLT (Set Less Than)
    // SLT = 1 nếu (A < B). Về bản chất là A - B < 0.
    // Logic chuẩn: Kết quả bit dấu (MSB) XOR với Overflow
    wire slt_bit = sr ^ overflow_flag;
    wire [DATA_WIDTH-1:0] res_slt;
    wire [DATA_WIDTH-1:0] ground = {DATA_WIDTH{1'b0}};
    
    assign res_slt = {ground[DATA_WIDTH-1:1], slt_bit};

    // =================================================================
    // PHẦN 2: CẤU TRÚC MUX TREE (Selection Logic) - GIỮ NGUYÊN
    // =================================================================
    
    wire [DATA_WIDTH-1:0] wire_mux_low_out;
    wire [DATA_WIDTH-1:0] wire_mux_high_out;
    
    wire [2:0] sel_low_bits = alu_op[2:0];
    wire       sel_high_bit = alu_op[3];

    // MUX CON 1
    Mux_8to1 #( .WIDTH(DATA_WIDTH) ) MUX_LOW_UNIT (
        .d0(res_and),   // 0000
        .d1(res_or),    // 0001
        .d2(res_add),   // 0010 (Lấy từ Shared Adder)
        .d3(ground),    
        .d4(res_xor),   // 0100
        .d5(ground),    
        .d6(res_sub),   // 0110 (Lấy từ Shared Adder)
        .d7(res_slt),   // 0111 (Tính toán kỹ thuật số)
        .sel(sel_low_bits), 
        .y(wire_mux_low_out)
    );

    // MUX CON 2
    Mux_8to1 #( .WIDTH(DATA_WIDTH) ) MUX_HIGH_UNIT (
        .d0(ground),    
        .d1(ground),    
        .d2(ground),    
        .d3(ground),    
        .d4(res_nor),   // 1100
        .d5(ground),    
        .d6(ground),    
        .d7(ground),    
        .sel(sel_low_bits), 
        .y(wire_mux_high_out)
    );

    // MUX TỔNG
    Mux_2to1 #( .WIDTH(DATA_WIDTH) ) MUX_FINAL_UNIT (
        .d0(wire_mux_low_out),   
        .d1(wire_mux_high_out),  
        .sel(sel_high_bit),
        .y(alu_result)           
    );

    // =================================================================
    // PHẦN 3: CỜ BÁO (FLAGS) - OUTPUT
    // =================================================================
    assign zero_flag = (alu_result == 0);
    // overflow_flag đã được assign ở trên

endmodule