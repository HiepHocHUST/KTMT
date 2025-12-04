// File: RegisterFile.v
// MÔ TẢ: Module Thanh ghi (Register File) theo chuẩn trang 9 PDF

module RegisterFile #(
    parameter DATA_WIDTH = 32,      // Độ rộng dữ liệu
    parameter REG_ADDR_WIDTH = 5    // 5 bit địa chỉ cho 32 thanh ghi
)(
    input  wire                      clk,             // Clock
    input  wire                      reset,           // Reset đồng bộ (Sync Reset)
    
    input  wire                      reg_write_en,    // Tín hiệu cho phép ghi
    input  wire [REG_ADDR_WIDTH-1:0] read_reg_1_addr, // Địa chỉ đọc 1 (Rs)
    input  wire [REG_ADDR_WIDTH-1:0] read_reg_2_addr, // Địa chỉ đọc 2 (Rt)
    input  wire [REG_ADDR_WIDTH-1:0] write_reg_addr,  // Địa chỉ ghi (Rd/Rt)
    input  wire [DATA_WIDTH-1:0]     write_data,      // Dữ liệu cần ghi
    
    output wire [DATA_WIDTH-1:0]     read_data_1,     // Output dữ liệu 1
    output wire [DATA_WIDTH-1:0]     read_data_2      // Output dữ liệu 2
);

    // Mảng lưu trữ 32 thanh ghi, mỗi thanh ghi 32 bit
    reg [DATA_WIDTH-1:0] registers [0:(1<<REG_ADDR_WIDTH)-1];
    integer i;

    // --- KHỐI GHI (Sequential Logic) ---
    // Reset đồng bộ: Chỉ reset khi có cạnh lên của clock
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < (1<<REG_ADDR_WIDTH); i = i + 1) begin
                registers[i] <= {DATA_WIDTH{1'b0}};
            end
        end
        else begin
            // Chỉ ghi khi Enable = 1 VÀ Địa chỉ khác 0 (vì $zero không được ghi)
            if (reg_write_en && (write_reg_addr != 0)) begin
                registers[write_reg_addr] <= write_data;
            end
        end
    end

    // --- KHỐI ĐỌC (Combinational Logic) ---
    // Đọc bất đồng bộ. Nếu địa chỉ là 0 thì luôn trả về 0.
    assign read_data_1 = (read_reg_1_addr == 0) ? {DATA_WIDTH{1'b0}} : registers[read_reg_1_addr];
    assign read_data_2 = (read_reg_2_addr == 0) ? {DATA_WIDTH{1'b0}} : registers[read_reg_2_addr];

endmodule