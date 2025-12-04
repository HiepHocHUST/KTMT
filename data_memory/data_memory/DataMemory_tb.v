
`timescale 1ns / 1ps

module DataMemory_tb;

    // Parameters
    parameter DATA_WIDTH = 32;
    parameter MEM_ADDR_WIDTH = 10;

    // Inputs
    reg clk;
    reg reset;
    reg mem_read_en;
    reg mem_write_en;
    reg [MEM_ADDR_WIDTH-1:0] mem_address;
    reg [DATA_WIDTH-1:0] write_data;

    // Outputs
    wire [DATA_WIDTH-1:0] read_data;

    // Instantiate the Unit Under Test (UUT)
    DataMemory #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .mem_address(mem_address),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Chu kỳ 10ns
    end

    // Test sequence
    initial begin
        // Setup GTKWave (Trang 8)
        $dumpfile("DataMemory_tb.vcd");
        $dumpvars(0, DataMemory_tb);

        // 1. Khởi tạo
        reset = 1;
        mem_read_en = 0;
        mem_write_en = 0;
        mem_address = 0;
        write_data = 0;
        #15; // Đợi qua cạnh lên clk để reset
        
        reset = 0;
        $display("--- Bat dau Test ---");

        // 2. Test Ghi (Write)
        // Ghi giá trị 100 vào địa chỉ 5
        #10;
        mem_address = 5;
        write_data = 32'd100;
        mem_write_en = 1;
        mem_read_en = 0;
        #10; // Đợi 1 chu kỳ clock để ghi xong
        mem_write_en = 0; // Tắt ghi

        // Ghi giá trị 255 vào địa chỉ 10
        mem_address = 10;
        write_data = 32'd255;
        mem_write_en = 1;
        #10;
        mem_write_en = 0;

        // 3. Test Đọc (Read)
        // Đọc lại địa chỉ 5
        mem_address = 5;
        mem_read_en = 1;
        #5; 
        if (read_data == 32'd100) 
            $display("[PASS] Doc dia chi 5: %d", read_data);
        else 
            $display("[FAIL] Doc dia chi 5: %d (Ky vong: 100)", read_data);

        // Đọc lại địa chỉ 10
        #5;
        mem_address = 10;
        #5;
        if (read_data == 32'd255) 
            $display("[PASS] Doc dia chi 10: %d", read_data);
        else 
            $display("[FAIL] Doc dia chi 10: %d (Ky vong: 255)", read_data);

        // Đọc địa chỉ chưa ghi (mặc định 0 sau reset)
        #5;
        mem_address = 2;
        #5;
        if (read_data == 0) 
            $display("[PASS] Doc dia chi 2 (chua ghi): %d", read_data);
        else 
            $display("[FAIL] Doc dia chi 2: %d", read_data);

        $display("--- Ket thuc Test ---");
        $finish;
    end

endmodule