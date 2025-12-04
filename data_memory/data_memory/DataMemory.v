
module DataMemory #(
    parameter DATA_WIDTH = 32,      // Độ rộng dữ liệu (mặc định 32-bit)
    parameter MEM_ADDR_WIDTH = 10   // Độ rộng địa chỉ (ví dụ 10 bit = 1024 từ nhớ)
)(
    input wire clk,
    input wire reset,               // Reset đồng bộ
    
    input wire mem_read_en,         // Tín hiệu cho phép đọc
    input wire mem_write_en,        // Tín hiệu cho phép ghi
    
    input wire [MEM_ADDR_WIDTH-1:0] mem_address, // Địa chỉ bộ nhớ
    input wire [DATA_WIDTH-1:0]     write_data,  // Dữ liệu cần ghi
    
    output reg [DATA_WIDTH-1:0]     read_data    // Dữ liệu đọc ra
);

    // 1. Khai báo mảng bộ nhớ (RAM)
    // Kích thước mảng là 2^MEM_ADDR_WIDTH
    localparam MEM_SIZE = 1 << MEM_ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];

    integer i; // Biến dùng cho vòng lặp reset

    // 2. Logic Đọc (Read Logic)
    // Sử dụng logic tổ hợp (always @* hoặc assign) để dữ liệu có ngay trong chu kỳ
    // Nếu mem_read_en = 1 thì đọc từ mem, ngược lại trả về 0 (hoặc giữ nguyên tùy thiết kế)
    always @(*) begin
        if (mem_read_en) begin
            read_data = mem[mem_address];
        end else begin
            read_data = {DATA_WIDTH{1'b0}};
        end
    end

    // 3. Logic Ghi và Reset (Write & Reset Logic) - Tuần tự (Sequential)
    always @(posedge clk) begin
        if (reset) begin
            // Reset đồng bộ: Xóa toàn bộ bộ nhớ (chỉ nên dùng trong mô phỏng/FPGA nhỏ)
            // Trong thực tế ASIC, RAM hiếm khi có reset toàn bộ.
            for (i = 0; i < MEM_SIZE; i = i + 1) begin
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end 
        else if (mem_write_en) begin
            // Chỉ ghi khi tín hiệu cho phép ghi bật
            mem[mem_address] <= write_data;
        end
    end

endmodule