module conv_top (clk, rst, A, kern, out); //All in parallel

parameter bw = 8;
parameter rows = 8;
parameter bw_psum = 2*bw + $clogb2(rows);
parameter cols = 8;
parameter height = 2;

input clk, rst;
input [rows*bw*cols-1:0] A;
input [rows*bw*height-1:0] kern;

//instantiate parallel mac columns depending on number of col
parameter macs = cols - height + 1; //number of times each kernal-mac is instantiated

output reg [bw_psum*macs-1:0] out;


genvar i;
genvar j;

wire [height*bw_psum*macs-1:0] out_p;

generate
for(i=0; i<macs; i = i + 1) begin
  for(j=0; j<height; j=j+1) begin
    conv1d inst (.clk, .rst, .A( A[ (i+j)*bw*rows +: bw*rows ] ), .kern( kern[ j*rows*bw +: rows*bw ] ), .out( out_p[ (i*height+j)*bw_psum +: bw_psum]) );
  end
  //adder add_inst ( .in1(), .in2() );
end
endgenerate

integer q,w;

always @(posedge clk) begin
  for(q=0; q<macs; q = q +1) 
    out[ q*bw_psum +: bw_psum ] = out_p[ (q*0+w)*bw_psum +: bw_psum];
    for(w=1; w<height; w = w+1)
      out[  q*bw_psum +: bw_psum ] += out_p[ (q*height+w)*bw_psum +: bw_psum];
end

endmodule

