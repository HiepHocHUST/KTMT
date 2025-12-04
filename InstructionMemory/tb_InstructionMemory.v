`timescale 1ns / 1ps

module tb_InstructionMemory;

    // 1. Khai báo tham số và tín hiệu
    parameter DATA_WIDTH = 32;
    parameter MEM_ADDR_WIDTH = 32;
    parameter MEM_SIZE = 256;

    reg [MEM_ADDR_WIDTH-1:0] pc_address;
    wire [DATA_WIDTH-1:0] instruction;

    // 2. Gọi module InstructionMemory (DUT)
    InstructionMemory #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) dut (
        .pc_address(pc_address),
        .instruction(instruction)
    );

    // 3. Kịch bản mô phỏng
    initial begin
        // Tạo file sóng cho GTKWave
        $dumpfile("wave_imem.vcd");
        $dumpvars(0, tb_InstructionMemory);

        // Test case
        $display("Bat dau mo phong Instruction Memory...");

        // Đọc lệnh thứ 1 (Địa chỉ 0)
        pc_address = 32'd0;
        #10; // Đợi 10ns
        
        // Đọc lệnh thứ 2 (Địa chỉ 4 - vì mỗi lệnh 4 byte)
        pc_address = 32'd4;
        #10;

        // Đọc lệnh thứ 3 (Địa chỉ 8)
        pc_address = 32'd8;
        #10;

        // Đọc lệnh thứ 4 (Địa chỉ 12)
        pc_address = 32'd12;
        #10;

        $finish;
    end
    
    // Theo dõi kết quả trên Terminal
    initial begin
        $monitor("Time=%0tns | PC=%d | Instruction Hex=%h", $time, pc_address, instruction);
    end

endmodule