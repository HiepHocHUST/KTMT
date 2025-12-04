// File: tb_RegisterFile.v
`timescale 1ns/1ps

module tb_RegisterFile;

    // 1. Khai báo tín hiệu nối vào Module
    reg clk;
    reg reset;
    reg reg_write_en;
    reg [4:0] read_reg_1_addr;
    reg [4:0] read_reg_2_addr;
    reg [4:0] write_reg_addr;
    reg [31:0] write_data;

    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    // 2. Gọi Module RegisterFile ra để test
    RegisterFile uut (
        .clk(clk),
        .reset(reset),
        .reg_write_en(reg_write_en),
        .read_reg_1_addr(read_reg_1_addr),
        .read_reg_2_addr(read_reg_2_addr),
        .write_reg_addr(write_reg_addr),
        .write_data(write_data),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    // 3. Tạo xung Clock (Chu kỳ 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 4. Kịch bản kiểm thử (Test Cases)
    initial begin
        // Thiết lập file ghi sóng (quan trọng cho GTKWave)
        $dumpfile("RegisterFile.vcd");
        $dumpvars(0, tb_RegisterFile);

        // --- TEST CASE 1: Reset ---
        $display("Time: %0t | Bat dau Test Reset...", $time);
        reset = 1; reg_write_en = 0; 
        read_reg_1_addr = 0; read_reg_2_addr = 0; write_reg_addr = 0; write_data = 0;
        #15; // Đợi qua cạnh clock
        reset = 0; // Thả reset
        
        // --- TEST CASE 2: Ghi vào thanh ghi R1 ---
        $display("Time: %0t | Test Ghi R1 = 100", $time);
        reg_write_en = 1;
        write_reg_addr = 5'd1;
        write_data = 32'd100;
        #10; // Đợi 1 chu kỳ clock để ghi
        reg_write_en = 0; // Tắt ghi

        // --- TEST CASE 3: Đọc thanh ghi R1 ---
        $display("Time: %0t | Test Doc R1", $time);
        read_reg_1_addr = 5'd1;
        #5;
        if (read_data_1 == 100) $display("   -> PASSED: R1 = %d", read_data_1);
        else                    $display("   -> FAILED: R1 = %d (Expected 100)", read_data_1);

        // --- TEST CASE 4: Thử ghi vào R0 ($zero) ---
        $display("Time: %0t | Test Ghi vao R0 (Phai that bai)", $time);
        reg_write_en = 1;
        write_reg_addr = 5'd0;
        write_data = 32'd999; // Cố tình ghi 999 vào R0
        #10;
        reg_write_en = 0;
        
        // Đọc lại R0
        read_reg_1_addr = 5'd0;
        #5;
        if (read_data_1 == 0) $display("   -> PASSED: R0 van la 0");
        else                  $display("   -> FAILED: R0 bi ghi thanh %d", read_data_1);

        // --- TEST CASE 5: Đọc 2 cổng cùng lúc (R1 và R0) ---
        $display("Time: %0t | Test Doc 2 cong: R1 va R0", $time);
        read_reg_1_addr = 5'd1; // R1 đang là 100
        read_reg_2_addr = 5'd0; // R0 đang là 0
        #5;
        $display("   Output 1: %d, Output 2: %d", read_data_1, read_data_2);

        $display("--- KET THUC MO PHONG ---");
        $finish;
    end

endmodule