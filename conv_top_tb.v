module conv_top_tb;

reg clk;
reg rst;

parameter bw = 8;
parameter rows = 8;
parameter bw_psum = 2*bw + $clogb2(rows);
parameter cols = 8;
parameter height = 2;
parameter macs = cols - height + 1; //number of times each kernal-mac is instantiated


reg [rows*bw*cols-1:0] A;
reg [rows*bw*height-1:0] kern;
wire [bw_psum*macs-1:0] out;

conv_top top (.clk, .rst, .A, .kern, .out);

integer ak_file ; // file handler
integer ak_scan_file ; // file handler
integer q,i,j; 
integer  captured_data;

integer  Kk[height-1:0][rows-1:0];
integer  Aa[cols-1:0][rows-1:0];

initial begin
$dumpfile("conv_tb.vcd");
$dumpvars(0,conv_top_tb);

$display("##### A data txt reading #####");


  ak_file = $fopen("adata.txt", "r");


  for (q=0; q<cols; q=q+1) begin
    for (j=0; j<rows; j=j+1) begin
          ak_scan_file = $fscanf(ak_file, "%d\n", captured_data);
          Aa[q][j] = captured_data;
          //$display("%d\n", Aa[q][j]);
    end
  end

///// K data txt reading /////

$display("##### K data txt reading #####");

  ak_file = $fopen("kdata.txt", "r");

  for (q=0; q<height; q=q+1) begin
    for (j=0; j<rows; j=j+1) begin
          ak_scan_file = $fscanf(ak_file, "%d\n", captured_data);
          Kk[q][j] = captured_data;
          //$display("%d\n", Kk[q][j]);
    end
  end


A = 0;
kern = 0;
clk = 0;
rst = 0;

#5 clk = 1;
#5 clk = 0;
rst = 1;

#5 clk = 1;
#5 clk = 0;
rst = 0;

for(i=0; i<rows; i = i+1) begin
  for(j=0; j<cols; j=j+1) begin
    A[(i*cols+j)*bw +: bw] = Aa[j][i];
  end
end
for(i=0; i<rows; i = i+1) begin
  for(j=0; j<height; j=j+1) begin
    kern[(i*height+j)*bw +: bw] = Kk[j][i];
  end
end

for(q=0; q<5; q = q+1) begin
#5 clk = 1;
#5 clk = 0;
end


end

endmodule
