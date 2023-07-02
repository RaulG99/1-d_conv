module conv_filter_top (clk, rst, A, kern, out); //For one filter

parameter bw = 8;
parameter rows = 8;
parameter bw_psum = 2*bw + $clogb2(rows);
parameter height = 2;

input clk, rst;
input [rows*bw*height-1:0] A;
input [rows*bw*height-1:0] kern;

output reg [bw_psum-1:0] out;
wire  [bw_psum*height-1:0] out_p;


genvar j;


generate
  for(j=0; j<height; j=j+1) begin
    conv1d inst (.clk, .rst, .A( A[ (i+j)*bw*rows +: bw*rows ] ), .kern( kern[ j*rows*bw +: rows*bw ] ), .out( out_p[ (j)*bw_psum +: bw_psum]) );
  end
endgenerate

integer q,w;

always @(posedge clk) begin
  out[ bw_psum-1:0 ] = 0;
  for(q=0; q<height; q = q +1) 
    out[ bw_psum-1:0 ] = out[ bw_psum-1:0 ] + out_p[ (q)*bw_psum +: bw_psum];
end

endmodule

