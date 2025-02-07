module wavewriter;

import "DPI-C" context function void hello();

initial begin
  hello();
  $finish;
end

endmodule
