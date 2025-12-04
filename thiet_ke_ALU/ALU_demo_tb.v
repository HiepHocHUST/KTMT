`timescale 1ns / 1ps

module tb_ALU;

    // 1. KHAI BÁO TÍN HIỆU (Signal Declaration)
    // Inputs (phải là reg để gán giá trị trong initial)
    reg [31:0] operand_a;
    reg [31:0] operand_b;
    reg [3:0]  alu_op; // QUAN TRỌNG: 4 bit để điều khiển Mux High/Low

    // Outputs (phải là wire để nối ra từ module)
    wire [31:0] alu_result;
    wire        zero_flag;
    wire        overflow_flag;

    // 2. KẾT NỐI VỚI MODULE ALU (Instantiation)
    // Tên tham số (.operand_a) phải khớp với file ALU.v
    ALU #(
        .DATA_WIDTH(32),
        .ALU_OP_WIDTH(4)
    ) uut (
        .operand_a(operand_a), 
        .operand_b(operand_b), 
        .alu_op(alu_op),
        .alu_result(alu_result), 
        .zero_flag(zero_flag), 
        .overflow_flag(overflow_flag)
    );

    // 3. HÀM IN KẾT QUẢ (Helper Task)
    task print_res;
        input [8*5:1] op_name; // Tên phép toán (để in cho đẹp)
        begin
            $display("%4t | %s | %h | %h | %h |  %b   |   %b", 
                     $time, op_name, operand_a, operand_b, alu_result, zero_flag, overflow_flag);
        end
    endtask

    // 4. KỊCH BẢN TEST (Test Vectors)
    initial begin
        // Tạo file sóng (dành cho GTKWave / ModelSim)
        $dumpfile("ketqua_alu.vcd");
        $dumpvars(0, tb_ALU);

        // In tiêu đề bảng
        $display("Time |  Op Name  |  Operand A   |  Operand B   |  ALU Result  | Zero | Ovflow");
        $display("-----------------------------------------------------------------------------");

        // --- TEST NHÓM MUX LOW (Bit 3 = 0) ---

        // 1. AND (Opcode 0000)
        operand_a = 32'hFFFF0000; operand_b = 32'h00FFFF00; alu_op = 4'b0000; 
        #10; print_res("AND  ");

        // 2. OR (Opcode 0001)
        operand_a = 32'hF0F0F0F0; operand_b = 32'h0F0F0F0F; alu_op = 4'b0001; 
        #10; print_res("OR   ");

        // 3. ADD (Opcode 0010)
        operand_a = 32'd15; operand_b = 32'd25; alu_op = 4'b0010; 
        #10; print_res("ADD  ");

        // 4. XOR (Opcode 0100)
        operand_a = 32'hAAAAAAAA; operand_b = 32'h55555555; alu_op = 4'b0100; 
        #10; print_res("XOR  ");

        // 5. SUB & Zero Check (Opcode 0110)
        // 50 - 50 = 0 -> Zero flag phải = 1
        operand_a = 32'd50; operand_b = 32'd50; alu_op = 4'b0110; 
        #10; print_res("SUB=0");

        // 6. SLT (Opcode 0111)
        // 10 < 20 -> Kết quả phải là 1
        operand_a = 32'd10; operand_b = 32'd20; alu_op = 4'b0111; 
        #10; print_res("SLT +");

        // 7. SLT Signed (Opcode 0111)
        // -5 (FFFF...) < 10 -> Kết quả phải là 1 (Test so sánh có dấu)
        operand_a = -32'd5; operand_b = 32'd10; alu_op = 4'b0111; 
        #10; print_res("SLT -");


        // --- TEST NHÓM MUX HIGH (Bit 3 = 1) ---
        // Đây là phần quan trọng để kiểm chứng thiết kế 2 tầng Mux của bạn

        // 8. NOR (Opcode 1100)
        // ~(0 | 0) = 1 (Toàn bit 1 = FFFFFFFF)
        operand_a = 32'h00000000; operand_b = 32'h00000000; alu_op = 4'b1100; 
        #10; print_res("NOR  ");

        // 9. TEST KHÔNG DÙNG (Opcode 1000)
        // Phải ra 0 vì chân này nối đất
        operand_a = 32'hFFFFFFFF; operand_b = 32'hFFFFFFFF; alu_op = 4'b1000; 
        #10; print_res("NULL ");


        // --- TEST OVERFLOW (Tràn số) ---

        // 10. Overflow ADD (Opcode 0010)
        // Max Positive + Max Positive -> Ra số Âm -> Overflow!
        // 0x7FFFFFFF (2 tỷ) + 1
        operand_a = 32'h7FFFFFFF; operand_b = 32'd1; alu_op = 4'b0010; 
        #10; print_res("OVF +");

        // 11. Overflow SUB (Opcode 0110)
        // Max Negative - 1 -> Ra số Dương -> Overflow!
        // 0x80000000 (-2 tỷ) - 1
        operand_a = 32'h80000000; operand_b = 32'd1; alu_op = 4'b0110; 
        #10; print_res("OVF -");

        $display("-----------------------------------------------------------------------------");
        $finish; // Kết thúc mô phỏng
    end

endmodule