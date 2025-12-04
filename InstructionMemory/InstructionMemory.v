module InstructionMemory #(
    parameter DATA_WIDTH = 32,      // Độ rộng lệnh (32-bit)
    parameter MEM_ADDR_WIDTH = 32,  // Độ rộng địa chỉ PC
    parameter MEM_SIZE = 256        // Kích thước bộ nhớ (số lượng dòng lệnh)
)(
    input [MEM_ADDR_WIDTH-1:0] pc_address, // Địa chỉ từ PC
    output [DATA_WIDTH-1:0] instruction    // Lệnh 32-bit đầu ra
);

    // Khai báo mảng bộ nhớ (RAM/ROM)
    reg [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];

    // Khởi tạo: Nạp chương trình từ file .hex vào bộ nhớ
    initial begin
        // Lưu ý: File "program.hex" phải nằm cùng thư mục
        $readmemh("program.hex", mem);
    end

    // Đọc lệnh:
    // Vì PC thường tăng 4 bytes (0, 4, 8...) mà mảng mem lại đánh số theo index (0, 1, 2...)
    // nên ta cần dịch phải 2 bit (chia 4) để lấy đúng dòng lệnh.
    // Nếu kiến trúc của bạn dùng Word Addressing (PC tăng 1) thì bỏ ">> 2" đi.
    assign instruction = mem[pc_address >> 2]; 

endmodule