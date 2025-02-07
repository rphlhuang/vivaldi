module wavewriter;

import "DPI-C" context function void hello();
import "DPI-C" context function int open_file(string filename);
import "DPI-C" context function void write_bytes(string data, int len);
import "DPI-C" context function void close_file();

logic [31:0] error;

initial begin
  hello();
  error = open_file("test.txt");
  if (error === 1) begin
    $display("Error opening file");
    $finish;
  end
  write_bytes("Hello World", 11);
  close_file();
  $finish;
end

endmodule
